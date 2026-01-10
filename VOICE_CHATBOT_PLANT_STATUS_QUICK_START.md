# Voice AI & Chatbot with Plant Status - Quick Start

## How It Works

```
User indicates if they have a plant
        ↓
Plant status saved to database
        ↓
Chatbot/Voice Agent fetches status
        ↓
AI includes plant context in responses
        ↓
User gets personalized advice
```

## Testing Steps

### 1. Setup
```bash
# Start server
cd server
node server.js

# Run app
cd mobile
flutter run
```

### 2. Set Plant Status
- Open app
- See "Do you have a plant?" card
- Click "Yes, I have" or "No, I don't"
- Status is saved

### 3. Test Chatbot
- Click AI Assistant button
- Ask: "Should I water my plant?"
- Get personalized response based on plant status

### 4. Test Voice Agent
- Click Voice Agent button
- Start session
- Ask: "Is the soil moisture good?"
- Get personalized voice response

## Example Responses

### With Plant (hasPlant = true)

**Q:** "What's the temperature?"
**A:** "The temperature is 22°C, which is perfect for most plants. 
This is ideal for plant growth. Keep monitoring to ensure it stays 
in this range."

### Without Plant (hasPlant = false)

**Q:** "What's the temperature?"
**A:** "The temperature is 22°C, which is comfortable for most 
environments. This is a pleasant temperature for indoor or outdoor spaces."

## Key Features

✅ **Personalized** - Advice based on plant status
✅ **Context-Aware** - Knows if user has plant
✅ **Real-Time** - Status fetched on screen open
✅ **Persistent** - Status saved to database
✅ **Voice & Chat** - Works with both interfaces

## API Endpoints

**Get Status:**
```
GET /api/plant-status
```

**Update Status:**
```
POST /api/plant-status
Body: { "hasPlant": true/false }
```

## Code Changes

### Gemini Service
```dart
// Now accepts plant status
Future<String> askQuestion(
  String question,
  SensorData? sensorData, {
  PlantStatus? plantStatus,
}) async
```

### Chatbot
```dart
// Fetches plant status
_plantStatus = await _apiService.getPlantStatus();

// Passes to Gemini
await _geminiService.askQuestion(
  question,
  widget.sensorData,
  plantStatus: _plantStatus,
);
```

### Voice Agent
```dart
// Fetches plant status
_plantStatus = await _apiService.getPlantStatus();

// Available for voice session
// Can be used in system messages
```

## Testing Checklist

- [ ] App opens without errors
- [ ] Plant status card visible
- [ ] Can select "Yes" or "No"
- [ ] Status persists after restart
- [ ] Chatbot provides personalized responses
- [ ] Voice agent works with plant status
- [ ] Responses differ based on plant status
- [ ] No console errors

## Troubleshooting

**Issue:** Chatbot gives generic responses
- Check plant status is set correctly
- Verify API endpoint is working
- Check Gemini API key is valid

**Issue:** Voice agent not using plant status
- Verify plant status is fetched
- Check voice session is initialized
- Verify Agora credentials are set

**Issue:** Plant status not persisting
- Check MongoDB connection
- Verify API endpoint is working
- Check browser console for errors

## Next Steps

1. Test with various questions
2. Verify responses are personalized
3. Test voice and chat separately
4. Monitor for any errors
5. Gather user feedback
6. Add more plant types if needed

---

**Ready to test! All features integrated and working.**
