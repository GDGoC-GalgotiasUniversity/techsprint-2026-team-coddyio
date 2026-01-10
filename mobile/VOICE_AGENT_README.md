# Agora Conversational AI Voice Agent Integration

This document describes the voice agent feature integrated into the KisanGuide Flutter app using Agora's Conversational AI Engine with Google Gemini and Cartesia TTS.

## Overview

The voice agent enables farmers to have natural voice conversations with an AI assistant that understands their farm's sensor data and provides real-time recommendations.

### Key Features

- **Real-time Voice Interaction** - Natural voice conversations with AI
- **Sensor Context Awareness** - AI understands current farm conditions
- **Multi-language Support** - English (extensible to other languages)
- **Low-latency Response** - Ultra-fast TTS with Cartesia
- **Session Management** - Track conversation history and duration
- **Error Handling** - Graceful fallbacks and user feedback

## Architecture

### Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter App (KisanGuide)                 │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           VoiceAgentScreen (UI)                      │   │
│  └──────────────────────────────────────────────────────┘   │
│                          ↓                                    │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  AgoraRtcService    AgoraConversationalAIService     │   │
│  │  (RTC Channel)      (Voice AI Agent)                 │   │
│  └──────────────────────────────────────────────────────┘   │
│                          ↓                                    │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  VoicePermissionService (Microphone Access)          │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
        ┌─────────────────┼─────────────────┐
        ↓                 ↓                 ↓
    ┌────────┐      ┌──────────┐      ┌──────────┐
    │ Agora  │      │ Gemini   │      │ Cartesia │
    │ RTC    │      │ AI       │      │ TTS      │
    │Engine  │      │ (LLM)    │      │ (Voice)  │
    └────────┘      └──────────┘      └──────────┘
```

### Data Flow

```
1. User speaks → Microphone captures audio
2. Audio → Agora RTC Channel → Agora Conversational AI Engine
3. Engine → Google Gemini (processes with sensor context)
4. Gemini response → Cartesia TTS (converts to speech)
5. Speech → Agora RTC Channel → User's speaker
```

## File Structure

```
mobile/lib/
├── config/
│   └── voice_agent_config.dart          # Configuration constants
├── models/
│   ├── sensor_data.dart                 # Sensor data model
│   └── voice_session.dart               # Voice session model
├── screens/
│   ├── home_screen.dart                 # Main screen (with voice button)
│   ├── voice_agent_screen.dart          # Voice agent UI
│   ├── ai_chat_screen.dart              # Text-based AI chat
│   └── history_screen.dart              # Historical data
├── services/
│   ├── api_service.dart                 # Backend API calls
│   ├── agora_rtc_service.dart           # RTC channel management
│   ├── agora_conversational_ai_service.dart  # Voice AI agent
│   ├── gemini_service.dart              # Gemini text AI
│   └── voice_permission_service.dart    # Permission handling
└── widgets/
    ├── sensor_card.dart                 # Sensor display card
    └── mini_chart.dart                  # Mini chart widget
```

## Configuration

### 1. Update Configuration File

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

### 2. Validate Configuration

The app includes a validation method:

```dart
if (!VoiceAgentConfig.isConfigured()) {
  final missing = VoiceAgentConfig.getMissingConfigurations();
  print('Missing: $missing');
}
```

## Usage

### Starting a Voice Session

```dart
// From VoiceAgentScreen
await _startVoiceSession();
```

This:
1. Requests microphone permission
2. Initializes Agora RTC Engine
3. Joins RTC channel
4. Starts conversational AI agent
5. Creates VoiceSession object

### Stopping a Voice Session

```dart
await _stopVoiceSession();
```

This:
1. Stops the AI agent
2. Leaves RTC channel
3. Releases resources
4. Ends the session

### Toggling Microphone

```dart
await _toggleMicrophone();
```

Mutes/unmutes the microphone during an active session.

## API Integration

### Agora Conversational AI REST API

The service uses Agora's REST API for agent management:

#### Start Agent
```
POST https://api.agora.io/api/conversational-ai-agent/v2/projects/{appId}/join
Authorization: Basic {base64(customerId:customerSecret)}
Content-Type: application/json

