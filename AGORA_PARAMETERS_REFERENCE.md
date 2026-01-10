# Agora Conversational AI - Exact Parameters Reference

This document details the exact parameters being used in the implementation, matching Agora's official documentation.

## API Endpoint

```
POST https://api.agora.io/api/conversational-ai-agent/v2/projects/{appId}/join
```

## Authentication

```
Authorization: Basic {base64(customerId:customerSecret)}
Content-Type: application/json
```

## Request Payload Structure

```json
{
  "name": "voice_agent_{timestamp}",
  "properties": {
    "channel": "{channelName}",
    "token": "{rtcToken}",
    "agent_rtc_uid": "0",
    "remote_rtc_uids": ["1002"],
    "enable_string_uid": false,
    "idle_timeout": 120,
    "llm": { ... },
    "asr": { ... },
    "tts": { ... }
  }
}
```

## LLM Configuration (Gemini)

### Parameter Details

| Parameter | Value | Description |
|-----------|-------|-------------|
| `url` | `https://generativelanguage.googleapis.com/v1beta/models/{model}:streamGenerateContent?alt=sse&key={apiKey}` | Gemini API endpoint with streaming |
| `style` | `gemini` | Specifies Gemini LLM style |
| `model` | `gemini-2.0-flash` | Model identifier in params |

### System Messages Format

```json
{
  "system_messages": [
    {
      "parts": [
        {
          "text": "You are an expert agricultural assistant..."
        }
      ],
      "role": "user"
    }
  ]
}
```

**Key Points:**
- `parts` is an ARRAY of objects (not a string)
- Each part has `text` property
- `role` must be `"user"` for system messages
- Multiple parts can be included for complex prompts

### Complete LLM Configuration

```json
{
  "llm": {
    "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:streamGenerateContent?alt=sse&key=AIzaSyB_5nuaBg9Hpg7LiCX7YsBgpyGv-KQHXro",
    "system_messages": [
      {
        "parts": [
          {
            "text": "You are an expert agricultural assistant for IoT-based farm monitoring.\nCurrent farm conditions:\n- Temperature: 22.5°C\n- Humidity: 36.9%\n- Soil Moisture: 98.4%\n- Last Updated: 2026-01-10T15:23:51.842Z\n\nHelp farmers understand their sensor data and provide actionable recommendations based on these readings.\nBe concise, friendly, and practical in your responses."
          }
        ],
        "role": "user"
      }
    ],
    "max_history": 32,
    "greeting_message": "Hello! I am your agricultural assistant. How can I help you with your farm today?",
    "failure_message": "Hold on a second. I did not understand that.",
    "params": {
      "model": "gemini-2.0-flash"
    },
    "style": "gemini"
  }
}
```

## ASR Configuration

```json
{
  "asr": {
    "language": "en-US"
  }
}
```

**Supported Languages:**
- `en-US` - English (United States)
- `en-GB` - English (United Kingdom)
- `zh-CN` - Chinese (Simplified)
- `zh-TW` - Chinese (Traditional)
- `ja-JP` - Japanese
- `ko-KR` - Korean
- `es-ES` - Spanish
- `fr-FR` - French
- `de-DE` - German
- `it-IT` - Italian
- `pt-BR` - Portuguese (Brazil)
- `ru-RU` - Russian

## TTS Configuration (Cartesia)

### Parameter Details

| Parameter | Value | Description |
|-----------|-------|-------------|
| `vendor` | `cartesia` | TTS provider |
| `api_key` | `sk_car_...` | Cartesia API key |
| `model_id` | `sonic-3` | Cartesia model (sonic-2 or sonic-3) |
| `voice.mode` | `id` | Voice selection mode |
| `voice.id` | `{voiceId}` | Specific voice ID |
| `output_format.container` | `raw` | Audio container format |
| `output_format.sample_rate` | `16000` | Sample rate in Hz |
| `language` | `en` | Language code |

### Complete TTS Configuration

```json
{
  "tts": {
    "vendor": "cartesia",
    "params": {
      "api_key": "sk_car_6trWSv23KdCNswkDj7tPdh",
      "model_id": "sonic-3",
      "voice": {
        "mode": "id",
        "id": "95d51f79-c397-46f9-b49a-23763d3eaa2d"
      },
      "output_format": {
        "container": "raw",
        "sample_rate": 16000
      },
      "language": "en"
    }
  }
}
```

**Important Notes:**
- `container: "raw"` is required for real-time streaming
- `sample_rate: 16000` is standard for voice agents
- Voice ID must be valid in your Cartesia account
- Model `sonic-3` is recommended for best quality

## RTC Token Generation

### Using agora-token Package

