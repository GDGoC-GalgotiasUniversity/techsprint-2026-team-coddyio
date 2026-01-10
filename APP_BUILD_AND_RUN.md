# Build and Run KisanGuide Mobile App

## Current Status

✅ **Server**: Running on port 3000  
✅ **Code**: Updated with correct emulator IP (10.0.2.2)  
⚠️ **App**: Needs rebuild to use new IP  

---

## Step 1: Stop Current App

If the app is still running, press **Ctrl+C** in the terminal where `flutter run` is executing.

---

## Step 2: Clean Build

```bash
cd mobile
flutter clean
```

This removes old build artifacts.

---

## Step 3: Rebuild and Run

```bash
flutter run
```

This will:
1. Rebuild the app with the correct server IP (10.0.2.2)
2. Install on the emulator
3. Start the app

**Wait for the build to complete** - it may take 1-2 minutes.

---

## Step 4: Verify Connection

Once the app starts, check the console logs for:

✅ **Success indicators:**
```
I/flutter: ✅ FCM token registered with server
I/flutter: ✅ FCM initialized successfully
I/flutter: 🔔 Alert: 🚨 Urgent: Water Your Plant NOW
I/flutter: 📝 Soil moisture is critically low at 0.0%
```

❌ **Error indicators (should NOT see these):**
```
I/flutter: Request timeout - server may be unreachable
```

---

## What Changed

**Before:**
```dart
static const String baseUrl = 'http://10.10.180.11:3000/api';
```

**After:**
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';
```

The special IP `10.0.2.2` is how Android emulator accesses the host machine.

---

## If Build Fails

### Issue: "Gradle task assembleDebug failed"

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: "Port 3000 already in use"

**Solution:**
```bash
Get-Process -Id (Get-NetTCPConnection -LocalPort 3000).OwningProcess | Stop-Process -Force
npm start --prefix server
```

### Issue: "Device not found"

**Solution:**
Make sure Android emulator is running:
```bash
flutter devices
```

Should show: `sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x86-64 • Android 14 (API 34)`

---

## Expected App Behavior

### Home Screen
- Shows plant status (Yes/No)
- Shows plant name if set
- Displays sensor data
- Shows alerts

### Alerts (Every 3 Seconds)
```
🔔 Alert: 🚨 Urgent: Water Your Plant NOW
   Plant: Tomato
   Soil Moisture: 0.0%
   Temperature: 28°C
   Humidity: 65%
```

### Features
- ✅ Chat with AI
- ✅ Voice conversations
- ✅ Disease detection
- ✅ Real-time alerts

---

## Server Verification

To verify server is working:

```bash
curl http://localhost:3000/api/sensor-data
```

Should return JSON with sensor data.

---

## Full Command Sequence

```bash
# Terminal 1: Server (already running)
npm start --prefix server

# Terminal 2: Mobile App
cd mobile
flutter clean
flutter run
```

---

## Troubleshooting Checklist

- [ ] Server is running on port 3000
- [ ] MongoDB is running
- [ ] Android emulator is running
- [ ] `flutter clean` completed
- [ ] `flutter run` completed without errors
- [ ] App shows on emulator screen
- [ ] No "Request timeout" errors in console
- [ ] Alerts appearing in console

---

## Next Steps

1. Run `flutter clean && flutter run`
2. Wait for app to start
3. Check console for successful connection
4. Test all features:
   - Set plant status
   - Chat with AI
   - Try voice agent
   - Test disease detection
5. Verify alerts appear every 3 seconds

---

## Support

If you encounter issues:
1. Check `FIX_SERVER_CONNECTION.md` for connection issues
2. Check `TROUBLESHOOTING_GUIDE.md` for common problems
3. Check server logs: `npm start --prefix server`
4. Check app logs: `flutter run` console output

