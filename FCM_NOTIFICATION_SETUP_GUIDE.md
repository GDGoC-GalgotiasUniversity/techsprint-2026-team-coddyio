# FCM Notification System - Complete Setup Guide

## Overview

The app now has a complete Firebase Cloud Messaging (FCM) notification system that sends alerts when:
- 🚨 Soil moisture is critically low (needs water immediately)
- ⚠️ Soil moisture is low (water soon)
- ⚠️ Soil is too wet (reduce watering)
- 🚨 Temperature is critically low (frost risk)
- ⚠️ Temperature is too low (cold stress)
- ⚠️ Temperature is too high (heat stress)
- 🚨 Temperature is critically high (critical heat)
- 🚨 Humidity is critically low (severe drought)
- ⚠️ Humidity is low (increase watering)
- ⚠️ Humidity is high (fungal disease risk)
- 🚨 Humidity is critically high (severe fungal disease risk)

---

## Setup Steps

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a new project"
3. Enter project name: "KisanGuide"
4. Enable Google Analytics (optional)
5. Click "Create project"

### Step 2: Set Up Firebase for Android

1. In Firebase Console, click "Add app" → Select Android
2. Enter package name: `com.example.mobile`
3. Download `google-services.json`
4. Place it in: `mobile/android/app/google-services.json`
5. In Firebase Console, go to Project Settings → Service Accounts
6. Click "Generate New Private Key"
7. Save as `server/firebase-service-account.json`

### Step 3: Set Up Firebase for iOS

1. In Firebase Console, click "Add app" → Select iOS
2. Enter bundle ID: `com.example.mobile`
3. Download `GoogleService-Info.plist`
4. Place it in: `mobile/ios/Runner/GoogleService-Info.plist`
5. In Xcode, add it to the Runner target

### Step 4: Update Server .env

Add to `server/.env`:
```
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
```

### Step 5: Install Dependencies

**Mobile:**
```bash
cd mobile
flutter pub get
```

**Server:**
```bash
cd server
npm install
```

### Step 6: Configure Android Manifest

The app already has the required permissions. Verify `mobile/android/app/src/main/AndroidManifest.xml` contains:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### Step 7: Configure iOS Info.plist

The app already has the required permissions. Verify `mobile/ios/Runner/Info.plist` contains:
```xml
<key>UIBackgroundModes</key>
<array>
  <string>remote-notification</string>
</array>
```

---

## How It Works

### Data Flow

```
NodeMCU Sensor
    ↓
Server /api/ingest
    ↓
MongoDB (SensorData)
    ↓
Mobile App (3-second polling)
    ↓
ThresholdService (checks thresholds)
    ↓
Alert Triggered?
    ├─ YES → NotificationService
    │         ↓
    │    Show Local Notification
    │         ↓
    │    User Sees Alert
    │
    └─ NO → Continue monitoring
```

### Threshold Checking

The app checks sensor data every 3 seconds against these thresholds:

**Soil Moisture (%)**
- Critical Low: < 20% → 🚨 Water NOW
- Warning Low: < 30% → ⚠️ Water soon
- Optimal: 40-70%
- Warning High: > 80% → ⚠️ Too wet
- Critical High: > 90% → 🚨 Drain water

**Temperature (°C)**
- Criti