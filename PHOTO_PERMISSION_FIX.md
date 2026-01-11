# Photo Permission Fix

## Problem
App doesn't have permission to access local photos on Android 13+

## Solution Applied

### 1. Updated AndroidManifest.xml
Added Android 13+ specific permissions:
```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

### 2. Updated plant_disease_screen.dart
- Uses `Permission.photos` which automatically handles Android 13+ differences
- Added null checks for mounted state
- Better error handling

### 3. How It Works

**Android 12 and below:**
- Uses `READ_EXTERNAL_STORAGE` permission
- Requests at runtime

**Android 13+:**
- Uses `READ_MEDIA_IMAGES` permission
- Requests at runtime
- More granular permission control

## Testing

### Step 1: Clean Build
```bash
cd mobile
flutter clean
flutter pub get
```

### Step 2: Run App
```bash
flutter run
```

### Step 3: Test Photo Access
1. Go to "Disease" tab
2. Click "📷 Camera" or "🖼️ Gallery"
3. Grant permission when prompted
4. Select or take a photo
5. Disease detection should work

## Expected Behavior

### First Time
- App asks for permission
- User grants permission
- Photo picker opens
- User selects photo
- Disease detection runs

### Subsequent Times
- Permission already granted
- Photo picker opens immediately
- No permission dialog

## Troubleshooting

### Permission Still Denied
1. Check app settings: Settings → Apps → KisanGuide → Permissions
2. Enable "Photos" or "Camera" permission
3. Restart app

### Photo Picker Doesn't Open
1. Make sure permission is granted
2. Check if device has storage
3. Try camera instead of gallery

### Disease Detection Fails
1. Check server is running: `npm start --prefix server`
2. Check image is valid (not corrupted)
3. Check server logs for errors

## Files Modified

- `mobile/android/app/src/main/AndroidManifest.xml` - Added Android 13+ permissions
- `mobile/lib/screens/plant_disease_screen.dart` - Improved permission handling

## Commit

```bash
git add .
git commit -m "fix: add Android 13+ photo permissions and improve permission handling"
```

