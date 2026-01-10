# Firebase Setup Complete ✅

## Your Firebase Project

- **Project ID**: `groot-7d03b`
- **Project Number**: `320654510322`
- **Console**: https://console.firebase.google.com/project/groot-7d03b

---

## What's Already Done

### ✅ Mobile App Configuration
- `mobile/android/app/google-services.json` - **Placed automatically**
- `mobile/pubspec.yaml` - Firebase packages added
- `mobile/lib/main.dart` - FCM initialization added
- `mobile/lib/services/notification_service.dart` - Created
- `mobile/lib/services/threshold_service.dart` - Created

### ✅ Server Configuration
- `server/.env` - Updated with Firebase project details
- `server/fcm-service.js` - Firebase Admin SDK integration
- `server/server.js` - FCM endpoints added
- `server/package.json` - firebase-admin dependency added

### ✅ Security
- `.gitignore` - firebase-service-account.json protected

---

## What You Need to Do (5 minutes)

### Step 1: Download Service Account Key

1. Go to https://console.firebase.google.com/project/groot-7d03b
2. Click **⚙️ Project Settings** (gear icon, top left)
3. Go to **Service Accounts** tab
4. Click **Generate New Private Key** button
5. JSON file downloads automatically

### Step 2: Save the File

Save the downloaded JSON as:
```
server/firebase-service-account.json
```

### Step 3: Install Dependencies

```bash
npm install --prefix server
```

### Step 4: Start Server

```bash
npm start --prefix server
```

You should see:
```
✅ Firebase Admin SDK initialized
```

### Step 5: Run Mobile App

```bash
flutter run
```

---

## Testing

### Automatic Testing

1. Open home screen
2. Wait for sensor data (3-second updates)
3. When threshold crossed, notification appears

### Manual Testing

```bash
# Get FCM token from mobile app logs, then:

curl -X POST http://localhost:3000/api/test-notification \
  -H "Content-Type: application/json" \
  -d '{"token":"your_fcm_token_here"}'
```

---

## Alert Examples

### Soil Moisture Alert
```
🚨 Urgent: Water Your Plant NOW
Soil moisture is critically low at 15%. Your plant needs water immediately!
```

### Temperature Alert
```
⚠️ Temperature Too High
Temperature is high at 38°C. Heat stress risk. Provide shade or water.
```

### Humidity Alert
```
🚨 Fungal Disease Risk!
Humidity is critically high at 92%. Severe fungal disease risk! Improve ventilation.
```

---

## File Structure

```
server/
├── .env                              ✅ Updated with Firebase config
├── firebase-service-account.json     ⏳ You need to download this
├── fcm-service.js                    ✅ Created
├── server.js                         ✅ Updated with FCM endpoints
└── package.json                      ✅ Updated with firebase-admin

mobile/
├── android/app/
│   └── google-services.json          ✅ Placed automatically
├── lib/
│   ├── main.dart                     ✅ FCM initialization added
│   ├── screens/
│   │   └── home_screen.dart          ✅ Threshold checking added
│   └── services/
│       ├── notification_service.dart ✅ Created
│       ├── threshold_service.dart    ✅ Created
│       └── api_service.dart          ✅ FCM token registration added
└── pubspec.yaml                      ✅ Firebase packages added
```

---

## Configuration Summary

### .env (server/.env)
```env
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
FIREBASE_DATABASE_URL=https://groot-7d03b.firebaseio.com
FIREBASE_PROJECT_ID=groot-7d03b
FIREBASE_API_KEY=AIzaSyCn3eSz8v77Knm_gu95es9cGW-KSNdH9K0
```

### google-services.json (mobile/android/app/)
```json
{
  "project_info": {
    "project_number": "320654510322",
    "project_id": "groot-7d03b",
    "storage_bucket": "groot-7d03b.firebasestorage.app"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:320654510322:android:b5d2cb6e80723aba64a86b",
        "android_client_info": {
          "package_name": "com.example.mobile"
        }
      },
      "api_key": [
        {
          "current_key": "AIzaSyCn3eSz8v77Knm_gu95es9cGW-KSNdH9K0"
        }
      ]
    }
  ]
}
```