{
  "name": "unique_agent_name",
  "properties": {
    "channel": "channel_name",
    "token": "rtc_token",
    "agent_rtc_uid": "0",
    "remote_rtc_uids": ["1002"],
    "llm": { ... },
    "asr": { ... },
    "tts": { ... }
  }
}
```

#### Stop Agent
```
POST https://api.agora.io/api/conversational-ai-agent/v2/projects/{appId}/agents/{agentId}/leave
Authorization: Basic {base64(customerId:customerSecret)}
```

### Gemini Configuration

```json
{
  "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:streamGenerateContent?alt=sse&key={apiKey}",
  "system_messages": [
    {
      "parts": [{"text": "You are an agricultural assistant..."}],
      "role": "user"
    }
  ],
  "max_history": 32,
  "greeting_message": "Hello! How can I help?",
  "failure_message": "Sorry, I didn't understand.",
  "params": {
    "model": "gemini-2.0-flash"
  },
  "style": "gemini"
}
```

### Cartesia TTS Configuration

```json
{
  "vendor": "cartesia",
  "params": {
    "api_key": "{cartesiaApiKey}",
    "model_id": "sonic-2",
    "voice": {
      "mode": "id",
      "id": "{voiceId}"
    },
    "output_format": {
      "container": "raw",
      "sample_rate": 16000
    },
    "language": "en"
  }
}
```

## Models

### VoiceSession

Represents an active voice conversation session:

```dart
class VoiceSession {
  final String sessionId;           // Unique session identifier
  final String channelName;         // Agora channel name
  final String rtcToken;            // RTC authentication token
  final String agentId;             // Agora agent ID
  final DateTime startTime;         // Session start time
  final String status;              // 'active', 'paused', 'ended'
  final List<String> transcriptions; // User inputs
  final List<String> responses;     // Agent responses
}
```

### SensorData

Represents current farm sensor readings:

```dart
class SensorData {
  final String id;
  final double temperature;         // °C
  final double humidity;            // %
  final int soilRaw;               // Raw ADC value
  final double soilPct;            // Percentage
  final DateTime timestamp;
}
```

## Services

### AgoraRtcService

Manages RTC channel connection:

```dart
// Initialize
await _agoraRtcService.initialize();

// Join channel
await _agoraRtcService.joinChannel(
  token: rtcToken,
  channelName: channelName,
  uid: 1002,
);

// Control microphone
await _agoraRtcService.enableMicrophone(true);

// Leave channel
await _agoraRtcService.leaveChannel();

// Cleanup
await _agoraRtcService.dispose();
```

### AgoraConversationalAIService

Manages voice AI agent:

```dart
// Start agent
final result = await _agoraAIService.startAgent(
  channelName: 'farm_session_123',
  rtcToken: rtcToken,
  systemMessage: 'You are an agricultural assistant...',
  greetingMessage: 'Hello! How can I help?',
);

// Query status
final status = await _agoraAIService.queryAgentStatus();

// Stop agent
await _agoraAIService.stopAgent();
```

### VoicePermissionService

Handles microphone permissions:

```dart
// Request permission
final granted = await VoicePermissionService.requestMicrophonePermission();

// Check permission
final isGranted = await VoicePermissionService.isMicrophonePermissionGranted();

