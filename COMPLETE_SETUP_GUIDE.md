# Complete Setup Guide - KisanGuide Voice Agent

This is the complete, step-by-step guide to set up and run the KisanGuide app with voice agent functionality.

## 📋 Prerequisites

- Flutter SDK installed
- Node.js and npm installed
- MongoDB running locally (or connection string)
- Agora account with Conversational AI enabled
- Google Gemini API key
- Cartesia TTS API key
- Android Studio or Xcode (for mobile development)

## 🚀 Complete Setup (Step by Step)

### Phase 1: Server Setup

#### Step 1.1: Install Server Dependencies

```bash
cd server
npm install
```

#### Step 1.2: Configure Server Credentials

Edit `server/.env` and add your credentials:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017/iot_sensors

# CORS Configuration
CORS_ORIGIN=*

# API Configuration
API_BASE_URL=http://localhost:3000/api

# ============================================================================
# GEMINI AI Configuration
# ============================================================================
GEMINI_API_KEY=YOUR_GEMINI_API_KEY
GEMINI_MODEL=gemini-2.0-flash

# ============================================================================
# AGORA CONFIGURATION
# ============================================================================
AGORA_APP_ID=YOUR_AGORA_APP_ID
AGORA_CUSTOMER_ID=YOUR_CUSTOMER_ID
AGORA_CUSTOMER_SECRET=YOUR_CUSTOMER_SECRET
AGORA_APP_CERTIFICATE=YOUR_AGORA_APP_CERTIFICATE

# ============================================================================
# CARTESIA TTS Configuration
# ============================================================================
CARTESIA_API_KEY=YOUR_CARTESIA_API_KEY
CARTESIA_MODEL_ID=sonic-2
CARTESIA_VOICE_ID=YOUR_VOICE_ID

# ============================================================================
# NodeMCU Configuration
# ============================================================================
NODEMCU_SERVER_URL=http://localhost:3000/api/ingest

# Sensor Calibration Values
SOIL_DRY_ADC=800
SOIL_WET_ADC=300
```

#### Step 1.3: Start Server

```bash
npm start
```

You should see:
```
Server running on port 3000
Accepting connections from all network interfaces
MongoDB connected
```

### Phase 2: Mobile App Setup

#### Step 2.1: Install Flutter Dependencies

```bash
cd mobile
flutter clean
flutter pub get
```

#### Step 2.2: Verify Build

```bash
flutter analyze
```

Should show no errors.

#### Step 2.3: Run on Android

```bash
flutter run -d android
```

Or on iOS:

```bash
flutter run -d ios
```

### Phase 3: Test Voice Agent

#### Step 3.1: Open App

1. App opens on home screen
2. Tap the **microphone icon** in the top right

#### Step 3.2: Grant Permissions

1. Permission dialog appears
2. Tap "Grant Permission"
3. System permission dialog appears
4. Tap "Allow"

#### Step 3.3: Start Voice Session

1. Tap "Start Session"
2. Wait for status to show "Voice session active"
3. Agent greeting is heard

#### Step 3.4: Test Voice Interaction

1. Speak a question like:
   - "What's the current temperature?"
   - "Is the soil too dry?"
   - "Should I water the plants?"
2. Listen for AI response
3. Tap "Stop Session" when done

## 📡 Server Endpoints

### Sensor Data Endpoints

**GET /api/latest** - Get latest sensor reading
```bash
curl http://localhost:3000/api/latest
```

**GET /api/readings** - Get historical readings
```bash
curl http://localhost:3000/api/readings?limit=50
```

**POST /api/ingest** - NodeMCU sends sensor data
```bash
curl -X POST http://localhost:3000/api/ingest \
  -H "Content-Type: application/json" \
  -d '{"temperature":25.5,"humidity":60,"soil_raw":500,"soil_pct":50}'
```

### Voice Agent Endpoints

**GET /api/config/credentials** - Get all credentials
```bash
curl http://localhost:3000/api/config/credentials
```

**POST /api/rtc-token** - Generate RTC token
```bash
curl -X POST http://localhost:3000/api/rtc-token \
  -H "Content-Type: application/json" \
  -d '{"channelName":"voice_agent_123","uid":1002}'
