# Pre-Testing Checklist - Voice Agent Integration

**Date**: January 10, 2026  
**Status**: Ready for testing

## System Requirements

- [ ] Node.js 14+ installed
- [ ] MongoDB running locally (or connection string configured)
- [ ] Flutter SDK installed
- [ ] Android SDK or iOS SDK (depending on target platform)
- [ ] Agora account created
- [ ] Google Cloud account with Gemini API enabled
- [ ] Cartesia account created

## Server Setup

### Installation
- [ ] Navigate to `server/` directory
- [ ] Run `npm install` (if not already done)
- [ ] Verify `node_modules/` exists

### Configuration
- [ ] Open `server/.env`
- [ ] Verify all credentials are filled in:
  - [ ] `GEMINI_API_KEY` - Not empty, starts with `AIzaSy`
  - [ ] `GEMINI_MODEL` - Set to `gemini-2.0-flash`
  - [ ] `AGORA_APP_ID` - Valid UUID format
  - [ ] `AGORA_CUSTOMER_ID` - Valid UUID format
  - [ ] `AGORA_CUSTOMER_SECRET` - Valid string
  - [ ] `AGORA_APP_CERTIFICATE` - Valid string
  - [ ] `CARTESIA_API_KEY` - Starts with `sk_car_`
  - [ ] `CARTESIA_MODEL_ID` - Set to `sonic-3`
  - [ ] `CARTESIA_VOICE_ID` - Valid UUID format
- [ ] Verify `MONGODB_URI` points to running MongoDB
- [ ] Verify `PORT` is set to `3000`
- [ ] Verify `CORS_ORIGIN` is set to `*`

### Startup
- [ ] Run `npm start` in `server/` directory
- [ ] Verify output shows:
  ```
  Server running on port 3000
  Accepting connections from all network interfaces
  MongoDB connected
  ```
- [ ] Leave server running in terminal

### Endpoint Verification
- [ ] Test credentials endpoint:
  ```bash
  curl http://10.10.180.11:3000/api/config/credentials
  ```
  Should return JSON with all credentials

- [ ] Test token generation:
  ```bash
  curl -X POST http://10.10.180.11:3000/api/rtc-token \
    -H "Content-Type: application/json" \
    -d '{"channelName":"test","uid":1002}'
  ```
  Should return valid token

- [ ] Test sensor endpoint:
  ```bash
  curl http://10.10.180.11:3000/api/latest
  ```
  Should return latest sensor data or empty object

## Mobile App Setup

### Flutter Configuration
- [ ] Navigate to `mobile/` directory
- [ ] Run `flutter pub get`
- [ ] Verify `pubspec.lock` is updated
- [ ] Run `flutter doctor` to verify setup

### API Configuration
- [ ] Open `mobile/lib/services/api_service.dart`
- [ ] Verify `baseUrl` is set to `http://10.10.180.11:3000/api`
- [ ] Update IP address if server is on different machine

### Build & Run
- [ ] Connect device or start emulator
- [ ] Run `flutter run` in `mobile/` directory
- [ ] Wait for app to build and launch
- [ ] Verify app starts without crashes

### Permission Setup (Android)
- [ ] Open `mobile/android/app/src/main/AndroidManifest.xml`
- [ ] Verify these permissions are present:
  ```xml
  <uses-permission android:name="android.permission.RECORD_AUDIO" />
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  ```

### Permission Setup (iOS)
- [ ] Open `mobile/ios/Runner/Info.plist`
- [ ] Verify this key is present:
  ```xml
  <key>NSMicrophoneUsageDescription</key>
  <string>The voice agent needs microphone access to hear your questions and respond with voice.</string>
  ```

## IoT Sensor Setup

### NodeMCU Configuration
- [ ] Open `nodemcu/sensor_code.ino`
- [ ] Verify WiFi credentials:
  ```cpp
  const char* WIFI_SSID = "GALGOTIAS-ARUBA";
  const char* WIFI_PASS = "1234567@";
  ```
- [ ] Verify server URL:
  ```cpp
  const char* POST_URL = "http://10.10.180.11:3000/api/ingest";
  ```
- [ ] Upload code to NodeMCU
- [ ] Verify serial output shows:
  ```
  WiFi OK, IP: 192.168.x.x
  Temp(C): XX.X | Hum(%): XX.X | SoilRaw: XXX | Soil(%): XX.X
  HTTP POST -> code: 201
  ```

