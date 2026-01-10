require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const { RtcTokenBuilder, RtcRole } = require('agora-token');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/iot_sensors')
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB connection error:', err));

// Sensor Data Schema
const sensorSchema = new mongoose.Schema({
  temperature: { type: Number, required: true },
  humidity: { type: Number, required: true },
  soil_raw: { type: Number, required: true },
  soil_pct: { type: Number, required: true },
  timestamp: { type: Date, default: Date.now }
});

const SensorData = mongoose.model('SensorData', sensorSchema);

// Routes

// GET credentials for mobile app (voice agent configuration)
app.get('/api/config/credentials', (req, res) => {
  try {
    // Return only non-sensitive configuration
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

    // Validate that all required credentials are present
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
    const { channelName, uid } = req.body;

    if (!channelName || uid === undefined) {
      return res.status(400).json({
        success: false,
        error: 'Missing channelName or uid'
      });
    }

    // Get Agora credentials from environment
    const appId = process.env.AGORA_APP_ID;
    const appCertificate = process.env.AGORA_APP_CERTIFICATE;

    if (!appId || !appCertificate) {
      // Return a demo token if credentials not configured
      console.warn('Agora credentials not configured, returning demo token');
      const demoToken = `demo_token_${channelName}_${uid}_${Date.now()}`;
      return res.json({
        success: true,
        token: demoToken,
        channelName: channelName,
        uid: uid,
        mode: 'demo'
      });
    }

    // Generate proper RTC token
    const expirationTimeInSeconds = 3600; // 1 hour
    const currentTimestamp = Math.floor(Date.now() / 1000);
    const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appCertificate,
      channelName,
      uid,
      RtcRole.PUBLISHER,
      privilegeExpiredTs
    );

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

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Accepting connections from all network interfaces`);
});
