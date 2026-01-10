# FCM Quick Reference Card

## 🚀 Quick Start (5 minutes)

### Option 1: Demo Mode (No Firebase)
```bash
npm install --prefix server
npm start --prefix server
flutter run
# Notifications work locally!
```

### Option 2: Full Setup (With Firebase)
```bash
# 1. Go to https://console.firebase.google.com
# 2. Create project "KisanGuide"
# 3. Download service account JSON
# 4. Save as: server/firebase-service-account.json
# 5. Update server/.env with project ID
# 6. Run:
npm install --prefix server
npm start --prefix server
flutter run
```

---

## 📋 Checklist

- [ ] Firebase project created
- [ ] Service account JSON downloaded
- [ ] Saved to `server/firebase-service-account.json`
- [ ] `.env` updated with project ID
- [ ] `npm install --prefix server` run
- [ ] Server started: `npm start --prefix server`
- [ ] Mobile app running: `flutter run`
- [ ] Check logs for "✅ Firebase Admin SDK initialized"

---

## 🔔 Alert Types

| Sensor | Critical | Warning |
|--------|----------|---------|
| **Soil** | < 20% or > 90% | < 30% or > 80% |
| **Temp** | < 5°C or > 40°C | < 10°C or > 35°C |
| **Humidity** | < 20% or > 95% | < 30% or > 80% |

---

## 🧪 Testing

```bash
# Test notification
curl -X POST http://localhost:3000/api/test-notification \
  -H "Content-Type: application/json" \
  -d '{"token":"test_token"}'

# Send alert
curl -X POST http://localhost:3000/api/send-alert \
  -H "Content-Type: application/json" \
  -d '{
    "token":"test_token",
    "alertType":"SOIL_CRITICAL_LOW",
    "sensorValue":15,
    "unit":"%",
    "plantName":"Tomato"
  }'
```

---

## 📁 Key Files

| File | Purpose |
|------|---------|
| `mobile/lib/services/notification_service.dart` | FCM setup & local notifications |
| `mobile/lib/services/threshold_service.dart` | Threshold checking & alerts |
| `server/fcm-service.js` | Firebase notification sending |
| `server/.env` | Firebase configuration |
| `server/firebase-service-account.json` | Firebase credentials (secret!) |

---

## ⚙️ Configuration

### .env Variables
```env
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
FIREBASE_DATABASE_URL=https://YOUR_PROJECT_ID.firebaseio.com
```

### Thresholds (Edit in threshold_service.dart)
```dart
SOIL_CRITICAL_LOW = 20
SOIL_WARNING_LOW = 30
TEMP_CRITICAL_LOW = 5
TEMP_WARNING_LOW = 10
HUMIDITY_CRITICAL_LOW = 20
HUMIDITY_WARNING_LOW = 30
```

### Cooldown (Edit in threshold_service.dart)
```dart
NOTIFICATION_COOLDOWN_MINUTES = 30  // Change to 60 for 1 hour
```

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| "Cannot find module 'firebase-admin'" | Run `npm install --prefix server` |
| "Firebase not initialized" | Check .env path and JSON file exists |
| "No notifications received" | Check app has notification permissions |
| "Duplicate notifications" | Wait 30 minutes or reset cooldown |

---

## 📚 Full Guides

- **Setup**: See `FCM_SETUP_GUIDE.md`
- **Firebase**: See `FIREBASE_QUICK_SETUP.md`
- **Implementation**: See `FCM_IMPLEMENTATION_COMPLETE.md`

---

## 🔐 Security

⚠️ **IMPORTANT**:
- Add `firebase-service-account.json` to `.gitignore`
- Never commit the JSON file
- Keep `FIREBASE_SERVICE_ACCOUNT_PATH` secret
- Use HTTPS in production

---

## 📞 Support

1. Check server logs: `npm start --prefix server`
2. Check mobile logs: `flutter run`
3. Verify Firebase project settings
4. Review guides above
5. Check network connectivity

---

## ✅ Verification

After setup, you should see:

**Server logs:**
```
✅ Firebase Admin SDK initialized
✅ FCM token registered: device_token_xxx...
✅ Notification sent to device_token_xxx...: message_id
```

**Mobile app:**
- Notifications appear when thresholds crossed
- Plant name shown in notification
- Sensor values displayed
- Actionable recommendations provided

---

## 🎯 Next Steps

1. Complete Firebase setup (5 min)
2. Test with curl commands (2 min)
3. Customize thresholds (5 min)
4. Monitor notifications (ongoing)
5. Adjust based on plant needs (ongoing)

**Total setup time: ~15 minutes**
