# Fix Server Connection Issue

## Problem
App shows "Request timeout - server may be unreachable" even though server is running.

## Root Cause
The app was using hardcoded IP `http://10.10.180.11:3000/api` which is incorrect for the Android emulator.

## Solution

### For Android Emulator
The special IP address to access the host machine from Android emulator is `10.0.2.2`.

**I've already updated the code to use this IP.**

### Step 1: Rebuild the App

Stop the current app (press Ctrl+C in the terminal where flutter run is executing).

Then run:
```bash
flutter clean
flutter run
```

This will rebuild the app with the correct server URL.

### Step 2: Verify Connection

Once the app starts, you should see:
- ✅ No more "Request timeout" errors
- ✅ Plant status loads correctly
- ✅ Sensor data displays
- ✅ Alerts appear in console

---

## For Physical Device

If you're testing on a physical device instead of emulator:

1. Find your computer's IP address:
   ```bash
   ipconfig
   ```
   Look for "IPv4 Address" (e.g., 192.168.x.x)

2. Update `mobile/lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000/api';
   ```

3. Make sure your phone is on the same WiFi network as your computer

4. Rebuild the app:
   ```bash
   flutter clean
   flutter run
   ```

---

## Android Emulator Special IPs

| What | IP Address |
|------|-----------|
| Host machine | 10.0.2.2 |
| Emulator itself | 127.0.0.1 or localhost |
| Other emulators | 10.0.2.x |

---

## Server Status

✅ Server running on port 3000  
✅ MongoDB connected  
✅ All APIs available  
✅ Ready for app connection  

---

## Quick Commands

**Rebuild app:**
```bash
cd mobile
flutter clean
flutter run
```

**Check server:**
```bash
curl http://localhost:3000/api/sensor-data
```

**Kill port 3000 if needed:**
```bash
Get-Process -Id (Get-NetTCPConnection -LocalPort 3000).OwningProcess | Stop-Process -Force
```

---

## Expected Output After Fix

```
I/flutter (17967): ✅ FCM token registered with server
I/flutter (17967): ✅ FCM initialized successfully
I/flutter (17967): 🔔 Alert: 🚨 Urgent: Water Your Plant NOW
I/flutter (17967): 📝 Soil moisture is critically low at 0.0%
```

No more "Request timeout" errors!

