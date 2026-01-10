# Agora Conversational AI Voice Agent Setup Guide

This guide walks you through setting up the voice agent feature in the KisanGuide Flutter app.

## Prerequisites

1. **Agora Account** - Sign up at https://console.agora.io
2. **Google Gemini API Key** - Get from https://makersuite.google.com/app/apikey
3. **Cartesia API Key** - Sign up at https://cartesia.ai
4. **Node.js Server** - Running on your network (for RTC token generation)

## Step 1: Get Agora Credentials

### 1.1 Create Agora Project
1. Go to https://console.agora.io
2. Sign in or create an account
3. Click "Create Project"
4. Select "Secure mode" for authentication
5. Copy your **App ID**

### 1.2 Get Customer ID and Secret
1. In Agora Console, go to **Account** → **Credentials**
2. Copy your **Customer ID** and **Customer Secret**
3. These are used for REST API authentication

### 1.3 Enable Conversational AI
1. In Agora Console, go to **Products** → **Conversational AI**
2. Click "Enable" if not already enabled
3. This activates the voice agent API

## Step 2: Get API Keys

### 2.1 Google Gemini API Key
1. Go to https://makersuite.google.com/app/apikey
2. Click "Create API Key"
3. Copy the key

### 2.2 Cartesia TTS API Key
1. Go to https://cartesia.ai
2. Sign up for an account
3. Go to **API Keys** section
4. Create a new API key
5. Copy the key and note your **Voice ID** (e.g., "en-US-AndrewMultilingualNeural")

## Step 3: Update Flutter App Configuration

### 3.1 Update Agora Service
Edit `mobile/lib/services/agora_conversational_ai_service.dart`:

```dart
// Replace these with your actual credentials
static const String appId = 'YOUR_AGORA_APP_ID';
static const String customerId = 'YOUR_CUSTOMER_ID';
static const String customerSecret = 'YOUR_CUSTOMER_SECRET';

// Gemini Configuration
static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';

// Cartesia Configuration
static const String cartesiaApiKey = 'YOUR_CARTESIA_API_KEY';
static const String cartesiaVoiceId = 'YOUR_VOICE_ID';
```

### 3.2 Update Agora RTC Service
Edit `mobile/lib/services/agora_rtc_service.dart`:

```dart
static const String appId = 'YOUR_AGORA_APP_ID';
```

## Step 4: Set Up RTC Token Generation (Backend)

The app needs RTC tokens to join Agora channels. You need to generate these on your backend server.

### 4.1 Install Agora Token Generator
```bash
cd server
npm install agora-token
```

### 4.2 Create Token Generation Endpoint
Add this to `server/server.js`:

```javascript
const { RtcTokenBuilder, RtcRole } = require('agora-token');

// Generate RTC Token endpoint
app.post('/api/rtc-token', (req, res) => {
  const { channelName, uid } = req.body;
  
  if (!channelName || uid === undefined) {
    return res.status(400).json({ error: 'Missing channelName or uid' });
  }

  try {
    const token = RtcTokenBuilder.buildTokenWithUid(
      process.env.AGORA_APP_ID,
      process.env.AGORA_APP_CERTIFICATE,
      channelName,
      uid,
      RtcRole.PUBLISHER,
      Math.floor(Date.now() / 1000) + 3600 // 1 hour expiry
    );

    res.json({ token });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

### 4.3 Update Server .env
Add to `server/.env`:

```env
AGORA_APP_ID=YOUR_AGORA_APP_ID
AGORA_APP_CERTIFICATE=YOUR_AGORA_APP_CERTIFICATE
```

## Step 5: Update Flutter App to Get Tokens from Server

Edit `mobile/lib/screens/voice_agent_screen.dart` and update the `_generateDummyToken()` method:

```dart
Future<String> _generateRtcToken(String channelName, int uid) async {
  try {
    final response = await http.post(
      Uri.parse('http://YOUR_SERVER_IP:3000/api/rtc-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'channelName': channelName,
        'uid': uid,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('Failed to generate token');
    }
  } catch (e) {
    throw Exception('Token generation error: $e');
  }
}
```

Then update `_startVoiceSession()` to use it:

```dart
final rtcToken = await _generateRtcToken(channelName, 1002);
```

## Step 6: Install Dependencies

```bash
cd mobile
flutter pub get
```

## Step 7: Configure Permissions

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to communicate with the voice agent</string>
```

## Step 8: Test the Voice Agent

1. Start your Node.js server:
```bash
cd server
npm start
```

2. Run the Flutter app:
```bash
cd mobile
flutter run
```

3. On the home screen, tap the **microphone icon** (Voice Agent)

4. Tap **"Start Session"**

5. Wait for the greeting message

6. Speak your questions naturally

7. The agent will respond with recommendations based on your farm data

## Troubleshooting

### "Microphone permission denied"
- Grant microphone permission in app settings
- On Android: Settings → Apps → KisanGuide → Permissions → Microphone
- On iOS: Settings → KisanGuide → Microphone

### "Failed to initialize Agora"
- Check that your App ID is correct
- Ensure Conversational AI is enabled in Agora Console
- Check internet connection

### "Agent not responding"
- Verify Gemini API key is valid
- Check Cartesia API key and voice ID
- Ensure server is running and accessible
- Check network connectivity

### "No audio output"
- Check device volume settings
- Verify speaker is not muted
- Restart the app

### "Token generation failed"
- Ensure backend server is running
- Check that `/api/rtc-token` endpoint exists
- Verify Agora credentials in server .env

## API Configuration Reference

### Gemini Configuration
- **Model**: `gemini-2.0-flash` (fast, efficient)
- **Max History**: 32 messages
- **Language**: English (en-US)

### Cartesia TTS Configuration
- **Model**: `sonic-2` (ultra-fast, low-latency)
- **Sample Rate**: 16000 Hz
- **Language**: English

### Agora Configuration
- **Channel Profile**: Live Broadcasting
- **Audio Profile**: Default
- **Idle Timeout**: 120 seconds

## Advanced Configuration

### Custom System Messages
Edit the `_buildSystemMessage()` method in `voice_agent_screen.dart` to customize the AI behavior.

### Voice Selection
Change the `cartesiaVoiceId` in `agora_conversational_ai_service.dart` to use different voices.

### Session Recording
Implement session recording by storing transcriptions and responses in the `VoiceSession` model.

## Security Best Practices

1. **Never commit credentials** - Use environment variables
2. **Rotate API keys** - Regularly update your keys
3. **Use HTTPS** - In production, use HTTPS for all API calls
4. **Token expiry** - Set appropriate token expiration times
5. **Rate limiting** - Implement rate limiting on your backend

## Support

For issues or questions:
- Agora Support: https://agora.io/en/support
- Gemini API Docs: https://ai.google.dev/docs
- Cartesia Docs: https://docs.cartesia.ai
- Flutter Docs: https://flutter.dev/docs

## Next Steps

1. Test voice interactions with various farm-related questions
2. Customize system messages for your use case
3. Implement session history and analytics
4. Add voice command shortcuts
5. Integrate with your farm management system
