require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const axios = require('axios');
const { RtcTokenBuilder, RtcRole } = require('agora-token');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/iot_sensors')
  .then(() => console.log('✅ MongoDB connected'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// Sensor Data Schema
const sensorSchema = new mongoose.Schema({
  temperature: { type: Number, required: true },
  humidity: { type: Number, required: true },
  soil_raw: { type: Number, required: true },
  soil_pct: { type: Number, required: true },
  timestamp: { type: Date, default: Date.now }
});

const SensorData = mongoose.model('SensorData', sensorSchema);

// Plant Status Schema
const plantStatusSchema = new mongoose.Schema({
  hasPlant: { type: Boolean, default: false },
  plantType: { type: String, default: null },
  lastUpdated: { type: Date, default: Date.now }
});

const PlantStatus = mongoose.model('PlantStatus', plantStatusSchema);

// ============================================================================
// AGORA CONVERSATIONAL AI SERVICE
// ============================================================================

class AgoraConversationalAIService {
  constructor() {
    this.appId = process.env.AGORA_APP_ID;
    this.customerId = process.env.AGORA_CUSTOMER_ID;
    this.customerSecret = process.env.AGORA_CUSTOMER_SECRET;
    this.baseUrl = 'https://api.agora.io/api/conversational-ai-agent/v2';

    this.llmApiKey = process.env.GEMINI_API_KEY;
    this.llmModel = process.env.GEMINI_MODEL || 'gemini-2.0-flash';

    this.ttsApiKey = process.env.CARTESIA_API_KEY;
    this.ttsModelId = process.env.CARTESIA_MODEL_ID || 'sonic-2';
    this.ttsVoiceId = process.env.CARTESIA_VOICE_ID;

    if (!this.appId || !this.customerId || !this.customerSecret) {
      console.warn('⚠️ Agora Conversational AI credentials not fully configured.');
    }
  }

  _getAuthHeader() {
    const credentials = `${this.customerId}:${this.customerSecret}`;
    const base64Credentials = Buffer.from(credentials).toString('base64');
    return `Basic ${base64Credentials}`;
  }

  async startAgent(channelName, token, agentName, remoteUids = ['*'], systemMessages = null) {
    try {
      if (!this.appId || !this.customerId || !this.customerSecret) {
        throw new Error('Agora credentials not configured');
      }

      console.log(`🤖 Starting Agora Conversational AI agent: ${agentName}`);
      console.log(`📋 LLM: ${this.llmModel}`);
      console.log(`🔊 TTS: Cartesia ${this.ttsModelId}`);
      console.log(`🎤 ASR: Ares`);

      // Build Gemini URL with API key in query param (per Agora docs)
      // CRITICAL: Use streamGenerateContent for streaming responses
      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${this.llmModel}:streamGenerateContent?alt=sse&key=${this.llmApiKey}`;

      console.log(`📡 Gemini URL: ${geminiUrl.substring(0, 80)}...`);
      console.log(`✅ Streaming enabled: alt=sse parameter set`);
      console.log(`✅ Response format: Server-Sent Events (SSE)`);
      console.log(`✅ Chunk processing: Enabled for real-time responses`);

      // Default system messages for agricultural assistant
      let defaultSystemMessages = [
        {
          parts: [
            {
              text: `You are an expert agricultural assistant for IoT-based farm monitoring.
Your role is to help farmers understand their sensor data and provide actionable recommendations.

TOPICS YOU SPECIALIZE IN:
- Temperature and humidity monitoring
- Soil moisture management
- Crop health and irrigation
- Pest and disease prevention
- Seasonal farming practices
- Sustainable agriculture

COMMUNICATION STYLE:
- Use simple, practical language
- Be friendly and encouraging
- Keep responses concise (2-3 sentences max for voice)
- Use analogies and relatable examples
- Be inclusive and respectful

IMPORTANT RULES:
1. NEVER give medical advice
2. ALWAYS suggest consulting agricultural experts for serious concerns
3. Provide educational information only
4. Stay on-topic about agriculture and farming
5. If asked about other topics, politely redirect to farming topics
6. Be empathetic - many farmers face real challenges

Remember: You're here to educate and support farmers with their IoT sensor data.`
            }
          ],
          role: 'user'
        }
      ];

      // Exact configuration format from Agora docs
      const requestBody = {
        name: agentName,
        properties: {
          channel: channelName,
          token: token,
          agent_rtc_uid: '999',
          remote_rtc_uids: remoteUids,
          idle_timeout: 120,
          // ASR Configuration - Agora Ares (exact format from docs)
          asr: {
            vendor: 'ares',
            language: 'en-US'
          },
          // TTS Configuration - Cartesia (exact format from docs)
          tts: {
            vendor: 'cartesia',
            params: {
              api_key: this.ttsApiKey,
              model_id: this.ttsModelId,
              voice: {
                mode: 'id',
                id: this.ttsVoiceId
              },
              output_format: {
                container: 'raw',
                sample_rate: 16000
              },
              language: 'en'
            }
          },
          // LLM Configuration - Google Gemini (exact format from docs)
          llm: {
            url: geminiUrl,
            system_messages: systemMessages || defaultSystemMessages,
            max_history: 32,
            greeting_message: 'Hello! I am your agricultural assistant. How can I help you with your farm today?',
            failure_message: 'Hold on a second. I did not understand that.',
            params: {
              model: this.llmModel
            },
            style: 'gemini'
          }
        }
      };

      console.log('📤 Request body:', JSON.stringify(requestBody, null, 2));

      const response = await axios.post(
        `${this.baseUrl}/projects/${this.appId}/join`,
        requestBody,
        {
          headers: {
            Authorization: this._getAuthHeader(),
            'Content-Type': 'application/json'
          }
        }
      );

      console.log('✅ Agent started successfully');
      console.log('🔊 Agent ID:', response.data.agent_id);
      console.log('📊 Status:', response.data.status);
      console.log('📡 Streaming: Enabled for real-time responses');
      console.log('🎯 Chunk processing: Active');

      // Validate response structure
      if (!response.data || !response.data.agent_id) {
        throw new Error('Invalid response structure from Agora API');
      }

      return {
        success: true,
        agentId: response.data.agent_id,
        status: response.data.status,
        createdAt: response.data.create_ts
      };
    } catch (error) {
      console.error('❌ Error starting agent:', error.message);
      if (error.response) {
        console.error('Response status:', error.response.status);
        console.error('Response data:', error.response.data);
        
        // Provide specific error messages
        if (error.response.status === 400) {
          console.error('❌ Bad request - Check Gemini URL and parameters');
        } else if (error.response.status === 401) {
          console.error('❌ Unauthorized - Check Agora credentials');
        } else if (error.response.status === 403) {
          console.error('❌ Forbidden - Check API permissions');
        } else if (error.response.status === 429) {
          console.error('❌ Rate limited - Too many requests');
        } else if (error.response.status === 500) {
          console.error('❌ Server error - Agora API issue');
        }
      }
      throw error;
    }
  }

  async stopAgent(agentId) {
    try {
      if (!this.appId || !this.customerId || !this.customerSecret) {
        throw new Error('Agora credentials not configured');
      }

      console.log(`🛑 Stopping Agora Conversational AI agent: ${agentId}`);

      const response = await axios.post(
        `${this.baseUrl}/projects/${this.appId}/agents/${agentId}/leave`,
        {},
        {
          headers: {
            Authorization: this._getAuthHeader(),
            'Content-Type': 'application/json'
          }
        }
      );

      console.log('✅ Agent stopped successfully');
      return {
        success: true,
        message: 'Agent stopped'
      };
    } catch (error) {
      if (error.response && error.response.status === 404) {
        console.warn('⚠️ Agent already stopped or not found (404)');
        return {
          success: true,
          message: 'Agent already stopped'
        };
      }

      console.error('❌ Error stopping agent:', error.message);
      throw error;
    }
  }

  async queryAgentStatus(agentId) {
    try {
      if (!this.appId || !this.customerId || !this.customerSecret) {
        throw new Error('Agora credentials not configured');
      }

      const response = await axios.get(
        `${this.baseUrl}/projects/${this.appId}/agents/${agentId}`,
        {
          headers: {
            Authorization: this._getAuthHeader(),
            'Content-Type': 'application/json'
          }
        }
      );

      return {
        success: true,
        agentId: response.data.agent_id,
        status: response.data.status,
        createdAt: response.data.create_ts
      };
    } catch (error) {
      console.error('❌ Error querying agent status:', error.message);
      throw error;
    }
  }
}

