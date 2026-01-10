# FCM Rebuild Guide - Fix Plugin Issues

## Issues Fixed

✅ Firebase Messaging plugin implementation
✅ Local notifications plugin implementation  
✅ Shared preferences plugin implementation
✅ Android build configuration
✅ FCM permissions and services

---

## What Was Updated

### Android Configuration
1. **Root build.gradle.kts** - Added Google Services plugin
2. **App build.gradle.kts** - Added Firebase dependencies
3. **AndroidManifest.xml** - Added FCM permissions and services

### Flutter Configuration
1. **pubspec.yaml** - Firebase and notification packages already added
2. **main.dart** - FCM initialization already added
3. **notification_service.dart** - Created and ready

---

## Rebuild Steps

### Step 1: Clean Everything

```bash
cd mobile
flutter clean
```

### Step 2: Get Dependencies

```bash
flutter pub get
```

### Step 3: Rebuild Android

```bash
flutter pub get
flutter build apk --debug
```

Or just run directly:

```bash
flutter run
```

---

## Expected Output

When you run `flutter run`, you should see:

```
✅ Firebase Admin SDK initialized
✅ FCM token registered
✅ Local notifications initialized
```

---

## If You Still Get Errors

### Error: "No implementation found for method Messaging#startBackgroundIsolate"

**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

### Error: "No implementation found for method show on channel dexterous.com/flutter/local_notifications"

**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

### Error: "Unable to establish connection on channel"

**Solution**:
1. Make sure you're running on a real device or emulator
2. Check that emulator has Google Play Services installed
3. Try: `flutter run -v` for verbose output

---

## Verify Setup

### Check 1: Server Running

```bash
npm start --prefix server
```

Should show:
```
✅ Firebase Admin SDK initialized
✅ MongoDB connected
🚀 Server running on port 3000
```

### Check 2: Mobile App Running

```bash
flutter run
```

Should show:
```
✅ FCM initialized successfully
✅ Local notifications initialized
```

### Check 3: Notifications Working

1. Open home screen
2. Wait for sensor data (3-second updates)
3. When threshold crossed, notification appears

---

## Files Updated

```
mobile/
├── android/
│   ├── build.gradle.kts              ✅ Updated
│   └── app/
│       ├── build.gradle.kts          ✅ Updated
│       ├── google-services.json      ✅ Placed
│       └── src/main/
│           └── AndroidManifest.xml   ✅ Updated
├── lib/
│   ├── main.dart                     ✅ Ready
│   ├── services/
│   │   ├── notification_service.dart ✅ Ready
│   │   └── threshold_service.dart    ✅ Ready
│   └── screens/
│       └── home_screen.dart          ✅ Ready
└── pubspec.yaml                      ✅ Ready
```

---

## Quick Commands

```bash
# Clean and rebuild
cd mobile
flutter clean
flutter pub get
flutter run

# Verbose output for debugging
flutter run -v

# Run on specific device
flutter devices
flutter run -d <device_id>

# Check plugin status
flutter doctor -v
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Plugin not found | Run `flutter clean` then `flutter pub get` |
| Build fails | Check `flutter doctor -v` for issues |
| Emulator issues | Restart emulator or use real device |
| Network timeout | Check server is running on correct IP |

---

## Next Steps

1. **Clean**: `flutter clean`
2. **Get deps**: `flutter pub get`
3. **Run**: `flutter run`
4. **Test**: Wait for notifications

**Time: ~5 minutes**

---

## Summary

All Android configuration is now complete. The app should:
- ✅ Initialize Firebase Messaging
- ✅ Register FCM token
- ✅ Show local notifications
- ✅ Check thresholds every 3 seconds
- ✅ Send alerts when needed

Just rebuild and run!
