# Camera & Photo Library Permissions - Added ✅

## What Was Done

Added camera and photo library permissions to both Android and iOS configurations, plus runtime permission handling in the Flutter app.

## Android Permissions

Added to `mobile/android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Permissions for camera and photo library -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

These permissions allow:
- **CAMERA** - Access to device camera for photo capture
- **READ_EXTERNAL_STORAGE** - Read photos from device gallery
- **WRITE_EXTERNAL_STORAGE** - Save captured photos to device storage

## iOS Permissions

Updated `mobile/ios/Runner/Info.plist`:

```xml
<!-- Camera permission for plant disease detection -->
<key>NSCameraUsageDescription</key>
<string>Camera access is needed to capture photos of plants for disease detection analysis.</string>

<!-- Photo library permission for plant disease detection -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access is needed to select plant photos for disease detection analysis.</string>
```

These provide user-facing descriptions for:
- **NSCameraUsageDescription** - Why camera access is needed
- **NSPhotoLibraryUsageDescription** - Why photo library access is needed

## Runtime Permission Handling

Updated `mobile/lib/screens/plant_disease_screen.dart`:

1. **Added permission_handler import** - For runtime permission requests
2. **Added _requestPermission() method** - Requests camera or photo library permission
3. **Updated _pickImage() method** - Now requests appropriate permission before accessing camera/gallery
4. **Added permission denied handling** - Shows user-friendly error message if permission is denied

## How It Works

When user clicks "Camera" or "Gallery" button:

1. App checks if permission is already granted
2. If not granted, shows system permission dialog
3. User can grant or deny permission
4. If granted, image picker opens
5. If denied, shows error message explaining why permission is needed

## Testing

1. Run the app: `flutter run`
2. Navigate to Plant Disease Detection screen
3. Click "Camera" button
   - First time: System will ask for camera permission
   - Grant permission to proceed
4. Click "Gallery" button
   - First time: System will ask for photo library permission
   - Grant permission to proceed
5. After granting permissions, image picker should work normally

## Files Modified

- `mobile/android/app/src/main/AndroidManifest.xml` - Added camera/storage permissions
- `mobile/ios/Runner/Info.plist` - Added camera/photo library descriptions
- `mobile/lib/screens/plant_disease_screen.dart` - Added runtime permission handling

## Notes

- Permissions are requested at runtime (Android 6.0+)
- iOS will show permission dialogs automatically when needed
- Users can change permissions in device settings
- App gracefully handles permission denial with helpful messages
