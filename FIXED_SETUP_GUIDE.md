# Fixed Setup Guide - Credentials from Server

All issues have been fixed. Here's how to get everything working:

## ✅ What Was Fixed

1. **Dependencies** - Updated `permission_handler` to compatible version
2. **Services** - Fixed all syntax errors in Agora and permission services
3. **Credentials** - All credentials now fetched from server `.env`
4. **Tokens** - RTC tokens generated on server

## 🚀 Quick Setup (3 Steps)

### Step 1: Update Server Credentials

Edit `server/.env`:

```env
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
```

### Step 2: Start Server

```bash
cd server
npm install
npm start
```

Server will run on `http://localhost:3000`

### Step 3: Run Mobile App

```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

**Done!** The app will automatically fetch credentials from the server.

## 📡 Server Endpoints

### GET /api/config/credentials
Returns all credentials for the mobile app.

```bash
curl http://localhost:3000/api/config/credentials
```

### POST /api/rtc-token
Generates RTC tokens for Agora channels.

```bash
curl -X POST http://localhost:3000/api/rtc-token \
  -H "Content-Type: application/json" \
  -d '{"channelName":"voice_agent_123","uid":1002}'
```

## 📁 Updated Files

### Server
- `server/.env` - All credentials
- `server/server.js` - Two new endpoints

### Mobile
- `mobile/lib/services/gemini_service.dart` - Fetches from server
- `mobile/lib/services/agora_rtc_service.dart` - Fetches from server
- `mobile/lib/services/agora_conversational_ai_service.dart` - Fetches from server
- `mobile/lib/screens/voice_agent_screen.dart` - Gets tokens from server
- `mobile/pubspec.yaml` - Updated dependencies

## 🔐 Security

✅ No credentials in mobile app code
✅ All credentials in server `.env` (git-ignored)
✅ Easy to rotate credentials
✅ Environment-specific configuration

## 🧪 Testing

### 1. Test Server Endpoints

```bash
# Test credentials endpoint
curl http://localhost:3000/api/config/credentials

# Test token generation
curl -X POST http://localhost:3000/api/rtc-token \
  -H "Content-Type: application/json" \
  -d '{"channelName":"test","uid":1002}'
```

### 2. Test Mobile App

1. Start server: `npm start`
2. Run app: `flutter run`
3. Tap voice agent button
4. Check logs for successful credential fetching

## 📋 Credentials Needed

Get these from:

| Credential | Source |
|-----------|--------|
| GEMINI_API_KEY | https://makersuite.google.com/app/apikey |
| AGORA_APP_ID | https://console.agora.io |
| AGORA_CUSTOMER_ID | Agora Console → Account → Credentials |
| AGORA_CUSTOMER_SECRET | Agora Console → Account → Credentials |
| AGORA_APP_CERTIFICATE | Agora Console → Project Settings |
| CARTESIA_API_KEY | https://cartesia.ai |
| CARTESIA_VOICE_ID | Cartesia Console → Voices |

## ✨ Features

✅ Real-time voice conversations with AI
✅ Sensor data context awareness
✅ Ultra-fast speech synthesis
✅ Natural language understanding
✅ Session management
✅ Microphone control
✅ Comprehensive error handling

## 🎯 How It Works

```
Mobile App
    ↓
Requests credentials from server
    ↓
Server reads from .env file
    ↓
Returns credentials to mobile app
    ↓
Mobile app uses credentials for:
- Gemini AI
- Agora RTC
- Cartesia TTS
```

## 📚 Documentation

- `CREDENTIALS_FROM_SERVER_SETUP.md` - Detailed setup guide
- `CREDENTIALS_MIGRATION_SUMMARY.md` - Migration overview
- `VOICE_AGENT_SETUP.md` - Voice agent configuration
- `VOICE_AGENT_README.md` - Complete technical documentation

## 🆘 Troubleshooting

### "Failed to fetch credentials from server"
- Ensure server is running: `npm start`
- Check server URL in mobile app
- Verify network connectivity

### "Missing credentials"
- Check `server/.env` file
- Ensure all required variables are set
- Restart server after updating `.env`

### "Flutter pub get failed"
- Run: `flutter clean`
- Run: `flutter pub get`
- Check internet connection

### "Agora initialization failed"
- Verify App ID is correct in `.env`
- Check Conversational AI is enabled in Agora Console
- Restart server

## ✅ Verification Checklist

- [ ] Server `.env` has all credentials
- [ ] Server is running: `npm start`
- [ ] Mobile app dependencies installed: `flutter pub get`
- [ ] Mobile app runs: `flutter run`
- [ ] Voice agent button visible on home screen
- [ ] Can start voice session
- [ ] Agent greeting is heard
- [ ] Can speak and get responses

## 🎉 You're Ready!

Everything is set up and ready to use. The voice agent will now:
1. Fetch credentials from server
2. Generate RTC tokens on server
3. Connect to Agora
4. Use Gemini for AI
5. Use Cartesia for voice

Enjoy your voice-enabled agricultural assistant!
