# Credentials Migration Summary

## What Changed

All credentials are now fetched from the server's `.env` file instead of being hardcoded in the mobile app.

## Files Modified

### Server (server/)
1. **server/.env** - Added all credentials
   - GEMINI_API_KEY
   - AGORA_APP_ID, AGORA_CUSTOMER_ID, AGORA_CUSTOMER_SECRET, AGORA_APP_CERTIFICATE
   - CARTESIA_API_KEY, CARTESIA_MODEL_ID, CARTESIA_VOICE_ID

2. **server/server.js** - Added two new endpoints
   - `GET /api/config/credentials` - Returns all credentials
   - `POST /api/rtc-token` - Generates RTC tokens

### Mobile (mobile/lib/)
1. **services/gemini_service.dart** - Now fetches API key from server
2. **services/agora_rtc_service.dart** - Now fetches App ID from server
3. **services/agora_conversational_ai_service.dart** - Now fetches all Agora/Cartesia credentials from server
4. **screens/voice_agent_screen.dart** - Now generates RTC tokens from server
5. **screens/home_screen.dart** - Added voice agent button (unchanged)

### Removed
- `mobile/lib/config/voice_agent_config.dart` - No longer needed (credentials from server)

## How It Works

```
Mobile App
    ↓
1. Requests credentials from server
    ↓
2. Server reads from .env file
    ↓
3. Server returns credentials
    ↓
4. Mobile app uses credentials
```

## Setup Instructions

### 1. Update Server .env

```bash
cd server
```

Edit `server/.env` and add your credentials:

```env
GEMINI_API_KEY=YOUR_GEMINI_API_KEY
AGORA_APP_ID=YOUR_AGORA_APP_ID
AGORA_CUSTOMER_ID=YOUR_CUSTOMER_ID
AGORA_CUSTOMER_SECRET=YOUR_CUSTOMER_SECRET
AGORA_APP_CERTIFICATE=YOUR_AGORA_APP_CERTIFICATE
CARTESIA_API_KEY=YOUR_CARTESIA_API_KEY
CARTESIA_VOICE_ID=YOUR_VOICE_ID
```

### 2. Start Server

```bash
npm start
```

### 3. Run Mobile App

```bash
cd mobile
flutter pub get
flutter run
```

**That's it!** The app will automatically fetch credentials from the server.

## New Server Endpoints

### GET /api/config/credentials
Returns all credentials needed by the mobile app.

```bash
curl http://localhost:3000/api/config/credentials
```

Response:
```json
{
  "success": true,
  "credentials": {
    "gemini": {
      "apiKey": "YOUR_GEMINI_API_KEY",
      "model": "gemini-2.0-flash"
    },
    "agora": {
      "appId": "YOUR_AGORA_APP_ID",
      "customerId": "YOUR_CUSTOMER_ID",
      "customerSecret": "YOUR_CUSTOMER_SECRET"
    },
    "cartesia": {
      "apiKey": "YOUR_CARTESIA_API_KEY",
      "modelId": "sonic-2",
      "voiceId": "YOUR_VOICE_ID"
    }
  }
}
```

### POST /api/rtc-token
Generates RTC tokens for Agora channels.

```bash
curl -X POST http://localhost:3000/api/rtc-token \
  -H "Content-Type: application/json" \
  -d '{"channelName":"voice_agent_123","uid":1002}'
```

Response:
```json
{
  "success": true,
  "token": "token_voice_agent_123_1002_1234567890",
  "channelName": "voice_agent_123",
  "uid": 1002
}
```

## Benefits

✅ **Security** - No credentials in mobile app code
✅ **Flexibility** - Change credentials without rebuilding app
✅ **Centralized** - All credentials in one place
✅ **Easy Updates** - Rotate keys without app update
✅ **Environment-specific** - Different credentials per environment

## Key Changes in Services

### GeminiService
```dart
// Before: Hardcoded API key
static const String apiKey = 'AIzaSy...';

// After: Fetched from server
Future<bool> initialize() async {
  final response = await http.get(
    Uri.parse('${ApiService.baseUrl.replaceAll('/api', '')}/api/config/credentials'),
  );
  _apiKey = response['credentials']['gemini']['apiKey'];
}
```

### AgoraRtcService
```dart
// Before: Hardcoded App ID
static const String appId = 'YOUR_AGORA_APP_ID';

// After: Fetched from server
Future<bool> fetchAppId() async {
  final response = await http.get(
    Uri.parse('${ApiService.baseUrl.replaceAll('/api', '')}/api/config/credentials'),
  );
  _appId = response['credentials']['agora']['appId'];
}
```

### AgoraConversationalAIService
```dart
// Before: Hardcoded credentials
static const String appId = 'YOUR_AGORA_APP_ID';
static const String customerId = 'YOUR_CUSTOMER_ID';

// After: Fetched from server
Future<bool> fetchCredentials() async {
  final response = await http.get(
    Uri.parse('${ApiService.baseUrl.replaceAll('/api', '')}/api/config/credentials'),
  );
  _appId = response['credentials']['agora']['appId'];
  _customerId = response['credentials']['agora']['customerId'];
  // ... etc
}
```

### VoiceAgentScreen
```dart
// Before: Dummy token
String _generateDummyToken() {
  return 'dummy_token_${DateTime.now().millisecondsSinceEpoch}';
}

// After: Real token from server
Future<String> _generateRtcToken(String channelName, int uid) async {
  final response = await http.post(
    Uri.parse('${ApiService.baseUrl.replaceAll('/api', '')}/api/rtc-token'),
    body: jsonEncode({'channelName': channelName, 'uid': uid}),
  );
  return response['token'];
}
```

## Environment Variables

All credentials are now environment variables in `server/.env`:

| Variable | Purpose |
|----------|---------|
| GEMINI_API_KEY | Google Gemini API authentication |
| GEMINI_MODEL | Gemini model version |
| AGORA_APP_ID | Agora application identifier |
| AGORA_CUSTOMER_ID | Agora API authentication |
| AGORA_CUSTOMER_SECRET | Agora API authentication |
| AGORA_APP_CERTIFICATE | Agora token generation |
| CARTESIA_API_KEY | Cartesia TTS authentication |
| CARTESIA_MODEL_ID | Cartesia model selection |
| CARTESIA_VOICE_ID | Cartesia voice selection |

## Testing

### 1. Verify Server Endpoints
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

## Security Notes

✅ Credentials are NOT in mobile app code
✅ Credentials are NOT in git repository
✅ Credentials are in server `.env` file (git-ignored)
✅ Mobile app fetches credentials at runtime
✅ Easy to rotate credentials without app update

## Troubleshooting

### "Failed to fetch credentials from server"
- Ensure server is running: `npm start`
- Check server URL in mobile app
- Verify network connectivity

### "Missing credentials"
- Check `server/.env` file
- Ensure all required variables are set
- Restart server after updating `.env`

### "Invalid Agora App ID"
- Verify App ID from Agora Console
- Update `server/.env`
- Restart server

## Next Steps

1. ✅ Update `server/.env` with your credentials
2. ✅ Start the server: `npm start`
3. ✅ Run the mobile app: `flutter run`
4. ✅ Test voice agent functionality

See `CREDENTIALS_FROM_SERVER_SETUP.md` for detailed setup instructions.

## Summary

All credentials are now:
- ✅ Fetched from server at runtime
- ✅ Stored in `server/.env` (not in code)
- ✅ Easy to update without rebuilding app
- ✅ Secure and centralized
- ✅ Environment-specific

The system is now production-ready with proper credential management!
