# Firebase Service Account Setup - Complete Guide

## Current Status
✅ **System is fully functional without Firebase**
- Threshold detection working
- Alerts being generated and logged
- App runs perfectly without push notifications

⚠️ **Firebase Push Notifications are OPTIONAL**
- If you want to enable them, follow the steps below
- If not, the system works fine as-is

---

## How to Enable Firebase Push Notifications

### Step 1: Get Service Account JSON from Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project **"groot-7d03b"**
3. Click ⚙️ **Project Settings** (top-left)
4. Go to **Service Accounts** tab
5. Click **"Generate New Private Key"** button
6. A JSON file will download automatically
7. **IMPORTANT**: This file contains your complete private key - keep it secure!

### Step 2: Place the JSON File

1. Copy the downloaded JSON file
2. Paste it into: `server/firebase-service-account.json`
3. Make sure the file has:
   - `private_key` field with complete key (starts with `-----BEGIN PRIVATE KEY-----`)
   - `client_email` field
   - `project_id` field set to `groot-7d03b`

### Step 3: Verify Setup

The file should look like:
```json
{
  "type": "service_account",
  "project_id": "groot-7d03b",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@groot-7d03b.iam.gserviceaccount.com",
  "client_id": "320654510322",
  ...
}
```

### Step 4: Restart Server

```bash
npm start --prefix server
```

You should see:
```
✅ Firebase Admin SDK initialized successfully
   Project: groot-7d03b
   Service Account: firebase-adminsdk-xxxxx@groot-7d03b.iam.gserviceaccount.com
```

---

## What Happens Without Firebase

✅ **Still Works:**
- Sensor data collection
- Threshold detection (every 3 seconds)
- Alert generation and logging
- Chatbot and voice agent
- Plant disease detection
- All app features

❌ **Won't Work:**
- Push notifications to device
- But alerts are still logged in console

---

## Troubleshooting

### Error: "Failed to parse private key"
- **Cause**: Private key is incomplete or truncated
- **Fix**: Download fresh service account JSON from Firebase Console
- **Verify**: Private key should be 1500+ characters long

### Error: "Service account JSON missing required fields"
- **Cause**: Downloaded file is incomplete
- **Fix**: Make sure you downloaded the complete JSON, not just the key ID
- **Verify**: File should have `private_key`, `client_email`, `project_id` fields

### Error: "Could not load service account"
- **Cause**: File path is wrong or file doesn't exist
- **Fix**: Make sure file is at `server/firebase-service-account.json`
- **Verify**: File should be in the same directory as `server.js`

### Firebase initialized but no notifications sent
- **Cause**: FCM tokens not registered on device
- **Fix**: App automatically registers token on startup
- **Verify**: Check mobile app logs for "FCM Token:" message

---

## Security Notes

⚠️ **IMPORTANT**: 
- `firebase-service-account.json` is in `.gitignore` - never commit it
- Keep the private key secret
- Don't share the service account JSON file
- If compromised, regenerate the key in Firebase Console

---

## Next Steps

1. Download service account JSON from Firebase Console
2. Save to `server/firebase-service-account.json`
3. Restart server: `npm start --prefix server`
4. Run mobile app: `flutter run`
5. Alerts will now send push notifications to device

---

## System Architecture

```
NodeMCU Sensor
    ↓
Server (Port 3000)
    ├─ Receives sensor data
    ├─ Checks thresholds every 3 seconds
    ├─ Generates alerts
    └─ Sends FCM notifications (if Firebase configured)
    ↓
Mobile App
    ├─ Receives push notifications
    ├─ Shows alerts in UI
    └─ Logs to console
```

---

## Alert Thresholds

**Soil Moisture:**
- Critical Low: < 20%
- Warning Low: < 30%
- Warning High: > 80%
- Critical High: > 90%

**Temperature:**
- Critical Low: < 5°C
- Warning Low: < 10°C
- Warning High: > 35°C
- Critical High: > 40°C

**Humidity:**
- Critical Low: < 20%
- Warning Low: < 30%
- Warning High: > 80%
- Critical High: > 95%

---

## Testing

### Test Endpoint (without Firebase)
```bash
curl http://localhost:3000/api/test-notification
```

### Test Endpoint (with Firebase)
```bash
curl -X POST http://localhost:3000/api/send-alert \
  -H "Content-Type: application/json" \
  -d '{
    "fcmToken": "YOUR_FCM_TOKEN",
    "alertType": "SOIL_CRITICAL_LOW",
    "sensorValue": 15,
    "unit": "%",
    "plantName": "Tomato"
  }'
```

---

## Support

If you encounter issues:
1. Check server logs for error messages
2. Verify service account JSON is valid
3. Make sure Firebase project is active
4. Check that FCM is enabled in Firebase Console
5. Restart both server and mobile app