---

## Alert Thresholds

| Sensor | Critical Low | Warning Low | Warning High | Critical High |
|--------|--------------|-------------|--------------|---------------|
| **Soil %** | < 20% | < 30% | > 80% | > 90% |
| **Temp °C** | < 5°C | < 10°C | > 35°C | > 40°C |
| **Humidity %** | < 20% | < 30% | > 80% | > 95% |

---

## Notification Cooldown

- Same alert won't repeat within **30 minutes**
- Prevents notification spam
- Can be customized in `threshold_service.dart`

---

## API Endpoints

### Register FCM Token
```
POST /api/fcm-token
Body: { "token": "device_fcm_token" }
```

### Send Test Notification
```
POST /api/test-notification
Body: { "token": "device_fcm_token" }
```

### Send Alert
```
POST /api/send-alert
Body: {
  "token": "device_fcm_token",
  "alertType": "SOIL_CRITICAL_LOW",
  "sensorValue": 15,
  "unit": "%",
  "plantName": "Tomato"
}
```

### Get All Tokens (Admin)
```
GET /api/fcm-tokens
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Firebase not initialized" | Check FIREBASE_SERVICE_ACCOUNT_PATH in .env, verify JSON file exists |
| "Cannot find module 'firebase-admin'" | Run `npm install --prefix server` |
| "Notifications not received" | Check app permissions, verify FCM token registered, check server logs |
| "Duplicate notifications" | Wait 30 minutes or reset cooldown in app settings |

---

## Security Checklist

- ✅ `firebase-service-account.json` in `.gitignore`
- ✅ Never commit the JSON file
- ✅ Keep `FIREBASE_SERVICE_ACCOUNT_PATH` secret
- ✅ Use HTTPS in production
- ✅ Validate all inputs on backend

---

## Quick Commands

```bash
# Install dependencies
npm install --prefix server

# Start server
npm start --prefix server

# Run mobile app
flutter run

# Test notification
curl -X POST http://localhost:3000/api/test-notification \
  -H "Content-Type: application/json" \
  -d '{"token":"your_fcm_token"}'

# Get all registered tokens
curl http://localhost:3000/api/fcm-tokens
```

---

## Next Steps

1. **Download Service Account JSON** (5 min)
   - Go to Firebase Console
   - Project Settings → Service Accounts
   - Generate New Private Key
   - Save as: `server/firebase-service-account.json`

2. **Install Dependencies** (2 min)
   ```bash
   npm install --prefix server
   ```

3. **Start Server** (1 min)
   ```bash
   npm start --prefix server
   ```

4. **Run Mobile App** (1 min)
   ```bash
   flutter run
   ```

5. **Test Notifications** (ongoing)
   - Wait for sensor data
   - When threshold crossed, notification appears

**Total setup time: ~10 minutes**

---

## Features

✅ **Real-time Monitoring**
- Checks thresholds every 3 seconds
- Immediate alerts when action needed

✅ **Smart Notifications**
- 🚨 Critical alerts (urgent)
- ⚠️ Warning alerts (soon)
- Plant-specific context

✅ **Spam Prevention**
- 30-minute cooldown between same alerts
- Prevents notification fatigue

✅ **Works Offline**
- Local notifications even without Firebase
- Demo mode available

✅ **Plant-Aware**
- Includes plant name in alerts
- Sensor values and units displayed
- Actionable recommendations

---

## Support

For issues:
1. Check server logs: `npm start --prefix server`
2. Check mobile logs: `flutter run`
3. Verify Firebase project settings
4. Review this guide
5. Check network connectivity

---

## Summary

Firebase is now configured for project **groot-7d03b**. 

**What's left:**
1. Download service account JSON
2. Save to `server/firebase-service-account.json`
3. Run `npm install --prefix server`
4. Start server and mobile app
5. Test notifications

**Estimated time: 10 minutes**

You're almost there! 🚀
