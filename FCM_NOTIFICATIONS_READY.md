# FCM Notifications - Ready to Deploy! ✅

## Status: 95% Complete

Everything is set up and ready. You just need to add the Firebase service account JSON file.

---

## What's Implemented

### ✅ Mobile App
- Firebase Cloud Messaging integration
- Local notification display
- Real-time threshold monitoring (every 3 seconds)
- Smart alert generation
- Notification cooldown (30 minutes)
- Plant-specific context in alerts
- Works in foreground and background

### ✅ Server
- Firebase Admin SDK integration
- FCM notification endpoints
- Alert notification helpers
- Token management
- Multicast notification support
- Error handling and logging

### ✅ Configuration
- Android: google-services.json placed
- Server: .env updated with Firebase details
- Build: gradle updated with Google Services plugin
- Security: firebase-service-account.json in .gitignore

---

## Your Firebase Project

- **Project ID**: `groot-7d03b`
- **Project Number**: `320654510322`
- **Private Key ID**: `Re31yk-j54xcLaqj3SB-tN3z2qn2e-Ewod_vu3YPB-w`
- **Console**: https://console.firebase.google.com/project/groot-7d03b

---

## One Last Step (5 minutes)

### Download Service Account JSON

1. Go to Firebase Console: https://console.firebase.google.com/project/groot-7d03b
2. Click **⚙️ Project Settings** (gear icon, top left)
3. Go to **Service Accounts** tab
4. Click **Generate New Private Key** button
5. JSON file downloads automatically

### Update Server File

1. Open downloaded JSON file
2. Copy all content
3. Paste into: `server/firebase-service-account.json`
4. Save

### Start Services

```bash
# Install dependencies
npm install --prefix server

# Start server
npm start --prefix server

# In another terminal, run mobile app
flutter run
```

---

## How It Works

### Real-Time Monitoring

```
Every 3 seconds:
  1. Fetch sensor data
  2. Check thresholds
  3. If threshold crossed:
     - Generate alert
     - Check cooldown (30 min)
     - Send FCM notification
     - Display local notification
  4. User sees alert
```

### Alert Examples

**Soil Moisture Alert**
```
🚨 Urgent: Water Your Plant NOW
Soil moisture is critically low at 15%. Your plant needs water immediately!
```

**Temperature Alert**
```
⚠️ Temperature Too High
Temperature is high at 38°C. Heat stress risk. Provide shade or water.
```

**Humidity Alert**
```
🚨 Fungal Disease Risk!
Humidity is critically high at 92%. Severe fungal disease risk! Improve ventilation.
```

---

## Alert Thresholds

| Sensor | Critical Low | Warning Low | Warning High | Critical High |
|--------|--------------|-------------|--------------|---------------|
| **Soil %** | < 20% | < 30% | > 80% | > 90% |
| **Temp °C** | < 5°C | < 10°C | > 35°C | > 40°C |
| **Humidity %** | < 20% | < 30% | > 80% | > 95% |

---

## Features

✅ **Real-Time Monitoring**
- Checks every 3 seconds
- Immediate alerts when needed

✅ **Smart Notifications**
- 🚨 Critical (urgent action)
- ⚠️ Warning (action soon)
- Plant-specific context

✅ **Spam Prevention**
- 30-minute cooldown
- Same alert won't repeat

✅ **Works Offline**
- Local notifications work without Firebase
- Demo mode available

✅ **Plant-Aware**
- Includes plant name
- Shows sensor values
- Actionable recommendations

---

## API Endpoints

### Register FCM Token
```bash
POST /api/fcm-token
{
  "token": "device_fcm_token"
}
```

### Send Test Notification
```bash
POST /api/test-notification
{
  "token": "device_fcm_token"
}
```

### Send Alert
```bash
POST /api/send-alert
{
  "token": "device_fcm_token",
  "alertType": "SOIL_CRITICAL_LOW",
  "sensorValue": 15,
  "unit": "%",
  "plantName": "Tomato"
}
```

### Get All Tokens
```bash
GET /api/fcm-tokens
```

---

## Testing

### Automatic Testing
1. Open home screen
2. Wait for sensor data
3. When threshold crossed, notification appears

### Manual Testing
```bash
# Test notification
curl -X POST http://localhost:3000/api/test-notification \
  -H "Content-Type: application/json" \
  -d '{"token":"your_fcm_token"}'

# Send alert
curl -X POST http://localhost:3000/api/send-alert \
  -H "Content-Type: application/json" \
  -d '{
    "token":"your_fcm_token",
    "alertType":"SOIL_CRITICAL_LOW",
    "sensorValue":15,
    "unit":"%",
    "plantName":"Tomato"
  }'
```

---

## Files Created/Updated

### Mobile
- ✅ `mobile/lib/services/notification_service.dart` - FCM setup
- ✅ `mobile/lib/services/threshold_service.dart` - Threshold checking
- ✅ `mob