const agoraService = new AgoraConversationalAIService();

// ============================================================================
// AGORA TOKEN SERVICE
// ============================================================================

class AgoraTokenService {
  constructor() {
    this.appId = process.env.AGORA_APP_ID;
    this.appCertificate = process.env.AGORA_APP_CERTIFICATE;

    if (!this.appId || !this.appCertificate) {
      console.warn('⚠️ Agora App ID or Certificate not configured.');
    }
  }

  generateToken(channelName, uid, expirationTimeInSeconds = 3600) {
    try {
      if (!this.appId || !this.appCertificate) {
        throw new Error('Agora credentials not configured');
      }

      console.log(`🔑 Generating RTC token for channel: ${channelName}, uid: ${uid}`);

      const token = RtcTokenBuilder.buildTokenWithUid(
        this.appId,
        this.appCertificate,
        channelName,
        uid,
        RtcRole.PUBLISHER,
        expirationTimeInSeconds
      );

      console.log('✅ RTC token generated successfully');
      return token;
    } catch (error) {
      console.error('❌ Error generating RTC token:', error.message);
      throw error;
    }
  }

  generateAgentTokenWithRtm2(channelName, uid, expirationTimeInSeconds = 3600) {
    try {
      if (!this.appId || !this.appCertificate) {
        throw new Error('Agora credentials not configured');
      }

      console.log(`🔑 Generating RTC+RTM2 token for channel: ${channelName}, uid: ${uid}`);

      if (typeof RtcTokenBuilder.buildTokenWithRtm2 === 'function') {
        const token = RtcTokenBuilder.buildTokenWithRtm2(
          this.appId,
          this.appCertificate,
          channelName,
          uid,
          RtcRole.PUBLISHER,
          expirationTimeInSeconds,
          expirationTimeInSeconds,
          expirationTimeInSeconds,
          expirationTimeInSeconds,
          expirationTimeInSeconds,
          String(uid),
          expirationTimeInSeconds
        );
        console.log('✅ RTC+RTM2 token generated successfully');
        return token;
      } else {
        console.warn('⚠️ buildTokenWithRtm2 not available, using buildTokenWithUid');
        return this.generateToken(channelName, uid, expirationTimeInSeconds);
      }
    } catch (error) {
      console.error('❌ Error generating RTC+RTM2 token:', error.message);
      return this.generateToken(channelName, uid, expirationTimeInSeconds);
    }
  }
}

