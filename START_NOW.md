# Start Now - Your System is Ready! 🚀

## Good News!

Your plant monitoring system is **fully functional**. The alerts are working perfectly!

---

## Quick Start (2 minutes)

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

---

## What You'll See

### Mobile App Console
```
✅ FCM initialized successfully
🔔 Alert: 🚨 Urgent: Water Your Plant NOW
📢 Soil moisture is critically low at 0.0%. Your plant needs water immediately!
```

### Server Console
```
✅ Firebase Admin SDK initialized
✅ FCM token registered with server
🚀 Server running on port 3000
```

---

## How It Works

1. **Sensor Data** arrives every 3 seconds
2. **Thresholds Checked** automatically
3. **Alert Generated** when threshold crossed
4. **Logged to Console** with full details
5. **Sent to Server** for Firebase notifications

---

## Alert Examples

### Soil Too Dry
```
🔔 Alert: 🚨 Urgent: Water Your Plant NOW
📢 Soil moisture is critically low at 15%. Your plant needs water immediately!
```

### Temperature Too High
```
🔔 Alert: ⚠️ Temperature Too High
📢 Temperature is high at 38°C. Heat stress risk. Provide shade or water.
```

### Humidity Too High
```
🔔 Alert: 🚨 Fungal Disease Risk!
📢 Humidity is critically high at 92%. Severe fungal disease risk! Improve ventilation.
```

---

## Thresholds

| Sensor | Critical | Warning |
|--------|----------|---------|
| Soil | < 20% or > 90% | < 30% or > 80% |
| Temp | < 5°C or > 40°C | < 10°C or > 35°C |
| Humidity | < 20% or > 95% | < 30% or > 80% |

---

## Features

✅ Real-time monitoring (every 3 seconds)
✅ Automatic alert generation
✅ Plant-specific context
✅ Sensor values displayed
✅ Actionable recommendations
✅ Spam prevention (30-min cooldown)

---

## Customization

### Change Thresholds

Edit `mobile/lib/services/threshold_service.dart`:

```dart
static const double SOIL_CRITICAL_LOW = 20;  // Change this
```

### Change Cooldown

Edit `mobile/lib/services/threshold_service.dart`:

```dart
static const int NOTIFICATION_COOLDOWN_MINUTES = 30;  // Change to 60
```

---

## Testing

### Automatic
1. Open home screen
2. Wait for sensor data
3. When threshold crossed, alert appears

### Manual
```bash
curl -X POST http://localhost:3000/api/test-notification \
  -H "Content-Type: application/json" \
  -d '{"token":"your_fcm_token_here"}'
```

---

## That's It!

Your system is ready to monitor your plants!

Just run the two commands above and watch the alerts appear.

🌱 **Happy monitoring!** 🌱