```

**GET /health** - Health check
```bash
curl http://localhost:3000/health
```

## 🔐 Getting Credentials

### 1. Google Gemini API Key

1. Go to https://makersuite.google.com/app/apikey
2. Click "Create API Key"
3. Copy the key
4. Add to `server/.env` as `GEMINI_API_KEY`

### 2. Agora Credentials

1. Go to https://console.agora.io
2. Create a project
3. Copy **App ID**
4. Go to Account → Credentials
5. Copy **Customer ID** and **Customer Secret**
6. Go to Project Settings
7. Copy **App Certificate**
8. Add all to `server/.env`

### 3. Cartesia TTS Credentials

1. Go to https://cartesia.ai
2. Sign up for account
3. Go to API Keys
4. Create new API key
5. Go to Voices section
6. Select a voice and copy its ID
7. Add to `server/.env`

## 📱 Platform-Specific Configuration

### Android

**Permissions** (already configured in `mobile/android/app/src/main/AndroidManifest.xml`):
- `RECORD_AUDIO` - Microphone access
- `INTERNET` - API calls
- `ACCESS_NETWORK_STATE` - Network detection

**Testing:**
```bash
flutter run -d android
```

### iOS

**Permissions** (already configured in `mobile/ios/Runner/Info.plist`):
- `NSMicrophoneUsageDescription` - Microphone explanation
- `NSCameraUsageDescription` - Camera explanation

**Testing:**
```bash
flutter run -d ios
```

## 🧪 Testing Checklist

### Server Tests

- [ ] Server starts without errors
- [ ] MongoDB connects successfully
- [ ] `/health` endpoint responds
- [ ] `/api/config/credentials` returns credentials
- [ ] `/api/rtc-token` generates tokens
- [ ] `/api/ingest` accepts sensor data

### Mobile Tests

- [ ] App builds without errors
- [ ] App starts on home screen
- [ ] Sensor data displays
- [ ] Voice agent button visible
- [ ] Permission dialog appears
- [ ] Permission can be granted
- [ ] Voice session starts
- [ ] Agent greeting is heard
- [ ] Microphone captures audio
- [ ] Agent responds with voice
- [ ] Session stops cleanly

### Voice Agent Tests

- [ ] Microphone permission requested
- [ ] Microphone permission granted
- [ ] RTC channel joins successfully
- [ ] Agora agent starts
- [ ] Speech recognition works
- [ ] Gemini AI responds
- [ ] Cartesia TTS speaks
- [ ] Audio quality acceptable
- [ ] No audio feedback loops
- [ ] Session ends cleanly

## 🆘 Troubleshooting

### Server Issues

**"MongoDB connection error"**
- Ensure MongoDB is running
- Check connection string in `.env`
- Verify MongoDB is accessible

**"Port 3000 already in use"**
- Change PORT in `.env`
- Or kill process using port 3000

**"Missing credentials"**
- Check all required variables in `.env`
- Restart server after updating `.env`

### Mobile Issues

**"Failed to fetch credentials from server"**
- Ensure server is running
- Check server URL is correct
- Verify network connectivity

**"Microphone permission denied"**
- Grant permission in Settings
- Revoke and re-grant permission
- Restart app

**"Agent not responding"**
- Verify all API keys are valid
- Check network connectivity
- Check server logs for errors

**"No audio output"**
- Check device volume
- Check speaker is not muted
- Check app volume is not muted

## 📚 Documentation Files

- `FIXED_SETUP_GUIDE.md` - Quick setup guide
- `CREDENTIALS_FROM_SERVER_SETUP.md` - Credentials configuration
- `VOICE_PERMISSIONS_SETUP.md` - Permission handling
- `VOICE_AGENT_SETUP.md` - Voice agent configuration
- `VOICE_AGENT_README.md` - Technical documentation
- `QUICK_START_VOICE_AGENT.md` - Quick start guide

## 🎯 Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                   │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │           VoiceAgentScreen (UI)                  │   │
│  └──────────────────────────────────────────────────┘   │
│                          ↓                                │
│  ┌──────────────────────────────────────────────────┐   │
│  │  AgoraRtcService    AgoraConversationalAIService │   │
│  │  (RTC Channel)      (Voice AI Agent)             │   │
│  └──────────────────────────────────────────────────┘   │
│                          ↓                                │
│  ┌──────────────────────────────────────────────────┐   │
│  │  VoicePermissionService (Microphone Access)      │   │
│  └──────────────────────────────────────────────────┘   │
│                                                           │
└─────────────────────────────────────────────────────────┘
                          ↓
        ┌─────────────────┼─────────────────┐
        ↓                 ↓                 ↓
    ┌────────┐      ┌──────────┐      ┌──────────┐
    │ Agora  │      │ Gemini   │      │ Cartesia │
    │ RTC    │      │ AI       │      │ TTS      │
    │Engine  │      │ (LLM)    │      │ (Voice)  │
    └────────┘      └──────────┘      └──────────┘
```

## 🔄 Data Flow

```
1. User speaks
   ↓
2. Microphone captures audio
   ↓
3. Audio → Agora RTC Channel
   ↓
4. Agora Conversational AI Engine
   ↓
5. Speech Recognition (ASR)
   ↓
6. Gemini AI Processing
   ↓
7. Cartesia TTS (Text to Speech)
   ↓
8. Audio → Agora RTC Channel
   ↓
9. User hears response
```

## ✨ Features

✅ Real-time voice conversations
✅ Sensor data context awareness
✅ Ultra-fast speech synthesis
✅ Natural language understanding
✅ Session management
✅ Microphone control
✅ Error handling
✅ Permission management
✅ Multi-platform support (Android & iOS)

## 🎉 You're Ready!

Everything is set up and ready to use. The voice agent will:

1. Request microphone permission
2. Connect to Agora RTC
3. Use Gemini for AI understanding
4. Use Cartesia for voice synthesis
5. Provide real-time responses

Enjoy your voice-enabled agricultural assistant!

## 📞 Support

For issues or questions:
- Check troubleshooting section
- Review documentation files
- Check server logs: `npm start`
- Check app logs: `flutter run`

## 📝 Next Steps

1. ✅ Set up server with credentials
2. ✅ Install mobile dependencies
3. ✅ Run app and grant permissions
4. ✅ Test voice agent
5. ✅ Deploy to production

Happy farming with KisanGuide! 🌾
