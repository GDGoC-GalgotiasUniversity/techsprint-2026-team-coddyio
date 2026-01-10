# How to Run the Mobile App - Quick Start

## Prerequisites

✅ Flutter installed and configured
✅ Android SDK/Emulator or physical device connected
✅ Node.js server running on `10.10.180.11:3000`
✅ Python service working

## Step 1: Start the Server

Open a terminal and run:
```bash
cd server
node server.js
```

You should see:
```
✅ MongoDB connected
🚀 Server running on port 3000
📍 Accepting connections from all network interfaces
🌱 Plant Disease Detection API available at /api/plant-disease/detect
```

## Step 2: Verify Python Service

In another terminal:
```bash
cd server
python test_plant_disease.py
```

You should see:
```
✅ Successfully imported PlantDiseaseDetector
✅ Successfully initialized detector
ℹ️ No image provided. Service is ready.
```

## Step 3: Run the Flutter App

In a third terminal:
```bash
cd mobile
flutter run
```

The app will:
1. Clean build files
2. Compile Dart code
3. Build APK/IPA
4. Install on device/emulator
5. Launch the app

## Step 4: Test Plant Disease Detection

1. **Open the app** - You should see the home screen with sensor data
2. **Click the 🌿 Plant Disease button** - Top right of app bar
3. **Grant permissions** - Allow camera and photo library access
4. **Select an image**:
   - Click "Camera" to take a photo
   - Click "Gallery" to select from device
5. **Wait for analysis** - 10-20 seconds
6. **View results**:
   - Disease name and confidence
   - Disease information
   - AI-powered treatment recommendations

## Expected Output

### Console Logs (Server)
```
🌱 Detecting plant disease from image...
📝 Temp image saved: C:\Users\...\Temp\plant_1768066513345.jpg
✅ Plant disease detection complete
🌿 Prediction: Tomato___Early_blight
📊 Confidence: 95.23%
🗑️ Temp image cleaned up
```

### Mobile App
```
📸 Picking image from camera...
✅ Image selected: /data/user/0/com.example.mobile/cache/...jpg
📦 Image compressed: 30727 → 28809 bytes
✅ Disease detected: Tomato___Early_blight
```

## Troubleshooting

### App won't start
```bash
flutter clean
flutter pub get
flutter run
```

### Image picker not working
- Ensure permissions are granted
- Check AndroidManifest.xml has CAMERA permission
- Check Info.plist has NSCameraUsageDescription

### Disease detection fails
- Check server is running: `node server.js`
- Check Python service: `python test_plant_disease.py`
- Check network connectivity
- Verify IP address: `10.10.180.11:3000`

### Slow performance
- Check network latency
- Verify image compression is working
- Monitor server CPU/memory usage

## Test Images

Sample images available in:
```
plant-disease-model/static/uploads/
```

Examples:
- `Apple_scab.JPG` - Apple scab disease
- `apple_black_rot.JPG` - Apple black rot
- `cherry_healthy.JPG` - Healthy cherry
- `potato_healthy.JPG` - Healthy potato

## Ports Used

- **3000** - Node.js server
- **5000** - Flask app (if running separately)
- **27017** - MongoDB (if running locally)

## Network Requirements

- Mobile device must be on same network as server
- Server IP: `10.10.180.11`
- Firewall must allow port 3000

## Success Checklist

✅ Server running on port 3000
✅ Python service initialized
✅ Flutter app launches
✅ Plant Disease button visible
✅ Camera/Gallery opens
✅ Image selected and compressed
✅ Disease detected with confidence
✅ Results displayed correctly
✅ No errors in console

## Next Steps

1. Run the app: `flutter run`
2. Test with different plant images
3. Verify all features work
4. Check server logs for any issues
5. Monitor performance metrics