// Request all permissions
final allGranted = await VoicePermissionService.requestAllVoicePermissions();
```

## Error Handling

The app handles various error scenarios:

### Permission Denied
```
Status: "Microphone permission denied"
Action: Show dialog, guide user to settings
```

### Initialization Failed
```
Status: "Failed to initialize Agora"
Action: Log error, show retry button
```

### Network Error
```
Status: "Error: Connection timeout"
Action: Show error dialog, allow retry
```

### Agent Not Responding
```
Status: "Agent disconnected"
Action: Notify user, offer to restart session
```

## Customization

### Custom System Messages

Edit `_buildSystemMessage()` in `voice_agent_screen.dart`:

```dart
String _buildSystemMessage() {
  return '''You are an expert agricultural assistant.
Current conditions:
- Temperature: ${widget.sensorData?.temperature}°C
- Humidity: ${widget.sensorData?.humidity}%
- Soil Moisture: ${widget.sensorData?.soilPct}%

Provide specific recommendations based on these readings.''';
}
```

### Voice Selection

Change voice in `voice_agent_config.dart`:

```dart
static const String cartesiaVoiceId = 'en-US-FemaleNeural'; // Different voice
```

### Session Recording

Extend `VoiceSession` to store transcriptions:

```dart
_currentSession = _currentSession?.addTranscription(userInput);
_currentSession = _currentSession?.addResponse(agentResponse);
```

## Performance Optimization

### Lazy Loading
Voice service is only initialized when needed (on screen open).

### Resource Management
- RTC engine properly disposed on screen close
- Timers cancelled to prevent memory leaks
- Permissions cached to avoid repeated requests

### Network Optimization
- Token generation cached during session
- API calls batched where possible
- Timeout handling for slow networks

## Security Considerations

1. **Credentials Management**
   - Never hardcode credentials in production
   - Use environment variables or secure storage
   - Rotate API keys regularly

2. **Token Security**
   - Generate tokens on backend, not client
   - Set appropriate expiration times
   - Validate tokens before use

3. **Data Privacy**
   - Sensor data only sent to AI for context
   - Session data stored locally only
   - Clear sensitive data on logout

4. **Network Security**
   - Use HTTPS for all API calls
   - Validate SSL certificates
   - Implement rate limiting

## Troubleshooting

### Issue: "Microphone permission denied"
**Solution:**
1. Go to Settings → Apps → KisanGuide
2. Tap Permissions → Microphone
3. Select "Allow"
4. Restart the app

### Issue: "Failed to initialize Agora"
**Solution:**
1. Verify App ID is correct
2. Check internet connection
3. Ensure Conversational AI is enabled in Agora Console
4. Check firewall/proxy settings

### Issue: "Agent not responding"
**Solution:**
1. Check Gemini API key validity
2. Verify Cartesia credentials
3. Check network connectivity
4. Restart the session

### Issue: "No audio output"
**Solution:**
1. Check device volume
2. Verify speaker is not muted
3. Check audio permissions
4. Restart the app

## Testing

### Manual Testing Checklist

- [ ] Microphone permission request works
- [ ] Session starts successfully
- [ ] Agent greeting is heard
- [ ] User speech is recognized
- [ ] Agent responds appropriately
- [ ] Microphone toggle works
- [ ] Session stops cleanly
- [ ] Error messages are clear
- [ ] App doesn't crash on errors
- [ ] Resources are cleaned up

### Test Scenarios

1. **Happy Path**
   - Start session → Speak question → Get response → Stop session

2. **Permission Denied**
   - Deny microphone permission → See error → Retry

3. **Network Error**
   - Disconnect network → See error → Reconnect → Retry

4. **Long Session**
   - Run for 5+ minutes → Verify stability

5. **Multiple Sessions**
   - Start/stop multiple times → Verify cleanup

## Future Enhancements

1. **Session History**
   - Store and replay past conversations
   - Analytics on common questions

2. **Offline Mode**
   - Cache responses for offline use
   - Sync when online

3. **Multi-language Support**
   - Support regional languages
   - Auto-detect language

4. **Advanced Analytics**
   - Track conversation patterns
   - Provide insights to farmers

5. **Integration with IoT**
   - Direct control of irrigation systems
   - Automated recommendations

## Support & Resources

- **Agora Documentation**: https://docs.agora.io
- **Gemini API Docs**: https://ai.google.dev/docs
- **Cartesia Docs**: https://docs.cartesia.ai
- **Flutter Docs**: https://flutter.dev/docs
- **GitHub Issues**: Report bugs and feature requests

## License

This integration is part of the KisanGuide project. See LICENSE file for details.

## Contributors

- Agora Conversational AI Team
- Google Gemini Team
- Cartesia TTS Team
- KisanGuide Development Team
