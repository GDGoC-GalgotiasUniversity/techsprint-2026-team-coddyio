# Firebase Final Setup - Ready to Go! 🚀

## Current Status

✅ **Mobile App**: Fully configured
- google-services.json placed in `mobile/android/app/`
- FCM packages added to pubspec.yaml
- Notification service created
- Threshold checking implemented
- Home screen updated to check thresholds

✅ **Server**: Fully configured
- FCM service created
- Endpoints added
- .env updated with Firebase project details
- firebase-admin dependency added

⏳ **Pending**: Firebase Service Account JSON
- You have the private key ID
- Need to download complete JSON from Firebase Console

---

## What You Have

### Private Key ID
```
Re31yk-j54xcLaqj3SB-tN3z2qn2e-Ewod_vu3YPB-w
```

### Project Details
- **Project ID**: `groot-7d03b`
- **Project Number**: `320654510322`
- **API Key**: `AIzaSyCn3eSz8v77Knm_gu95es9cGW-KSNdH9K0`

---

## What You Need to Do (5 minutes)

### Step 1: Download Service Account JSON

1. Go to https://console.firebase.google.com/project/groot-7d03b
2. Click **⚙️ Project Settings** (gear icon)
3. Go to **Service Accounts** tab
4. Click **Generate New Private Key**
5. JSON file downloads automatically

### Step 2: Update Server File

1. Open the downloaded JSON file
2. Copy all content
3. Paste into: `server/firebase-service-account.json`
4. Save file

### Step 3: Verify File

Check that `server/firebase-service-account.json` contains:
```json
{
  "type": "service_account",
  "project_id": "groot-7d03b",
  "private_key_id": "Re31yk-j54xcLaqj3SB-tN3z2qn2e-Ewod_vu3YPB-w",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...",
  "client_email": "firebase-adminsdk-...@groot-7d03b.iam.gserviceaccount.com",
  "client_id": "320654510322",
  ...
}
```

### Step 4: Install Dependencies

```bash
npm install --prefix server
```

### Step 5: Start Server

```bash
npm start --prefix server
```

Expected output:
```
✅ Firebase Admin SDK initialized
✅ MongoDB connected
🚀 Server running on port 3000
📬 FCM Notification API available at /api/fcm-token
```

### Step 6: Run Mobile App

```bash
flutter run
```

---

## How It Works

### Notification Flow

```
Sensor Data (every 3 seconds)
    ↓
Check Thresholds
    ↓
Alert Generated?
    ↓
Send FCM Notification
    ↓
Firebase Cloud Messaging
    ↓
Mobile App Receives
    ↓
Display Local Notification
    ↓
User Sees Alert
```

### Example Alert

**Trigger**: Soil moisture drops to 15%

**Notification**:
```
🚨 Urgent: Water Your Plant NOW
Soil moisture is critically low at 15%. Your plant needs water immediately!
```

---

## Alert Types

### Soil Moisture
- 🚨 **Critical Low** (< 20%): "Water your plant NOW"
- ⚠️ **Warning Low** (< 30%): "Water soon"
- ⚠️ **Warning High** (> 80%): "Soil too wet"
- 🚨 **Critical High** (> 90%): "Drain excess water"

### Temperature
- 🚨 **Critical Low** (< 5°C): "Frost risk!"
- ⚠️ **Warning Low** (< 10°C): "Cold stress"
- ⚠️ **Warning High** (> 35°C): "Heat stress"
- 🚨 **Critical High** (> 40°C): "Critical heat!"

### Humidity
- 🚨 **Critical Low** (< 20%): "Severe drought stress"
- ⚠️ **Warning Low** (< 30%): "Low humidity"
- ⚠️ **Warning High** (> 80%): "Fungal disease risk"
- 🚨 **Critical High** (> 95%): "Severe fungal risk!"

---

## Testing

### Automatic Testing

1. Open home screen
2. Wait for sensor data (updates every 3 seconds)
3. When threshold crossed, notification appears

### Manual Testing

