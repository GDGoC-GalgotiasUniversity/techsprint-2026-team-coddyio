# KisanGuide - Quick Start Guide

## 🚀 Start the System (2 Steps)

### Step 1: Start Server
```bash
npm start --prefix server
```

You should see:
```
🚀 Server running on port 3000
✅ MongoDB connected
```

### Step 2: Start Mobile App
```bash
flutter run
```

**That's it! System is running.**

---

## 📱 Using the Mobile App

### Home Screen
1. Select "Yes, I have a plant" or "No, I don't have a plant"
2. If yes, enter plant name (e.g., "Tomato", "Rose")
3. Status saves automatically

### AI Chat
- Tap "Chat with AI"
- Ask questions about your plant
- AI responds with plant-specific advice

### Voice Agent
- Tap "Voice Agent"
- Tap "Start Session"
- Speak to the AI
- AI responds with voice

### Plant Disease Detection
- Tap "Disease Detection"
- Take photo or upload from gallery
- AI identifies disease
- Shows home remedies

---

## 🔔 Alerts

System checks every 3 seconds for:
- **Soil too dry** → "Water Your Plant NOW"
- **Soil too wet** → "Drain Excess Water"
- **Temperature too low** → "Frost Risk!"
- **Temperature too high** → "Critical Heat!"
- **Humidity too low** → "Severe Drought Stress"
- **Humidity too high** → "Fungal Disease Risk!"

Alerts appear in console (and as push notifications if Firebase configured).

---

## 🔧 Optional: Enable Firebase Push Notifications

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project "groot-7d03b"
3. Project Settings → Service Accounts
4. Click "Generate New Private Key"
5. Save JSON to `server/firebase-service-account.json`
6. Restart server: `npm start --prefix server`

See `FIREBASE_SERVICE_ACCOUNT_SETUP_COMPLETE.md` for details.

---

## 🔌 Optional: Connect NodeMCU Sensor

1. Open `nodemcu/sensor_code.ino` in Arduino IDE
2. Update WiFi SSID and password
3. Update server URL: `http://YOUR_SERVER_IP:3000/api/ingest`
4. Upload to NodeMCU
5. Sensor data flows to server automatically

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Server won't start | Kill process on port 3000, restart |
| App can't connect | Make sure server is running |
| No alerts | Check MongoDB is running |
| Voice agent not speaking | Check microphone permissions |
| Disease detection fails | Check image upload is working |

---

## 📊 API Endpoints

| Endpoint | Purpose |
|----------|---------|
| `POST /api/ingest` | Receive sensor data |
| `GET /api/sensor-data` | Get latest readings |
| `GET /api/plant-status` | Get plant status |
| `POST /api/plant-status` | Update plant status |
| `POST /api/plant-disease/detect` | Detect disease |
| `POST /api/fcm-token` | Register for notifications |

---

## 📁 Key Files

| File | Purpose |
|------|---------|
| `server/server.js` | Main server |
| `server/.env` | Configuration |
| `mobile/lib/main.dart` | App entry point |
| `mobile/lib/screens/home_screen.dart` | Home screen |
| `nodemcu/sensor_code.ino` | Sensor firmware |

---

## ✨ Features

✅ Real-time sensor monitoring  
✅ AI chatbot with plant context  
✅ Voice conversations with AI  
✅ Plant disease detection  
✅ Automatic alerts  
✅ Push notifications (optional)  
✅ Home remedy recommendations  

---

## 🎯 Next Steps

1. Start server and mobile app
2. Set plant status and name
3. Try chatbot and voice agent
4. Test disease detection
5. (Optional) Enable Firebase notifications
6. (Optional) Connect NodeMCU sensor

---

## 📞 Support

Check these files for detailed help:
- `SYSTEM_STATUS_COMPLETE.md` - Full system overview
- `FIREBASE_SERVICE_ACCOUNT_SETUP_COMPLETE.md` - Firebase setup
- `TROUBLESHOOTING_GUIDE.md` - Common issues

---

**System is ready! Start the server and run the app.** 🌱