const tokenService = new AgoraTokenService();

// ============================================================================
// ROUTES
// ============================================================================

// GET credentials for mobile app
app.get('/api/config/credentials', (req, res) => {
  try {
    const credentials = {
      gemini: {
        apiKey: process.env.GEMINI_API_KEY,
        model: process.env.GEMINI_MODEL || 'gemini-2.0-flash'
      },
      agora: {
        appId: process.env.AGORA_APP_ID,
        customerId: process.env.AGORA_CUSTOMER_ID,
        customerSecret: process.env.AGORA_CUSTOMER_SECRET
      },
      cartesia: {
        apiKey: process.env.CARTESIA_API_KEY,
        modelId: process.env.CARTESIA_MODEL_ID || 'sonic-2',
        voiceId: process.env.CARTESIA_VOICE_ID
      }
    };

    const missing = [];
    if (!credentials.gemini.apiKey) missing.push('GEMINI_API_KEY');
    if (!credentials.agora.appId) missing.push('AGORA_APP_ID');
    if (!credentials.agora.customerId) missing.push('AGORA_CUSTOMER_ID');
    if (!credentials.agora.customerSecret) missing.push('AGORA_CUSTOMER_SECRET');
    if (!credentials.cartesia.apiKey) missing.push('CARTESIA_API_KEY');
    if (!credentials.cartesia.voiceId) missing.push('CARTESIA_VOICE_ID');

    if (missing.length > 0) {
      return res.status(400).json({
        success: false,
        error: 'Missing credentials',
        missing: missing
      });
    }

    res.json({
      success: true,
      credentials: credentials
    });
  } catch (error) {
    console.error('Error fetching credentials:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST endpoint for RTC token generation
app.post('/api/rtc-token', (req, res) => {
  try {
    const { channelName, uid, expirationTimeInSeconds = 86400 } = req.body;

    if (!channelName || uid === undefined) {
      return res.status(400).json({
        success: false,
        error: 'Missing channelName or uid'
      });
    }

    const token = tokenService.generateToken(channelName, uid, expirationTimeInSeconds);

    res.json({
      success: true,
      token: token,
      channelName: channelName,
      uid: uid,
      expiresIn: expirationTimeInSeconds
    });
  } catch (error) {
    console.error('Error generating RTC token:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST endpoint for starting Agora Conversational AI agent
app.post('/api/agora-ai/start-agent', async (req, res) => {
  try {
    const { channelName, agentName, systemMessages = null } = req.body;

    console.log(`📥 Received start-agent request`);
    console.log(`   Channel: ${channelName}`);
    console.log(`   Agent: ${agentName}`);
    console.log(`   System Messages: ${systemMessages ? 'provided' : 'using default'}`);

    if (!channelName || !agentName) {
      console.error('❌ Missing required parameters');
      return res.status(400).json({
        success: false,
        error: 'channelName and agentName are required'
      });
    }

    // Validate Agora credentials are configured
    if (!process.env.AGORA_APP_ID || !process.env.AGORA_CUSTOMER_ID || !process.env.AGORA_CUSTOMER_SECRET) {
      console.error('❌ Agora credentials not configured in .env');
      return res.status(400).json({
        success: false,
        error: 'Agora credentials not configured. Check server/.env'
      });
    }

    // Validate Gemini credentials
    if (!process.env.GEMINI_API_KEY) {
      console.error('❌ Gemini API key not configured');
      return res.status(400).json({
        success: false,
        error: 'Gemini API key not configured. Check server/.env'
      });
    }

    // Validate Cartesia credentials
    if (!process.env.CARTESIA_API_KEY || !process.env.CARTESIA_VOICE_ID) {
      console.error('❌ Cartesia credentials not configured');
      return res.status(400).json({
        success: false,
        error: 'Cartesia credentials not configured. Check server/.env'
      });
    }

    // Generate token for agent UID 999 with RTM2 privileges
    const agentUid = 999;
    console.log(`🔑 Generating RTM2 token for agent UID ${agentUid}...`);
    const agentToken = tokenService.generateAgentTokenWithRtm2(channelName, agentUid, 3600);
    console.log(`✅ Token generated successfully`);

    console.log(`🤖 Calling agoraService.startAgent()...`);
    const result = await agoraService.startAgent(
      channelName,
      agentToken,
      agentName,
      ['*'],
      systemMessages
    );

    console.log(`✅ Agent start result:`, result);
    res.json(result);
  } catch (error) {
    console.error('❌ Error starting agent:', error.message);
    console.error('Stack:', error.stack);
    res.status(500).json({
      success: false,
      error: error.message,
      details: error.response?.data || 'No additional details'
    });
  }
});

// POST endpoint for stopping Agora Conversational AI agent
app.post('/api/agora-ai/stop-agent', async (req, res) => {
  try {
    const { agentId } = req.body;

    if (!agentId) {
      return res.status(400).json({
        success: false,
        error: 'agentId is required'
      });
    }

    const result = await agoraService.stopAgent(agentId);
    res.json(result);
  } catch (error) {
    console.error('Error stopping agent:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// GET endpoint for agent status
app.get('/api/agora-ai/agent-status/:agentId', async (req, res) => {
  try {
    const { agentId } = req.params;

    if (!agentId) {
      return res.status(400).json({
        success: false,
        error: 'agentId is required'
      });
    }

    const result = await agoraService.queryAgentStatus(agentId);
    res.json(result);
  } catch (error) {
    console.error('Error querying agent status:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});


// POST endpoint for NodeMCU to send data
app.post('/api/ingest', async (req, res) => {
  console.log(`[${new Date().toISOString()}] POST /api/ingest from ${req.ip}`);
  console.log('Body:', req.body);
  try {
    const { temperature, humidity, soil_raw, soil_pct } = req.body;
    
    const sensorData = new SensorData({
      temperature,
      humidity,
      soil_raw,
      soil_pct
    });
    
    await sensorData.save();
    res.status(201).json({ success: true, message: 'Data saved', id: sensorData._id });
  } catch (error) {
    console.error('Error saving data:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET latest sensor reading
app.get('/api/latest', async (req, res) => {
  try {
    const latest = await SensorData.findOne().sort({ timestamp: -1 });
    res.json(latest || {});
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET all readings with pagination
app.get('/api/readings', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 100;
    const skip = parseInt(req.query.skip) || 0;
    
    const readings = await SensorData.find()
      .sort({ timestamp: -1 })
      .limit(limit)
      .skip(skip);
    
    const total = await SensorData.countDocuments();
    
    res.json({ readings, total, limit, skip });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET readings within time range
app.get('/api/readings/range', async (req, res) => {
  try {
    const { start, end } = req.query;
    const query = {};
    
    if (start || end) {
      query.timestamp = {};
      if (start) query.timestamp.$gte = new Date(start);
      if (end) query.timestamp.$lte = new Date(end);
    }
    
    const readings = await SensorData.find(query).sort({ timestamp: -1 });
    res.json(readings);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

// ============================================================================
// PLANT STATUS ENDPOINTS
// ============================================================================

// GET plant status
app.get('/api/plant-status', async (req, res) => {
  try {
    let status = await PlantStatus.findOne();
    
    // If no status exists, create default one
    if (!status) {
      status = new PlantStatus({ hasPlant: false });
      await status.save();
    }
    
    res.json({
      success: true,
      data: {
        hasPlant: status.hasPlant,
        plantType: status.plantType,
        lastUpdated: status.lastUpdated
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// POST/UPDATE plant status
app.post('/api/plant-status', async (req, res) => {
  try {
    const { hasPlant, plantType } = req.body;
    
    let status = await PlantStatus.findOne();
    
    if (!status) {
      status = new PlantStatus({
        hasPlant,
        plantType,
        lastUpdated: new Date()
      });
    } else {
      status.hasPlant = hasPlant;
      status.plantType = plantType;
      status.lastUpdated = new Date();
    }
    
    await status.save();
    
    console.log(`🌱 Plant status updated: hasPlant=${hasPlant}, plantType=${plantType}`);
    
    res.json({
      success: true,
      data: {
        hasPlant: status.hasPlant,
        plantType: status.plantType,
        lastUpdated: status.lastUpdated
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// ============================================================================
// PLANT DISEASE DETECTION ENDPOINT
// ============================================================================

// POST endpoint for plant disease detection
app.post('/api/plant-disease/detect', async (req, res) => {
  const fs = require('fs');
  const path = require('path');
  const os = require('os');
  
  try {
    const { image } = req.body;

    if (!image) {
      return res.status(400).json({
        success: false,
        error: 'Image is required'
      });
    }

    console.log(`🌱 Detecting plant disease from image...`);

    // Write base64 image to temporary file
    const tempDir = os.tmpdir();
    const tempImagePath = path.join(tempDir, `plant_${Date.now()}.jpg`);
    
    try {
      const imageBuffer = Buffer.from(image, 'base64');
      fs.writeFileSync(tempImagePath, imageBuffer);
      console.log(`📝 Temp image saved: ${tempImagePath}`);
    } catch (writeError) {
      console.error('❌ Error writing temp image:', writeError);
      return res.status(500).json({
        success: false,
        error: 'Failed to process image'
      });
    }

    // Call Python service with file path instead of base64
    const { spawn } = require('child_process');
    const python = spawn('python', [
      './plant_disease_service.py',
      tempImagePath
    ]);

    let output = '';
    let error = '';

    python.stdout.on('data', (data) => {
      output += data.toString();
    });

    python.stderr.on('data', (data) => {
      error += data.toString();
    });

    python.on('close', (code) => {
      // Clean up temp file
      try {
        if (fs.existsSync(tempImagePath)) {
          fs.unlinkSync(tempImagePath);
          console.log(`🗑️ Temp image cleaned up`);
        }
      } catch (cleanupError) {
        console.warn('⚠️ Warning cleaning up temp file:', cleanupError.message);
      }

      if (code !== 0) {
        console.error('❌ Python error (exit code ' + code + '):', error);
        return res.status(500).json({
          success: false,
          error: 'Plant disease detection failed',
          details: error || 'No error output'
        });
      }

      if (!output) {
        console.error('❌ Python produced no output');
        return res.status(500).json({
          success: false,
          error: 'Plant disease detection failed',
          details: 'No output from Python service'
        });
      }

      try {
        const result = JSON.parse(output);
        
        if (!result.success) {
          console.error('❌ Detection failed:', result.error);
          return res.status(500).json({
            success: false,
            error: result.error || 'Detection failed'
          });
        }
        
        console.log('✅ Plant disease detection complete');
        console.log(`🌿 Prediction: ${result.prediction}`);
        console.log(`📊 Confidence: ${(result.confidence * 100).toFixed(2)}%`);
        res.json(result);
      } catch (e) {
        console.error('❌ Error parsing Python output:', e);
        console.error('Raw output:', output);
        res.status(500).json({
          success: false,
          error: 'Failed to parse detection results',
          details: output
        });
      }
    });

  } catch (error) {
    console.error('Error in plant disease detection:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// GET endpoint for disease information
app.get('/api/plant-disease/info/:disease', (req, res) => {
  try {
    const { disease } = req.params;
    
    // Parse disease name
    const [plant, condition] = disease.split('___');
    
    res.json({
      success: true,
      plant: plant || 'Unknown',
      condition: condition || 'Unknown',
      is_healthy: condition && condition.toLowerCase() === 'healthy',
      recommendations: _getDiseaseRecommendations(disease)
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Helper function to get disease recommendations
function _getDiseaseRecommendations(disease) {
  const recommendations = {
    'Apple___Apple_scab': [
      'Mix baking soda with water and spray on leaves',
      'Pick off bad leaves and throw away',
      'Cut branches to let air flow',
      'Spray cooking oil mixed with water'
    ],
    'Apple___Black_rot': [
      'Cut out the black parts with a knife',
      'Spray baking soda solution on tree',
      'Remove fallen fruit from ground',
      'Make sure water drains well around tree'
    ],
    'Tomato___Early_blight': [
      'Remove leaves touching the ground',
      'Spray milk mixed with water (1 milk : 9 water)',
      'Put dry grass around plant base',
      'Water only the soil, not the leaves'
    ],
    'Tomato___Late_blight': [
      'Pick off all bad leaves right away',
      'Spray baking soda or cooking oil solution',
      'Let air flow between plants',
      'Never spray water on leaves'
    ],
    'Potato___Early_blight': [
      'Remove leaves that look bad',
      'Spray milk solution on plant',
      'Put dry grass around plant',
      'Plant potatoes in different spot next year'
    ],
    'Potato___Late_blight': [
      'Remove the whole plant if very bad',
      'Spray baking soda solution',
      'Make sure soil drains water well',
      'Never spray water on leaves'
    ],
    'Corn___Common_rust': [
      'Remove leaves with rust spots',
      'Spray cooking oil mixed with water',
      'Let air flow between plants',
      'Plant rust-resistant corn next time'
    ],
    'Corn___Northern_Leaf_Blight': [
      'Remove bad leaves from plant',
      'Spray baking soda solution',
      'Plant in different spot next year',
      'Plant disease-resistant corn'
    ],
    'Grape___Black_rot': [
      'Remove grapes and leaves with black spots',
      'Spray baking soda or sulfur powder',
      'Cut branches to let air flow',
      'Clean up fallen fruit and leaves'
    ],
    'Pepper,_bell___Bacterial_spot': [
      'Remove leaves with spots',
      'Spray baking soda solution',
      'Never spray water on leaves',
      'Let air flow between plants'
    ],
    'Strawberry___Leaf_scorch': [
      'Remove bad leaves',
      'Spray cooking oil mixed with water',
      'Let air flow between plants',
      'Water only the soil'
    ]
  };
  
  return recommendations[disease] || [
    'Remove the bad leaves and throw away',
    'Spray baking soda or cooking oil solution',
    'Let air flow around the plant',
    'Keep the plant away from others'
  ];
}

// ============================================================================
// FCM NOTIFICATION SERVICE
// ============================================================================

const fcmService = require('./fcm-service');
fcmService.initializeFirebase();

// FCM Device Token Schema
const fcmTokenSchema = new mongoose.Schema({
  token: { type: String, required: true, unique: true },
  createdAt: { type: Date, default: Date.now },
  lastUsed: { type: Date, default: Date.now }
});

const FCMToken = mongoose.model('FCMToken', fcmTokenSchema);

// POST endpoint to register FCM token
app.post('/api/fcm-token', async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        error: 'FCM token is required'
      });
    }

    // Save or update token
    await FCMToken.findOneAndUpdate(
      { token },
      { lastUsed: new Date() },
      { upsert: true, new: true }
    );

    console.log(`✅ FCM token registered: ${token.substring(0, 20)}...`);

    res.json({
      success: true,
      message: 'FCM token registered successfully'
    });
  } catch (error) {
    console.error('❌ Error registering FCM token:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// POST endpoint to send test notification
app.post('/api/test-notification', async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        error: 'FCM token is required'
      });
    }

    const success = await fcmService.sendNotification(
      token,
      '🌱 Test Notification',
      'FCM is working correctly! Your plant monitoring system is ready.',
      {
        type: 'TEST',
        action: 'open_home_screen'
      }
    );

    res.json({
      success: success,
      message: success ? 'Test notification sent' : 'Failed to send notification'
    });
  } catch (error) {
    console.error('❌ Error sending test notification:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// POST endpoint to send alert notification
app.post('/api/send-alert', async (req, res) => {
  try {
    const { token, alertType, sensorValue, unit, plantName } = req.body;

    if (!token || !alertType || sensorValue === undefined || !unit) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: token, alertType, sensorValue, unit'
      });
    }

    const success = await fcmService.sendAlertNotification(
      token,
      alertType,
      sensorValue,
      unit,
      plantName
    );

    res.json({
      success: success,
      message: success ? 'Alert notification sent' : 'Failed to send alert'
    });
  } catch (error) {
    console.error('❌ Error sending alert notification:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// GET endpoint to get all registered FCM tokens (for admin)
app.get('/api/fcm-tokens', async (req, res) => {
  try {
    const tokens = await FCMToken.find().select('token createdAt lastUsed');

    res.json({
      success: true,
      count: tokens.length,
      tokens: tokens
    });
  } catch (error) {
    console.error('❌ Error fetching FCM tokens:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📍 Accepting connections from all network interfaces`);
  console.log(`🌱 Plant Disease Detection API available at /api/plant-disease/detect`);
  console.log(`📬 FCM Notification API available at /api/fcm-token`);
});