```bash
# Get FCM token from mobile app logs, then:

# Test notification
curl -X POST http://localhost:3000/api/test-notification \
  -H "Content-Type: application/json" \
  -d '{"token":"your_fcm_token_here"}'

# Send alert
curl -X POST http://localhost:3000/api/send-alert \
  -H "Content-Type: application/json" \
  -d '{
    "token":"your_fcm_token_here",
    "alertType":"SOIL_CRITICAL_LOW",
    "sensorValue":15,
    "unit":"%",
    "plantName":"Tomato"
  }'

# Get all registered tokens
curl http://localhost:3000/api/fcm-tokens
```

---

## File Structure

```
server/
├── .env                              ✅ Updated
├── firebase-service-account.json     ⏳ Download & update
├── fcm-service.js                    ✅ Created
├── server.js                         ✅ Updated
└── package.json                      ✅ Updated

mobile/
├── android/app/
│   ├── google-services.json          ✅ Placed
│   └── build.gradle.kts              ✅ Updated
├── lib/
│   ├── main.dart                     ✅ Updated
│   ├── screens/
│   │   └── home_screen.dart          ✅ Updated
│   └── services/
│       ├── notification_service.dart ✅ Created
│       ├── threshold_service.dart    ✅ Created
│       └── api_service.dart          ✅ Updated
└── pubspec.yaml                      ✅ Updated
```

---

## Configuration

### server/.env
```env
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
FIREBASE_DATABASE_URL=https://groot-7d03b.firebaseio.com
FIREBASE_PROJECT_ID=groot-7d03b
FIREBASE_API_KEY=AIzaSyCn3eSz8v77Knm_gu95es9cGW-KSNdH9K0
```

### mobile/android/app/google-services.json
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

## Customization

### Change Thresholds

Edit `mobile/lib/services/threshold_service.dart`:

```dart
class SensorThresholds {
  static const double SOIL_CRITICAL_LOW = 20;    // Change this
  static const double SOIL_WARNING_LOW = 30;     // Or this
  static const double TEMP_CRITICAL_LOW = 5;
  static const double TEMP_WARNING_LOW = 10;
  static const double HUMIDITY_CRITICAL_LOW = 20;
  static const double HUMIDITY_WARNING_LOW = 30;
}
```

### Change Cooldown

Edit `mobile/lib/services/threshold_service.dart`:

```dart
static const int NOTIFICATION_COOLDOWN_MINUTES = 30;  // Change to 60
```

### Customize Messages

Edit `server/fcm-service.js`:

```javascript
const alerts = {
  SOIL_CRITICAL_LOW: {
    title: '🚨 Urgent: Water Your Plant NOW',  // Customize
    body: `Soil moisture is critically low...`,
  },
};
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Firebase not initialized" | Check JSON file is valid and complete |
| "Cannot find module 'firebase-admin'" | Run `npm install --prefix server` |
| "Notifications not received" | Check app permissions, verify FCM token |
| "Duplicate notifications" | Wait 30 minutes or reset cooldown |

---

## Security

✅ **Protected**:
- `firebase-service-account.json` in `.gitignore`
- Never committed to git
- Private key kept secret

⚠️ **Remember**:
- Don't share the JSON file
- Don't paste in chat or emails
- Use HTTPS in production
- Validate all inputs

---

## Quick Commands

```bash
# Install dependencies
npm install --prefix server

# Start server
npm start --prefix server

# Run mobile app
flutter run

# Check server logs
npm start --prefix server

# Test notification
curl -X POST http://localhost:3000/api/test-notification \
  -H "Content-Type: application/json" \
  -d '{"token":"your_fcm_token"}'
```

---

## Summary

### What's Done ✅
- Mobile app fully configured
- Server fully configured
- Notification service created
- Threshold checking implemented
- All code compiles without errors

### What's Left ⏳
1. Download service account JSON (2 min)
2. Update `server/firebase-service-account.json` (1 min)
3. Run `npm install --prefix server` (2 min)
4. Start server and app (2 min)
5. Test notifications (1 min)

**Total time: ~10 minutes**

---

## Next Steps

1. **Download JSON** from Firebase Console
2. **Update File** `server/firebase-service-account.json`
3. **Install** `npm install --prefix server`
4. **Start** `npm start --prefix server`
5. **Run** `flutter run`
6. **Test** Send notification

You're almost there! 🚀
