# Critical Agora Fixes Applied

## Summary
The Agora Conversational AI integration has been fixed by applying exact parameters from the working Mensa-WIEEE project.

## 4 Critical Issues Fixed

### 1. ❌ Agent UID was "0" → ✅ Changed to "999"
**Why it matters**: UID 0 is reserved for system use. Agents must use UID 999.

```javascript
// BEFORE (WRONG)
"agent_rtc_uid": "0"

// AFTER (CORRECT)
"agent_rtc_uid": "999"
```

### 2. ❌ Remote UIDs limited to ["1002"] → ✅ Changed to ["*"]
**Why it matters**: Agent needs to hear ALL users in channel, not just one.

```javascript
// BEFORE (WRONG)
"remote_rtc_uids": ["1002"]

// AFTER (CORRECT)
"remote_rtc_uids": ["*"]
```

### 3. ❌ ASR vendor not specified → ✅ Explicitly set to "ares"
**Why it matters**: Agora Ares is the built-in STT. Must be explicit.

```javascript
// BEFORE (WRONG)
"asr": {"language": "en-US"}

// AFTER (CORRECT)
"asr": {
  "vendor": "ares",
  "language": "en-US"
}
```

### 4. ❌ Regular RTC tokens for agent → ✅ Use RTM2 tokens
**Why it matters**: Conversational AI requires RTM2 privileges for proper communication.

```javascript
// BEFORE (WRONG)
const token = RtcTokenBuilder.buildTokenWithUid(...)

// AFTER (CORRECT)
const token = RtcTokenBuilder.buildTokenWithRtm2(...)
```

## Server Endpoints Added

### Start Agent
```
POST /api/agora-ai/start-agent
Body: {
  "channelName": "voice_agent_1234567890",
  "agentName": "agricultural_assistant",
  "systemMessages": null  // optional
}
```

### Stop Agent
```
POST /api/agora-ai/stop-agent
Body: {
  "agentId": "agent_1234567890_abc123"
}
```

### Agent Status
```
GET /api/agora-ai/agent-status/:agentId
```

## Exact Agora Payload Structure

```json
{
  "name": "voice_agent_1768039103046",
  "properties": {
    "channel": "voice_agent_1768039103046",
    "token": "006...",
    "agent_rtc_uid": "999",
    "remote_rtc_uids": ["*"],
    "idle_timeout": 120,
    "asr": {
      "vendor": "ares",
      "language": "en-US"
    },
    "tts": {
      "vendor": "cartesia",
      "params": {
        "api_key": "sk_car_...",
        "model_id": "sonic-2",
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
    },
    "llm": {
      "url": "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:streamGenerateContent?alt=sse&key=AIzaSy...",
      "system_messages": [
        {
          "parts": [
            {"text": "You are an agricultural assistant..."}
          ],
          "role": "user"
        }
      ],
      "max_history": 32,
      "greeting_message": "Hello! I am your agricultural assistant...",
      "failure_message": "Hold on a second. I did not understand that.",
      "params": {
        "model": "gemini-2.0-flash"
      },
      "style": "gemini"
    }
  }
}
```

## What Changed in Code

### Server (`server/server.js`)
- ✅ Added `AgoraConversationalAIService` class
- ✅ Added `AgoraTokenService` class with RTM2 support
- ✅ Added 3 new endpoints for agent management
- ✅ Proper error handling and logging

### Mobile (`agora_conversational_ai_service.dart`)
- ✅ Updated `startAgent()` with correct parameters
- ✅ Changed agent UID from 0 to 999
- ✅ Changed remote UIDs from ["1002"] to ["*"]
- ✅ Added explicit ASR vendor "ares"

### Dependencies
- ✅ Added `axios` to `server/package.json`

## How to Test

### 1. Install & Start Server
```bash
cd server
npm install
npm start
```

### 2. Test Credentials
```bash
curl http://10.10.180.11:3000/api/config/credentials
```

### 3. Test Token Generation
```bash
curl -X POST http://10.10.180.11:3000/api/rtc-token \
  -H "Content-Type: application/json" \
  -d '{"channelName":"test","uid":1002}'
```

### 4. Run Flutter App
```bash
cd mobile
flutter run
```

### 5. Start Voice Session
- Tap "Start Session"
- Wait for "Voice session active - Speak now!"
- Speak to agent
- Agent responds with voice

## Expected Logs

### Server
```
🤖 Starting Agora Conversational AI agent: voice_agent_1768039103046
📋 LLM: gemini-2.0-flash
🔊 TTS: Cartesia sonic-2
🎤 ASR: Ares
✅ Agent started successfully
🔊 Agent ID: agent_1768039103046_abc123
```

### Flutter
```
[AgoraConversationalAI] ✅ Agent started successfully: agent_1768039103046_abc123
[AgoraRTC] User joined: 999
```

## Success Indicators

✅ Agent UID 999 joins channel  
✅ Agent greets user with voice  
✅ User can speak and agent responds  
✅ No errors in logs  
✅ Session can be stopped cleanly  

## Files Modified

1. `server/server.js` - Complete Agora integration
2. `server/package.json` - Added axios
3. `mobile/lib/services/agora_conversational_ai_service.dart` - Fixed parameters
4. `mobile/lib/screens/voice_agent_screen.dart` - Minor updates

---

**Status**: ✅ FIXED - Ready for testing  
**Source**: Exact parameters from Mensa-WIEEE working implementation  
**Date**: January 10, 2026
