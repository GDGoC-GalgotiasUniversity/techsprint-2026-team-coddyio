# FCM Implementation Summary

## What Was Implemented

Complete Firebase Cloud Messaging (FCM) integration for plant care notifications. The system monitors sensor data and sends alerts when thresholds are crossed.

---

## Files Created

### Mobile (Flutter)

1. **mobile/lib/services/notification_service.dart**
   - FCM initialization and setup
   - Local notification display
   - Token registration with server
   - Background message handling
   - Foreground message handling

2. **mobile/lib/services/threshold_service.dart**
   - Sensor threshold definitions
   - Alert type enumeration
   - Threshold checking logic
   - Alert cooldown management
   - Alert history tracking

### Server (Node.js)

1. **server/fcm-service.js**
   - Firebase Admin SDK initialization
   - Single notification sending
   - Multicast notification sending
   - Alert notification templates
   - Error handling and logging

2. **server/server.js** (updated)
   - FCM token registration endpoint: `POST /api/fcm-token`
   - Test notification endpoint: `POST /api/test-notification`
   - Alert notification endpoint: `POST /api/send-alert`
   - FCM tokens list endpoint: `GET /api/fcm-tokens`
   - FCM Token MongoDB schema

### Configuration

1. **mobile/pubspec.yaml** (updated)
   - Added: `firebase_core: ^2.24.0`
   - Added: `firebase_messaging: ^14.6.0`
   - Added: `flutter_local_notifications: ^16.1.0`
   - Added: `shared_preferences: ^2.2.0`

2. **server/package.json** (updated)
   - Added: `firebase-admin: ^12.0.0`

3. **mobile/lib/main.dart** (updated)
   - FCM initialization on app startup
   - Background message handler setup

4. **mobile/lib/screens/home_screen.dart** (updated)
   - Threshold checking on each sensor reading
   - Notification sending when thresholds crossed

5. **mobile/lib/services/api_service.dart** (updated)
   - Added: `registerFCMToken()` method

---

## Features Implemented

### 1. Automatic Threshold Monitoring
- Checks sensor data every 3 seconds
- Compares against predefined thresholds
- Triggers alerts when thresholds crossed

### 2. Smart Notifications
- **Soil Moisture Alerts**:
  - 🚨 Critical Low (< 20%): Urgent watering needed
  - ⚠️ Warning Low (< 30%): Water soon
  - ⚠️ Warning High (> 80%): Soil too wet
  - 🚨 Critical High (> 90%): Drain excess water

- **Temperature Alerts**:
  - 🚨 Critical Low (< 5°C): Frost risk
  - ⚠️ Warning Low (< 10°C): Cold stress
  - ⚠️ Warning High (> 35°C): Heat stress
  - 🚨 Critical High (> 40°C): Critical heat

- **Humidity Alerts**:
  - 🚨 Critical Low (< 20%): Severe drought
  - ⚠️ Warning Low (< 30%): Low humidity
  - ⚠️ Warning High (> 80%): Fungal risk
  - 🚨 Critical High (> 95%): Severe fungal risk

### 3. Notification Cooldown
- Prevents notification spam
- Same alert won't repeat within 30 minutes
- Cooldown tracked in SharedPreferences
- Can be reset for testing

### 4. Dual Notification System
- **FCM Push Notifications** (when Firebase configured)
  - Sent from server to device
  - Works in foreground and background
  - Includes rich data payload

- **Local Notifications** (always available)
  - Displayed on device
  - Works without Firebase
  - Useful for demo/testing

### 5. Token Management
- Automatic token registration on app startup
- Token refresh on demand
- Token storage in MongoDB
- Token history tracking (created, last used)

### 6. Background Processing
- Handles messages when app is closed
- Processes messages when app is in background
- Displays notifications automatically

---

## How It Works

### Notification Flow

```
1. NodeMCU sends sensor data
   ↓
2. Server receives at /api/ingest
   ↓
3. Mobile app polls /api/latest every 3 seconds
   ↓
4. HomeScreen._fetchLatestData() called
   ↓
5. ThresholdService.checkThresholds() checks values
   ↓
6. If threshold crossed:
   - Create AlertInfo object
   - Check cooldown (30 min)
   - If not in cooldown:
     ↓
7. NotificationService.showNotification()
   ↓
8. Display local notification on device
   ↓
9. (Optional) Send FCM to server
   ↓
10. Server sends via Firebase
    ↓
11. Device receives push notification
```

### Example: Soil Moisture Alert

```
Sensor reads: 15% soil moisture
  ↓
Threshold check: 15 < 20 (SOIL_CRITICAL_LOW)
  ↓
Alert created: "🚨 Urgent: Water Your Plant NOW"
  ↓
Cooldown check: Last alert was 45 minutes ago (> 30 min)
  ↓
Send notification:
  Title: "🚨 Urgent: Water Your Plant NOW"
  Body: "Soil moisture is critically low at 15%. Your plant needs water immediately!"
  ↓
User sees notification on device
```

---

## Threshold Values

### Soil Moisture (%)
- Critical Low: < 20%
- Warning Low: < 30%
- Optimal: 40-70%
- Warning High: > 80%
- Critical High: > 90%

### Temperature (°C)
- Critical Low: < 5°C
- Warning Low: < 10°C
- Optimal: 15-30°C
- Warning High: > 35°C
- Critical High: > 40°C

### Humidity (%)
- Critical Low: < 20%
- Warning Low: < 30%
- Optimal: 40-70%
- Warning High: > 80%
- Critical High: > 95%

---

## API Endpoints

### 1. Register FCM Token
```
POST /api/fcm-token
{
  "token": "device_fcm_token"
}
```

### 2. Send Test Notification
```
POST /api/test-notification
{
  "token": "device_fcm_token"
}
```

### 3. Send Alert Notification
```
POST /api/send-alert
{
  "token": "device_fcm_token",
  "alertType": "SOIL_CRITICAL_LOW",
  "sensorValue": 15,
  "unit": "%",
  "plantName": "Tomato"
}
```

### 4. Get All FCM Tokens
```
GET /api/fcm-tokens
```

---

## Testing

### Without Firebase (Demo Mode)
1. Run server: `npm start --prefix server`
2. Run app: `flutter run`
3. Notifications display locally
4. No Firebase credentials needed

### With Firebase (Production)
1. Follow FCM_SETUP_GUIDE.md
2. Configure Firebase project
3. Download service account key
4. Set FIREBASE_SERVICE_ACCOUNT_PATH in .env
5. Restart server
6. Notifications sent via FCM

---

## Current Status

✅ **Implemented**:
- Threshold checking logic
- Local notification display
- FCM token registration
- Server endpoints
- Background message handling
- Notification cool