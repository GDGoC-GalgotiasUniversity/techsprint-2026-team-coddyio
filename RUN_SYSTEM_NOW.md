# Run KisanGuide System Now

## ✅ System Status
- ✅ Server running on port 3000
- ✅ MongoDB connected
- ✅ All APIs available
- ✅ Ready for mobile app

---

## 🚀 Quick Start (Copy & Paste)

### Terminal 1: Start Server
```bash
npm start --prefix server
```

Expected output:
```
⚠️ Firebase initialization failed: Failed to parse private key...
   FCM notifications will not be sent
   App will continue to work without push notifications
🚀 Server running on port 3000
📍 Accepting connections from all network interfaces
🌱 Plant Disease Detection API available at /api/plant-disease/detect
📬 FCM Notification API available at /api/fcm-token
✅ MongoDB connected
```

### Terminal 2: Start Mobile App
```bash
flutter run
```

---

## 📱 Using the App

### Step 1: Home Screen
- Select "Yes, I have a plant" or "No"
- If yes, enter plant name (e.g., "Tomato")
- Status saves automatically

### Step 2: Try Features
- **Chat**: Tap "Chat with AI" → Ask about your plant
- **Voice**: Tap "Voice Agent" → Start Session → Speak
- **Disease**: Tap "Disease Detection" → Take photo
- **Alerts**: Check console for threshold alerts

---

## 🔔 What to Expect

### Alerts (Every 3 Seconds)
When sensor data crosses thresholds:
- 🚨 "Water Your Plant NOW" (soil < 20%)
- ⚠️ "Soil Too Wet" (soil > 80%)
- 🚨 "Frost Risk!" (temp < 5°C)
- ⚠️ "Temperature Too High" (temp > 35°C)
- 🚨 "Severe Drought Stress" (humidity < 20%)
- ⚠️ "High Humidity" (humidity > 80%)

### Console Output
```
🔔 Alert: 🚨 Urgent: Water Your Plant NOW
   Plant: Tomato
   Soil Moisture: 15%
   Temperature: 28°C
   Humidity: 65%
```

---

## 🎯 Test Each Feature

### 1. Test Chatbot
```
User: "My tomato plant looks yellow"
AI: "Yellow leaves on tomato can indicate nitrogen deficiency. 
     Try adding compost or diluted fertilizer..."
```

### 2. Test Voice Agent
```
User: "How often should I water my plant?"
AI: "For tomato plants, water when soil is dry 1-2 inches deep.
     That's usually every 2-3 days in warm weather..."
```

### 3. Test Disease Detection
```
1. Tap "Disease Detection"
2. Take photo of plant leaf
3. AI identifies disease
4. Shows home remedies
```

### 4. Test Alerts
```
1. Check console for alerts
2. Alerts appear every 3 seconds when thresholds crossed
3. Shows plant name and sensor values
```

---

## 🔧 Optional: Enable Firebase Notifications

If you want push notifications on device:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project "groot-7d03b"
3. Project Settings → Service Accounts
4. Click "Generate New Private Key"
5. Save JSON to `server/firebase-service-account.json`
6. Restart server: `npm start --prefix server`

See `FIREBASE_SERVICE_ACCOUNT_SETUP_COMPLETE.md` for details.

---

## 🔌 Optional: Connect NodeMCU Sensor

To send real sensor data:

1. Open `nodemcu/sensor_code.ino` in Arduino IDE
2. Update WiFi SSID and password
3. Update server URL: `http://YOUR_SERVER_IP:3000/api/ingest`
4. Upload to NodeMCU
5. Sensor data flows to server automatically

---

## 📊 API Endpoints (For Testing)

### Get Latest Sensor Data
```bash
curl http://localhost:3000/api/sensor-data
```

### Get Plant Status
```bash
curl http://localhost:3000/api/plant-status
```

### Update Plant Status
```bash
curl -X POST http://localhost:3000/api/plant-status \
  -H "Content-Type: application/json" \
  -d '{"hasPlant": true, "plantType": "Tomato"}'
```

### Test Notification
```bash
curl http://localhost:3000/api/test-notification
```

---

## 🐛 If Something Goes Wrong

### Server won't start
```bash
# Kill process on port 3000
Get-Process -Id (Get-NetTCPConnection -LocalPort 3000).OwningProcess | Stop-Process -Force

# Restart
npm start --prefix server
```

### App can't connect to server
- Make sure server is running
- Check server IP address
- Verify port 3000 is open

### No alerts appearing
- Check MongoDB is running
- Verify sensor data is being received
- Check console for errors

### Voice agent not speaking
- Check microphone permissions
- Verify Agora credentials in `.env`
- Check server logs

---

## 📚 Documentation

- `QUICK_START_GUIDE.md` - Quick reference
- `SYSTEM_STATUS_COMPLETE.md` - Full overview
- `FIREBASE_SERVICE_ACCOUNT_SETUP_COMPLETE.md` - Firebase setup
- `TROUBLESHOOTING_GUIDE.md` - Common issues

---

## ✨ System Features

✅ Real-time sensor monitoring  
✅ AI chatbot with plant context  
✅ Voice conversations with AI  
✅ Plant disease detection  
✅ Automatic alerts  
✅ Push notifications (optional)  
✅ Home remedy recommendations  

---

## 🎉 Ready!

**Server is running. Start the mobile app and begin using KisanGuide!**

```bash
flutter run
```

Enjoy! 🌱