```javascript
const { RtcTokenBuilder, RtcRole } = require('agora-token');

const token = RtcTokenBuilder.buildTokenWithUid(
  appId,                    // Agora App ID
  appCertificate,           // Agora App Certificate
  channelName,              // Channel name
  uid,                      // User ID (1002 for user)
  RtcRole.PUBLISHER,        // Role (PUBLISHER for voice agent)
  privilegeExpiredTs        // Expiration timestamp (current + 3600)
);
```

### Token Properties

- **Expiration**: 1 hour (3600 seconds)
- **Role**: PUBLISHER (allows both sending and receiving)
- **UID**: 1002 (user), 0 (agent)
- **Channel**: Unique per session

## Channel Configuration

```json
{
  "channel": "voice_agent_1768039103046",
  "agent_rtc_uid": "0",
  "remote_rtc_uids": ["1002"],
  "enable_string_uid": false,
  "idle_timeout": 120
}
```

**Parameters:**
- `channel`: Unique channel name per session
- `agent_rtc_uid`: "0" (agent always uses UID 0)
- `remote_rtc_uids`: Array of user UIDs (["1002"] for single user)
- `enable_string_uid`: false (use numeric UIDs)
- `idle_timeout`: 120 seconds (agent stops if no activity)

## Response Format

### Success Response

```json
{
  "agent_id": "agent_1768039103046_abc123",
  "status": "RUNNING",
  "create_ts": 1768039103046
}
```

### Error Response

```json
{
  "code": 400,
  "message": "Invalid request parameters",
  "details": "..."
}
```

## Common Error Codes

| Code | Message | Solution |
|------|---------|----------|
| 400 | Invalid request parameters | Check JSON structure and required fields |
| 401 | Unauthorized | Verify Basic Auth credentials |
| 403 | Forbidden | Check App ID and permissions |
| 404 | Not found | Verify endpoint URL and App ID |
| 429 | Rate limited | Wait before retrying |
| 500 | Server error | Retry or contact Agora support |

## Validation Checklist

Before starting an agent, verify:

- [ ] `appId` is valid and matches credentials
- [ ] `customerId` and `customerSecret` are correct
- [ ] `channelName` is unique per session
- [ ] `rtcToken` is valid and not expired
- [ ] `geminiApiKey` is valid
- [ ] `geminiModel` is supported (gemini-2.0-flash recommended)
- [ ] `cartesiaApiKey` is valid
- [ ] `cartesiaVoiceId` exists in your account
- [ ] `system_messages` uses `parts` array format
- [ ] `asr.language` is supported
- [ ] `tts.output_format.sample_rate` is 16000

## Testing the API Directly

### Using curl

```bash
# Get credentials
curl http://10.10.180.11:3000/api/config/credentials

# Generate token
curl -X POST http://10.10.180.11:3000/api/rtc-token \
  -H "Content-Type: application/json" \
  -d '{"channelName":"test_channel","uid":1002}'

# Start agent (requires valid credentials)
curl -X POST https://api.agora.io/api/conversational-ai-agent/v2/projects/{appId}/join \
  -H "Authorization: Basic $(echo -n 'customerId:customerSecret' | base64)" \
  -H "Content-Type: application/json" \
  -d @agent_payload.json
```

## Implementation in Code

### Dart (Flutter)

```dart
final payload = {
  'name': 'voice_agent_${DateTime.now().millisecondsSinceEpoch}',
  'properties': {
    'channel': channelName,
    'token': rtcToken,
    'agent_rtc_uid': '0',
    'remote_rtc_uids': ['1002'],
    'enable_string_uid': false,
    'idle_timeout': 120,
    'llm': {
      'url': 'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:streamGenerateContent?alt=sse&key=$_geminiApiKey',
      'system_messages': [
        {
          'parts': [
            {'text': systemMessage},
          ],
          'role': 'user',
        },
      ],
      'max_history': 32,
      'greeting_message': greetingMessage,
      'failure_message': 'Hold on a second. I did not understand that.',
      'params': {'model': _geminiModel},
      'style': 'gemini',
    },
    'asr': {'language': 'en-US'},
    'tts': {
      'vendor': 'cartesia',
      'params': {
        'api_key': _cartesiaApiKey,
        'model_id': _cartesiaModelId,
        'voice': {'mode': 'id', 'id': _cartesiaVoiceId},
        'output_format': {'container': 'raw', 'sample_rate': 16000},
        'language': 'en',
      },
    },
  },
};
```

## References

- [Agora Conversational AI Documentation](https://docs.agora.io/en/conversational-ai/overview)
- [Gemini API Documentation](https://ai.google.dev/docs)
- [Cartesia TTS Documentation](https://docs.cartesia.ai)
- [Agora Token Builder](https://github.com/AgoraIO/Tools/tree/master/DynamicKey/AgoraDynamicKey/nodejs)

---

**Last Updated**: January 10, 2026  
**Status**: Verified against Agora documentation
