# FCM (Firebase Cloud Messaging) Setup Guide

## Overview
FCM notifications are now integrated into KisanGuide. The system will send push notifications when:
- Soil moisture is too low (needs watering)
- Soil moisture is too high (risk of root rot)
- Temperature is too high or too low
- Humidity is too high or too low

---

## Quick Start (Without Firebase - Demo Mode)

The app works in **demo mode** without Firebase configured. Local notifications will still work:

1. **Mobile App**: Notifications will display locally on the device
2. **Server**: FCM endpoints available but won't send push notifications
3. **Testing**: Use local notifications to test the system

To test without Firebase:
```bash
# Just run the server normally
npm start

# Mobile app will show local notifications when thresholds are crossed
```

---

## Full Setup (With Firebase - Production)

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a new project"
3. Enter project name: `KisanGuide`
4. Enable Google Analytics (optional)
5. Click "Create project"

### Step 2: Set Up Firebase Cloud Messaging

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Click **Cloud Messaging** tab
3. Note your **Server API Key** (you'll need this later)
4. Enable **Firebase Cloud Messaging API** in Google Cloud Console

### Step 3: Download Service Account Key

1. In Firebase Console, go to **Project Settings** → **Service Accounts**
2. Click **Generate New Private Key**
3. A JSON file will download: `firebase-service-account.json`
4. Save this file to: `server/firebase-service-account.json`
5. **IMPORTANT**: Add to `.gitignore` to keep it secret

```bash
# Add to server/.gitignore
firebase-service-account.json
```

### Step 4: Configure Environment Variables

Add to `server/.env`:

```env
# Firebase Configuration
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
FIREBASE_DATABASE_URL=https://your-project-id.firebaseio.com
```

### Step 5: Set Up Android

1. In Firebase Console, go to **Project Settings** → **General**
2. Click **Add App** → **Android**
3. Enter package name: `com.example.mobile`
4. Download `google-services.json`
5. Place in: `mobile/android/app/google-services.json`

### Step 6: Set Up iOS

1. In Firebase Console, click **Add App** → **iOS**
2. Enter bundle ID: `com.example.mobile`
3. Download `GoogleService-Info.plist`
4. Place in: `mobile/ios/Runner/GoogleService-Info.plist`
5. In Xcode, add to Runner target

### Step 7: Install Dependencies

```bash
# Server
npm install --prefix server

# Mobile (already done)
flutter pub get
```

### Step 8: Restart Services

```bash
# Terminal 1: Server
npm start --prefix server

# Terminal 2: Mobile
flutter run
```

---

## How It Works

### Notification Flow

```
NodeMCU Sensor Data
    ↓
Server /api/ingest
    ↓
Check Thresholds
    ↓
Send FCM Notification
    ↓
Firebase Cloud Messaging
    ↓
Mobile App Receives Notification
    ↓
Display Local Notification
```

### Threshold Alerts

**Soil Moisture:**
- 🚨 Critical Low (< 20%): "Water your plant NOW"
- ⚠️ Warning Low (< 30%): "Water soon"
- ⚠️ Warning High (> 80%): "Soil too wet"
- 🚨 Critical High (> 90%): "Drain excess water"

**Temperature:**
- 🚨 Critical Low (< 5°C): "Frost risk!"
- ⚠️ Warning Low (< 10°C): "Cold stress"
- ⚠️ Warning High (> 35°C): "Heat stress"
- 🚨 Critical High (> 40°C): "Critical heat!"

**Humidity:**
- 🚨 Critical Low (< 20%): "Severe drought stress"
- ⚠️ Warning Low (< 30%): "Low humidity"
- ⚠️ Warning High (> 80%): "Fungal disease risk"
- 🚨 Critical High (> 95%): "Severe fungal risk!"

### Notification Cooldown

To prevent notification spam:
- Same alert type won't repeat within 30 minutes
- Cooldown tracked in local storage
- Can be reset for testing

---

## API Endpoints

### Register FCM Token
```bash
POST /api/fcm-token
Content-Type: application/json

{
  "token": "device_fcm_token_here"
}

Response:
{
  "success": true,
  "message": "FCM token registered successfully"
}
```

### Send Test Notification
```bash
POST /api/test-notification
Content-Type: application/json

{
  "token": "device_fcm_token_here"
}

Response:
{
  "success": true,
  "message": "Test notification sent"
}
```

### Send Alert Notification
```bash
POST /api/send-alert
Content-Type: application/json

{
  "token": "device_fcm_token_here",
  "alertType": "SOIL_CRITICAL_LOW",
  "sensorValue": 15,
  "unit": "%",
  "plantName": "Tomato"
}

Response:
{
  "success": true,
  "message": "Alert notification sent"
}
```

### Get All FCM Tokens (Admin)
```bash
GET /api/fcm-tokens

Response:
{
  "success": true,
  "count": 5,
  "tokens": [
    {
      "token": "device_token_1",
      "createdAt": "2024-01-15T10:00:00Z",
      "lastUsed": "2024-01-15T10:30:00Z"
    }
  ]
}
```

---

## Testing

### Test Without Firebase (Demo Mode)

1. Run server: `npm start --prefix server`
2. Run mobile app: `flutter run`
3. Open home screen
4. Sensor data will update every 3 seconds
5. When thresholds are crossed, local notifications appear

### Test With Firebase

1. Complete Firebase setup (steps 1-8 above)
2. Run server: `npm start --prefix server`
3. Run mobile app: `flutter run`
4. Check server logs for "Firebase Admin SDK initialized"
5. Trigger threshold by:
   - Manually setting low soil moisture in database
   - Or wait for actual sensor data to cross threshold
6. Notification should appear on device

### Manual Testing

```bash
# Test notification endpoint
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
```

---

## Troubleshooting

### Firebase not initializing

**Error**: "Firebase Admin SDK not initialized"

**Solution**:
1. Check `FIREBASE_SERVICE_ACCOUNT_PATH` in `.env`
2. Verify file exists at that path
3. Check file is valid JSON
4. Restart server

### Notifications not received

**Check**:
1. FCM token registered: `GET /api/fcm-tokens`
2. Firebase project has Cloud Messaging enabled
3. Android/iOS app has notification permissions
4. Check server logs for errors

### Token not registering

**Solution**:
1. Ensure app has notification permissions
2. Check network connectivity
3. Verify server is running
4. Check browser console for errors

### Duplicate notifications

**Solution**:
1. Check notification cooldown (30 minutes)
2. Reset cooldown in app settings
3. Verify only one device token registered

---

## Notification Customization

### Change Thresholds

Edit `mobile/lib/services/threshold_service.dart`:

```dart
class SensorThresholds {
  static const double SOIL_CRITICAL_LOW = 20;  // Change this
  static const double SOIL_WARNING_LOW = 30;   // Or this
  // ... etc
}
```

### Change Cooldown Period

Edit `mobile/lib/services/threshold_service.dart`:

```dart
static const int NOTIFICATION_COOLDOWN_MINUTES = 30;  // Change to 60 for 1 hour
```

### Customize Notification Messages

Edit `server/fcm-service.js`:

```javascript
const alerts = {
  SOIL_CRITICAL_LOW: {
    title: '🚨 Urgent: Water Your Plant NOW',  // Customize
    body: `Soil moisture is critically low...`,  // Customize
  },
  // ... etc
};
```

---

## Production Checklist

- [ ] Firebase project created
- [ ] Service account key downloaded and saved
- [ ] `FIREBASE_SERVICE_ACCOUNT_PATH` added to `.env`
- [ ] `firebase-service-account.json` added to `.gitignore`
- [ ] Android `google-services.json` added
- [ ] iOS `GoogleService-Info.plist` added
- [ ] Dependencies installed: `npm install --prefix server`
- [ ] Server restarted
- [ ] Mobile app rebuilt
- [ ] Test notification sent successfully
- [ ] Threshold alert tested
- [ ] Notification permissions granted on device

---

## Security Notes

1. **Never commit** `firebase-service-account.json` to git
2. **Keep** `FIREBASE_SERVICE_ACCOUNT_PATH` secret
3. **Validate** FCM tokens on backend
4. **Encrypt** tokens in transit (HTTPS)
5. **Limit** notification frequency to prevent spam
6. **Monitor** FCM token usage

---

## Support

For issues:
1. Check server logs: `npm start --prefix server`
2. Check mobile logs: `flutter run`
3. Verify Firebase project settings
4. Check network connectivity
5. Review this guide for troubleshooting

---

## Next Steps

After setup:
1. Test notifications with different thresholds
2. Customize alert messages for your plants
3. Set up notification preferences in app
4. Monitor notification delivery in Firebase Console
5. Adjust thresholds based on plant needs
