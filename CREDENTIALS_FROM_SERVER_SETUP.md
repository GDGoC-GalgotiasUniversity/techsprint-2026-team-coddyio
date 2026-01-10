# Credentials from Server Setup Guide

This guide explains how the app now fetches all credentials from the server's `.env` file instead of hardcoding them in the mobile app.

## Architecture

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

## Benefits

✅ **Security** - No credentials in mobile app code
✅ **Flexibility** - Change credentials without rebuilding app
✅ **Centralized** - All credentials in one place
✅ **Easy Updates** - Rotate keys without app update
✅ **Environment-specific** - Different credentials per environment

## Server Setup

### 1. Update server/.env

Add all credentials to `server/.env`:

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

### 2. Server Endpoints

The server now provides two new endpoints:

#### GET /api/config/credentials
Returns all credentials needed by the mobile app.

**Response:**
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

#### POST /api/rtc-token
Generates RTC tokens for joining Agora channels.

**Request:**
```json
{
  "channelName": "voice_agent_123",
  "uid": 1002
}
```

**Response:**
```json
{
  "success": true,
  "token": "token_voice_agent_123_1002_1234567890",
  "channelName": "voice_agent_123",
  "uid": 1002
}
```

## Mobile App Changes

### 1. Gemini Service

Now fetches API key from server on initialization:

```dart
class GeminiService {
  Future<bool> initialize() async {
    // Fetches credentials from server
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl.replaceAll('/api', '')}/api/config/credentials'),
    );
    // Uses fetched credentials
  }
}
```

### 2. Agora RTC Service

Fetches App ID from server:

```dart
class AgoraRtcService {
  Future<bool> fetchAppId() async {
    // Fetches Agora App ID from server
  }
  
  Future<bool> initialize() async {
    // Uses fetched App ID
  }
}
```

### 3. Agora Conversational AI Service

Fetches all Agora and Cartesia credentials from server:

```dart
class AgoraConversationalAIService {
  Future<bool> fetchCredentials() async {
    // Fetches all credentials from server
  }
  
  Future<Map<String, dynamic>> startAgent(...) async {
    // Uses fetched credentials
  }
}
```

### 4. Voice Agent Screen

Generates RTC tokens from server:

```dart
Future<String> _generateRtcToken(String channelName, int uid) async {
  final response = await http.post(
    Uri.parse('${ApiService.baseUrl.replaceAll('/api', '')}/api/rtc-token'),
    body: jsonEncode({'channelName': channelName, 'uid': uid}),
  );
  return response['token'];
}
```

## Configuration File Removed

The `mobile/lib/config/voice_agent_config.dart` file is no longer needed since all credentials come from the server.

You can delete it or keep it for reference.

## Setup Steps

### 1. Server Configuration

```bash
cd server
npm install
```

Update `server/.env` with your credentials:
```env
GEMINI_API_KEY=your_gemini_key
AGORA_APP_ID=your_agora_app_id
AGORA_CUSTOMER_ID=your_customer_id
AGORA_CUSTOMER_SECRET=your_customer_secret
AGORA_APP_CERTIFICATE=your_app_certificate
CARTESIA_API_KEY=your_cartesia_key
CARTESIA_VOICE_ID=your_voice_id
```

Start the server:
```bash
npm start
```

### 2. Mobile App

No configuration needed! The app will automatically fetch credentials from the server.

Just run:
```bash
cd mobile
flutter pub get
flutter run
```

## Security Best Practices

### 1. Server Security
- Keep `.env` file secure
- Never commit `.env` to git
- Use `.gitignore` to exclude `.env`
- Restrict access to `/api/config/credentials` endpoint

### 2. Credential Rotation
- Update credentials in `server/.env`
- No need to rebuild mobile app
- Changes take effect immediately

### 3. Environment-Specific Credentials
- Use different `.env` files for dev/staging/production
- Load appropriate `.env` based on environment
- Example:
  ```bash
  NODE_ENV=production npm start
  ```

