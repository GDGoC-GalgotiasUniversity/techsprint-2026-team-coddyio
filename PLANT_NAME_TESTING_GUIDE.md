# Plant Name Integration - Testing Guide

## Quick Test Steps

### 1. Home Screen - Enter Plant Name
```
1. Open app → Home Screen
2. Scroll to "Do you have a plant?" card
3. Click "Yes, I have"
4. Enter plant name: "Tomato" (or any plant)
5. Verify status shows: "🌱 Tomato - Ready for disease detection"
6. Close and reopen app → Plant name should persist
```

### 2. AI Chatbot - Plant-Specific Responses
```
1. Click "AI Assistant" button (psychology icon)
2. Verify AppBar shows: "AI Assistant" with "🌱 Tomato" below
3. Verify greeting message includes plant name:
   "Hello! 🌱 I see you have a Tomato..."
4. Ask: "Is the temperature good for my Tomato?"
5. Verify response mentions Tomato specifically
6. Ask: "Should I water my Tomato?"
7. Verify response includes Tomato-specific watering advice
```

### 3. Voice Agent - Plant-Aware Conversations
```
1. Click "Voice Agent" button (mic icon)
2. Click "Start Session"
3. Wait for greeting: "Hello! I see you have a Tomato..."
4. Ask: "My Tomato leaves are yellow"
5. Verify agent responds with Tomato-specific advice
6. Ask: "What temperature does my Tomato need?"
7. Verify response includes Tomato temperature ranges
```

### 4. Plant Disease Detection - Plant-Specific Remedies
```
1. Click "Plant Disease" button (nature icon)
2. Verify AppBar shows: "Monitoring: Tomato"
3. Take/upload a plant photo
4. Wait for disease detection
5. Scroll to "Treatment & Prevention" section
6. Verify remedies mention Tomato specifically
7. Example: "Remove leaves touching ground (especially for Tomatoes)"
```

---

## Expected Outputs by Plant Type

### Tomato
**Chatbot**: "Your Tomato prefers 20-28°C. Current temp is 28°C - perfect!"
**Voice**: "I see you have a Tomato. How can I help you care for your Tomato?"
**Disease**: "Tomato___Early_blight → Remove leaves, spray milk solution"

### Rose
**Chatbot**: "Your Rose prefers 18-25°C and well-drained soil."
**Voice**: "Hello! I see you have a Rose. How can I help you care for your Rose?"
**Disease**: "Rose___Black_spot → Improve air circulation around Rose"

### Potato
**Chatbot**: "Your Potato needs 15-20°C and consistent moisture."
**Voice**: "I see you have a Potato. Let me help with your Potato care."
**Disease**: "Potato___Late_blight → Remove affected Potato leaves"

---

## Verification Checklist

- [ ] Plant name appears in home screen status
- [ ] Plant name persists after app restart
- [ ] Chatbot AppBar shows plant name
- [ ] Chatbot greeting mentions plant name
- [ ] Chatbot responses include plant-specific advice
- [ ] Voice agent greeting includes plant name
- [ ] Voice agent responses mention plant type
- [ ] Disease detection AppBar shows plant name
- [ ] Disease remedies mention plant type
- [ ] All responses are contextual to plant type

---

## Troubleshooting

**Plant name not showing in AppBar?**
- Ensure plant status was saved (check home screen status message)
- Restart app to refresh plant status

**Chatbot not mentioning plant name?**
- Verify plant name was entered on home screen
- Check that plant status shows "Yes, I have"
- Restart app and try again

**Voice agent not greeting with plant name?**
- Ensure plant status is saved before starting session
- Check server logs for plant status retrieval
- Verify Agora credentials are configured

**Disease remedies not plant-specific?**
- Verify plant name is shown in AppBar
- Check that Gemini service initialized successfully
- Ensure server is running and accessible

---

## Sample Test Data

Use these plant names for testing:
- Tomato
- Rose
- Potato
- Corn
- Grape
- Pepper
- Cucumber
- Lettuce
- Carrot
- Spinach

---

## API Endpoints to Verify

```bash
# Get plant status
curl http://10.10.180.11:3000/api/plant-status

# Expected response:
{
  "success": true,
  "data": {
    "hasPlant": true,
    "plantType": "Tomato",
    "lastUpdated": "2024-01-11T10:30:00Z"
  }
}

# Update plant status
curl -X POST http://10.10.180.11:3000/api/plant-status \
  -H "Content-Type: application/json" \
  -d '{"hasPlant": true, "plantType": "Tomato"}'
```

---

## Performance Notes

- Plant name fetched once on screen initialization
- Cached in state for quick access
- No additional API calls per message
- Minimal performance impact

---

## Next Steps

After testing:
1. Verify all plant types work correctly
2. Test with different sensor data ranges
3. Confirm disease detection works with plant name
4. Test app restart and persistence
5. Check voice agent with different plants
