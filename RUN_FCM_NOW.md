# Run FCM Now - Step by Step

## Prerequisites

✅ Firebase service account JSON downloaded
✅ Saved to `server/firebase-service-account.json`
✅ All code updated and ready

---

## Step 1: Clean Mobile App

```bash
cd mobile
flutter clean
```

Expected output:
```
Deleting build...
Deleting .dart_tool...
...
```

---

## Step 2: Get Dependencies

```bash
flutter pub get
```

Expected output:
```
Resolving dependencies...
Downloading packages...
Got dependencies!
```

---

## Step 3: Run Mobile App

```bash
flutter run
```

Expected output:
```
✅ FCM initialized successfully
✅ Local notifications initialized
✅ FCM token registered
```

**Keep this terminal open!**

---

## Step 4: Open New Terminal - Start Server

```bash
npm install --prefix server
npm start --prefix server
```

Expected output:
```
✅ Firebase Admin SDK initialized
✅ MongoDB connected
🚀 Server running on port 3000
📬 FCM Notification API available at /api/fcm-token
```

**Keep this terminal open!**

---

## Step 5: Test Notifications

### Option A: Automatic Testing

1. Open home screen in mobile app
2. Wait for sensor data (updates every 3 seconds)
3. When threshold crossed, notification appears

### Option B: Manual Testing

Open a third terminal and run:

```bash
# Get FCM token from mobile app logs, then:

curl -X POST http://localhost:3000/api/test-notification \
  -H "Content-Type: application/json" \
  -d '{"token":"your_fcm_token_here"}'
```

Expected output:
```
{
  "success": true,
  "message": "Test notification sent"
}
```

---

## Expected Results

### Mobile App
- ✅ Home screen shows sensor data
- ✅ Notifications appear when thresholds crossed
- ✅ Plant name shown in notifications
- ✅ Sensor values displayed

### Server
- ✅ FCM initialized message
- ✅ Token registration logged
- ✅ Notifications sent successfully

### Notifications
- ✅ 🚨 Critical alerts (urgent)
- ✅ ⚠️ Warning alerts (soon)
- ✅ Plant-specific context
- ✅ Actionable recommendations

---

## Troubleshooting

### If Mobile App Won't Start

```bash
flutter clean
flutter pub get
flutter run -v
```

### If Server Won't Start

```bash
npm install --prefix server
npm start --prefix server
```

### If Notifications Don't Appear

1. Check server logs for errors
2. Verify FCM token is registered
3. Check app has notification permissions
4. Verify threshold is actually crossed

### If You Get Timeout Error

1. Check server is running on correct IP
2. Update `mobile/lib/services/api_service.dart` with correct IP
3. Restart both server and app

---

## Quick Reference

### Terminal 1: Mobile App
```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

### Terminal 2: Server
```bash
npm install --prefix server
npm start --prefix server
```

### Terminal 3: Testing
```bash
curl -X POST http://localhost:3000/api/test-notification \
  -H "Content-Type: application/json" \
  -d '{"token":"your_fcm_token_here"}'
```

---

## What Happens Next

1. **Sensor Data Arrives** (every 3 seconds)
2. **Thresholds Checked** (automatically)
3. **Alert Generated** (if threshold crossed)
4. **Cooldown Checked** (30-minute cooldown)
5. **FCM Notification Sent** (via Firebase)
6. **Local Notification Displayed** (on device)
7. **User Sees Alert** (with plant name and action)

---

## Example Scenario

### Scenario: Soil Moisture Too Low

**Time**: 10:00 AM
- Soil moisture: 45% ✅ (OK)

**Time**: 10:03 AM
- Soil moisture: 25% ⚠️ (Warning)
- Notification sent: "Water soon"

**Time**: 10:06 AM
- Soil moisture: 15% 🚨 (Critical)
- Notification sent: "Water your plant NOW"

**Time**: 10:36 AM (30 minutes later)
- Soil moisture: 10% 🚨 (Still critical)
- Notification sent again: "Water your plant NOW"

---

## Success Indicators

✅ **Mobile App**
- Starts without errors
- Shows "FCM initialized successfully"
- Displays sensor data
- Shows notifications

✅ **Server**
- Starts without errors
- Shows "Firebase Admin SDK initialized"
- Logs token registration
- Sends notifications

✅ **Notifications**
- Appear on device
- Include plant name
- Show sensor values
- Provide recommendations

---

## Next Steps After Testing

1. **Customize Thresholds** (if needed)
2. **Adjust Cooldown** (if needed)
3. **Test Different Scenarios** (all alert types)
4. **Monitor Notifications** (check delivery)
5. **Deploy to Production** (when ready)

---

## Support

If something doesn't work:

1. Check server logs: `npm start --prefix server`
2. Check mobile logs: `flutter run -v`
3. Verify Firebase project settings
4. Review this guide
5. Check network connectivity

---

## Summary

**You're ready to go!**

Just run:
1. `flutter run` (Terminal 1)
2. `npm start --prefix server` (Terminal 2)
3. Wait for notifications!

**Time to first notification: ~5 minutes**

Enjoy your plant monitoring system! 🌱