### 4. API Key Protection
- Use environment variables
- Never log credentials
- Validate credentials on server startup
- Implement rate limiting on credential endpoint

## Troubleshooting

### "Failed to fetch credentials from server"
**Cause:** Server not running or endpoint not accessible
**Solution:**
1. Ensure server is running: `npm start`
2. Check server URL in mobile app
3. Verify network connectivity

### "Missing credentials"
**Cause:** Some credentials not set in `.env`
**Solution:**
1. Check `server/.env` file
2. Ensure all required variables are set
3. Restart server after updating `.env`

### "Invalid Agora App ID"
**Cause:** Wrong App ID in `.env`
**Solution:**
1. Verify App ID from Agora Console
2. Update `server/.env`
3. Restart server

### "Token generation failed"
**Cause:** RTC token endpoint not working
**Solution:**
1. Check server logs
2. Verify endpoint is accessible
3. Check request format

## Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| GEMINI_API_KEY | Google Gemini API key | AIzaSy... |
| GEMINI_MODEL | Gemini model version | gemini-2.0-flash |
| AGORA_APP_ID | Agora application ID | a1b2c3d4... |
| AGORA_CUSTOMER_ID | Agora customer ID | 123456 |
| AGORA_CUSTOMER_SECRET | Agora customer secret | abc123... |
| AGORA_APP_CERTIFICATE | Agora app certificate | xyz789... |
| CARTESIA_API_KEY | Cartesia API key | cart_... |
| CARTESIA_MODEL_ID | Cartesia model ID | sonic-2 |
| CARTESIA_VOICE_ID | Cartesia voice ID | en-US-... |

## API Endpoints

### Credentials Endpoint
```
GET /api/config/credentials
```
Returns all credentials for mobile app.

### RTC Token Endpoint
```
POST /api/rtc-token
Content-Type: application/json

{
  "channelName": "string",
  "uid": "number"
}
```
Generates RTC token for Agora channel.

## Testing

### 1. Test Credentials Endpoint
```bash
curl http://localhost:3000/api/config/credentials
```

### 2. Test Token Generation
```bash
curl -X POST http://localhost:3000/api/rtc-token \
  -H "Content-Type: application/json" \
  -d '{"channelName":"test","uid":1002}'
```

### 3. Test Mobile App
1. Start server: `npm start`
2. Run app: `flutter run`
3. Tap voice agent button
4. Check logs for credential fetching

## Migration from Hardcoded Credentials

If you had hardcoded credentials before:

1. **Remove from mobile app:**
   - Delete `mobile/lib/config/voice_agent_config.dart`
   - Remove hardcoded credentials from services

2. **Add to server:**
   - Update `server/.env` with credentials
   - Restart server

3. **Test:**
   - Run mobile app
   - Verify credentials are fetched from server

## Production Deployment

### 1. Secure .env File
```bash
# Set restrictive permissions
chmod 600 server/.env

# Ensure it's not in git
echo ".env" >> .gitignore
```

### 2. Use Environment Variables
```bash
# Instead of .env file, use system environment variables
export GEMINI_API_KEY=your_key
export AGORA_APP_ID=your_id
npm start
```

### 3. Restrict Credentials Endpoint
Consider adding authentication to `/api/config/credentials`:
```javascript
app.get('/api/config/credentials', authenticateRequest, (req, res) => {
  // Return credentials only to authenticated clients
});
```

### 4. Use Secrets Management
For production, use a secrets manager:
- AWS Secrets Manager
- HashiCorp Vault
- Azure Key Vault
- Google Cloud Secret Manager

## Summary

✅ All credentials now fetched from server
✅ No hardcoded secrets in mobile app
✅ Easy credential rotation
✅ Environment-specific configuration
✅ Improved security
✅ Centralized management

The mobile app is now more secure and flexible!
