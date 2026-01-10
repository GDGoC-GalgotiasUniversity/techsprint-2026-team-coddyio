# Quick Test Guide - Voice Agent

## 1. Start the Server

```bash
cd server
npm install  # if not already done
npm start
```

Expected output:
```
Server running on port 3000
Accepting connections from all network interfaces
MongoDB connected
```

## 2. Verify Credentials Endpoint

```bash
curl http://10.10.180.11:3000/api/config/credentials
```

Expected response:
```json
{
  "success": true,
  "credentials": {
    "gemini": {
      "apiKey": "AIzaSy...",
      "model": "gemini-2.0-flash"
    },
    "agora": {
      "appId": "6f0e339f...",
      "customerId": "c97ad182...",
      "customerSecret": "984b8786..."
    },
    "cartesia": {
      "apiKey": "sk_car_...",
      "modelId": "sonic-3",
      "voiceId": "95d51f79..."
    }
  }
}
```

## 3. Test RTC Token Generation

```bash
curl -X POST http://10.10.180.11:3000/api/rtc-token \
  -H "Content-Type: application/json" \
  -d '{"channelName":"test_channel","uid":1002}'
```

Expected response:
```json
{
  "success": true,
  "token": "006...",
  "channelName": "test_channel",
  "uid": 1002,
  "expiresIn": 3600
}
```

## 4. Run Flutter App

```bash
cd mobile
flutter run
```

## 5. Test Voice Agent

1. **Permission Dialog**
   - App should show "Microphone Permission Required" dialog
   - Tap "Grant Permission"
   - Device should show system permission prompt
   - Grant microphone access

2. **Start Session**
   - Tap "Start Session" button
   - Watch status messages:
     - "Checking permissions..."
     - "Initializing Agora..."
     - "Generating RTC token..."
     - "Joining channel..."
     - "Starting AI agent..."
     - "Voice session active - Speak now!"

3. **Speak to Agent**
   - Say: "What's the current temperature?"
   - Agent should respond with current sensor data
   - Try: "Should I water my plants?"
   - Agent should give recommendations based on soil moisture

4. **Stop Session**
   - Tap "Stop Session" button
   - Status should return to "Ready to start voice session"

## 6. Monitor Logs

### Server Logs
```
[2026-01-10T15:23:51.842Z] POST /api/ingest from 192.168.x.x
[2026-01-10T15:23:52.123Z] POST /api/rtc-token
[2026-01-10T15:23:53.456Z] GET /api/config/credentials
```

### Flutter Logs (in IDE)
```
[AgoraRTC] Valid App ID fetched from server: 6f0e339f...
[AgoraRTC] Agora RTC Engine initialized (Demo: false)
[AgoraConversationalAI] Credentials fetched successfully
[AgoraConversationalAI] Starting Agora Conversational AI agent
[AgoraConversationalAI] Agent started successfully: agent_id_xxx
```

## 7. Troubleshooting

### "Demo Mode" Message
- Check `server/.env` has all credentials
- Verify credentials are not placeholder values
- Restart server after updating `.env`

### "Failed to generate token"
- Verify server is running
- Check IP address in `ApiService.baseUrl`
- Verify `AGORA_APP_CERTIFICATE` in `.env`

### "Agent failed to start"
- Check Agora API response in Flutter logs
- Verify Gemini API key is valid
- Verify Cartesia API key and voice ID are valid

### No Audio from Agent
- Check device volume is not muted
- Verify microphone permission is granted
- Check Cartesia TTS configuration in `.env`

### "Microphone permission denied"
- Go to device Settings → Apps → [App Name] → Permissions
- Enable Microphone permission
- Restart app

## 8. Test Sensor Data Integration

1. Ensure NodeMCU is sending data
2. Check latest reading: `curl http://10.10.180.11:3000/api/latest`
3. In voice agent, ask: "What's the current humidity?"
4. Agent should respond with current sensor data

## 9. Performance Metrics

- **Token Generation**: < 100ms
- **Channel Join**: < 2 seconds
- **Agent Start**: < 3 seconds
- **First Response**: < 5 seconds
- **Subsequent Responses**: < 2 seconds

## 10. Success Criteria

✅ All of the following should work:
- [ ] Permission dialog appears and works
- [ ] RTC token generated successfully
- [ ] Agent joins channel
- [ ] Agent greets user
- [ ] User can speak and agent responds
- [ ] Responses include sensor context
- [ ] Session can be stopped cleanly
- [ ] No crashes or unhandled errors

---

**Ready to test!** Follow these steps in order for best results.