### Sensor Verification
- [ ] Check server logs for incoming POST requests
- [ ] Verify sensor data is being stored in MongoDB
- [ ] Test `/api/latest` endpoint returns current sensor data

## Pre-Test Verification

### Code Quality
- [ ] All Dart files compile without errors
- [ ] No type warnings or errors
- [ ] Server code has no syntax errors
- [ ] All dependencies installed

### Network Connectivity
- [ ] Device/emulator can reach server IP
- [ ] Server can reach Agora API
- [ ] Server can reach Gemini API
- [ ] Server can reach Cartesia API

### Credentials Validation
- [ ] All credentials are non-empty
- [ ] No placeholder values (YOUR_*, REPLACE_*, etc.)
- [ ] Credentials match Agora/Google/Cartesia accounts
- [ ] API keys are valid and not expired

### Logs Setup
- [ ] Open IDE console to view Flutter logs
- [ ] Open terminal to view server logs
- [ ] Have device logs accessible (Android Studio/Xcode)

## Testing Readiness

### Final Checks
- [ ] ✅ Server running and responding to requests
- [ ] ✅ MongoDB connected and storing data
- [ ] ✅ NodeMCU sending sensor data
- [ ] ✅ Flutter app built and running
- [ ] ✅ All credentials configured
- [ ] ✅ Network connectivity verified
- [ ] ✅ Permissions configured
- [ ] ✅ Logs accessible

### Ready to Test?
If all items above are checked, proceed to `QUICK_TEST_GUIDE.md` for step-by-step testing instructions.

## Troubleshooting Pre-Test Issues

### Server Won't Start
- [ ] Check MongoDB is running: `mongod`
- [ ] Check port 3000 is not in use: `netstat -an | grep 3000`
- [ ] Check `.env` file exists and is readable
- [ ] Check all dependencies installed: `npm install`

### App Won't Build
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Check Flutter version: `flutter --version`
- [ ] Check device/emulator is connected: `flutter devices`

### Can't Connect to Server
- [ ] Verify server IP address is correct
- [ ] Verify server is running: `curl http://10.10.180.11:3000/health`
- [ ] Check firewall allows port 3000
- [ ] Check device is on same network as server

### Credentials Not Working
- [ ] Verify credentials in `.env` are correct
- [ ] Check credentials haven't expired
- [ ] Verify API keys are for correct services
- [ ] Test credentials directly with service APIs

### Sensor Data Not Arriving
- [ ] Check NodeMCU is powered on
- [ ] Check WiFi connection: Serial monitor should show IP
- [ ] Check server URL in NodeMCU code
- [ ] Check server logs for POST requests
- [ ] Verify MongoDB is storing data

## Quick Verification Commands

```bash
# Check server is running
curl http://10.10.180.11:3000/health

# Check credentials endpoint
curl http://10.10.180.11:3000/api/config/credentials

# Check latest sensor data
curl http://10.10.180.11:3000/api/latest

# Check MongoDB connection
mongo
> use iot_sensors
> db.sensordatas.findOne()

# Check Flutter app logs
flutter logs

# Check device logs (Android)
adb logcat | grep flutter

# Check device logs (iOS)
xcrun simctl spawn booted log stream --predicate 'eventMessage contains[cd] "flutter"'
```

## Success Indicators

When everything is ready, you should see:

✅ Server console:
```
Server running on port 3000
Accepting connections from all network interfaces
MongoDB connected
```

✅ Flutter app:
- App launches without crashes
- Permission dialog appears
- Status shows "Ready to start voice session"

✅ NodeMCU serial:
```
WiFi OK, IP: 192.168.x.x
Temp(C): 22.5 | Hum(%): 36.9 | SoilRaw: 308 | Soil(%): 98.4
HTTP POST -> code: 201
```

✅ Server logs:
```
[2026-01-10T15:23:51.842Z] POST /api/ingest from 192.168.x.x
```

## Next Steps

1. Complete all items in this checklist
2. Verify all success indicators above
3. Proceed to `QUICK_TEST_GUIDE.md`
4. Follow testing steps in order
5. Monitor logs for any issues

---

**Checklist Version**: 1.0  
**Last Updated**: January 10, 2026  
**Status**: Ready for testing
