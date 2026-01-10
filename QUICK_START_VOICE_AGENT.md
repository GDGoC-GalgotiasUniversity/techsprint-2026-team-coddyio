# Quick Start: Agora Voice Agent Integration

## 5-Minute Setup

### Step 1: Install Dependencies
```bash
cd mobile
flutter pub get
```

### Step 2: Get Your Credentials

#### Agora
1. Go to https://console.agora.io
2. Create a project
3. Copy **App ID**
4. Go to Account → Credentials
5. Copy **Customer ID** and **Customer Secret**

#### Google Gemini
1. Go to https://makersuite.google.com/app/apikey
2. Click "Create API Key"
3. Copy the key

#### Cartesia TTS
1. Go to https://cartesia.ai
2. Sign up and get **API Key**
3. Note a **Voice ID** (e.g., "en-US-AndrewMultilingualNeural")

### Step 3: Update Configuration

Edit `mobile/lib/config/voice_agent_config.dart`:

```dart
class VoiceAgentConfig {
  static const String agoraAppId = 'YOUR_AGORA_APP_ID';
  static const String agoraCustomerId = 'YOUR_CUSTOMER_ID';
  static const String agoraCustomerSecret = 'YOUR_CUSTOMER_SECRET';
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  static const String cartesiaApiKey = 'YOUR_CARTESIA_API_KEY';
  static const String cartesiaVoiceId = 'YOUR_VOICE_ID';
  static const String serverUrl = 'http://YOUR_SERVER_IP:3000';
}
```

### Step 4: Set Up Backend Token Generation

Add to `server/server.js`:

```javascript
const { RtcTokenBuilder, RtcRole } = require('agora-token');

app.post('/api/rtc-token', (req, res) => {
  const { channelName, uid } = req.body;
  
  try {
    const token = RtcTokenBuilder.buildTokenWithUid(
      process.env.AGORA_APP_ID,
      process.env.AGORA_APP_CERTIFICATE,
      channelName,
      uid,
      RtcRole.PUBLISHER,
      Math.floor(Date.now() / 1000) + 3600
    );
    res.json({ token });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

Add to `server/.env`:

```env
AGORA_APP_ID=YOUR_AGORA_APP_ID
AGORA_APP_CERTIFICATE=YOUR_AGORA_APP_CERTIFICATE
```

Install dependency:
```bash
cd server
npm install agora-token
```

### Step 5: Run the App

```bash
cd mobile
flutter run
```

### Step 6: Test Voice Agent

1. Tap the **microphone icon** on the home screen
2. Tap **"Start Session"**
3. Wait for the greeting
4. Speak your question
5. Listen to the AI response
6. Tap **"Stop Session"** when done

## What You Get

✅ Real-time voice conversations with AI
✅ Sensor data context awareness
✅ Ultra-fast speech synthesis
✅ Natural language understanding
✅ Agricultural expertise

## File Structure

```
mobile/lib/
├── config/voice_agent_config.dart          ← Update credentials here
├── services/
│   ├── agora_conversational_ai_service.dart
│   ├── agora_rtc_service.dart
│   └── voice_permission_service.dart
├── screens/voice_agent_screen.dart         ← Voice UI
└── models/voice_session.dart
```

## Troubleshooting

### "Microphone permission denied"
→ Grant permission in Settings → Apps → KisanGuide → Permissions

### "Failed to initialize Agora"
→ Check App ID is correct in config file

### "Agent not responding"
→ Verify all API keys are valid

### "No audio output"
→ Check device volume and speaker settings

## Next Steps

1. Read `mobile/VOICE_AGENT_SETUP.md` for detailed setup
2. Read `mobile/VOICE_AGENT_README.md` for full documentation
3. Customize system messages in `voice_agent_screen.dart`
4. Test with various farm-related questions

## Key Files

- **Configuration**: `mobile/lib/config/voice_agent_config.dart`
- **Voice UI**: `mobile/lib/screens/voice_agent_screen.dart`
- **AI Service**: `mobile/lib/services/agora_conversational_ai_service.dart`
- **RTC Service**: `mobile/lib/services/agora_rtc_service.dart`
- **Setup Guide**: `mobile/VOICE_AGENT_SETUP.md`
- **Full Docs**: `mobile/VOICE_AGENT_README.md`

## Support

- Agora: https://docs.agora.io
- Gemini: https://ai.google.dev/docs
- Cartesia: https://docs.cartesia.ai
- Flutter: https://flutter.dev/docs

---

**You're all set!** The voice agent is ready to use. Start the app and tap the microphone icon to begin.
