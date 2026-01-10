# Voice Agent - Permissions & Voice Setup Guide

## 🎤 What Was Updated

The app now properly requests microphone permissions and is configured for voice input/output on both Android and iOS.

## ✅ Changes Made

### 1. Voice Agent Screen (mobile/lib/screens/voice_agent_screen.dart)
- ✅ Requests microphone permission on screen initialization
- ✅ Shows permission dialog if permission not granted
- ✅ Displays status messages for permission state
- ✅ Handles permission grant/deny gracefully

### 2. Android Configuration (mobile/android/app/src/main/AndroidManifest.xml)
- ✅ Added `RECORD_AUDIO` permission - for microphone access
- ✅ Added `INTERNET` permission - for API calls
- ✅ Added `ACCESS_NETWORK_STATE` permission - for network detection

### 3. iOS Configuration (mobile/ios/Runner/Info.plist)
- ✅ Added `NSMicrophoneUsageDescription` - explains why microphone is needed
- ✅ Added `NSCameraUsageDescription` - for future video features

## 🔐 Permission Flow

```
App Starts
    ↓
Voice Agent Screen Opens
    ↓
Check if Microphone Permission Granted
    ↓
If NOT Granted:
    ↓
Show Permission Dialog
    ↓
User Taps "Grant Permission"
    ↓
System Shows Native Permission Request
    ↓
User Grants/Denies
    ↓
App Updates Status
```

## 📱 User Experience

### First Time Opening Voice Agent

1. **Permission Dialog Appears**
   - Title: "Microphone Permission Required"
   - Message: Explains why microphone is needed
   - Buttons: "Cancel" and "Grant Permission"

2. **User Grants Permission**
   - Native system permission dialog appears
   - User taps "Allow"
   - App shows: "Permission granted - Ready to start"

3. **User Denies Permission**
   - App shows: "Permission denied - Cannot use voice agent"
   - User can retry or go to settings

### Subsequent Opens

- If permission already granted: No dialog, ready to use
- If permission denied: Dialog appears again, user can grant

## 🎯 How Voice Works

### Voice Input (Microphone)
1. User taps "Start Session"
2. Microphone captures user's voice
3. Audio sent to Agora RTC channel
4. Agora Conversational AI Engine processes audio
5. Speech recognition converts to text
6. Gemini AI processes the text

### Voice Output (Speaker)
1. Gemini generates response text
2. Cartesia TTS converts text to speech
3. Audio sent back through Agora RTC
4. User hears response through speaker

## 📋 Permissions Explained

### Android Permissions

| Permission | Purpose | Required |
|-----------|---------|----------|
| RECORD_AUDIO | Capture microphone input | ✅ Yes |
| INTERNET | API calls to server | ✅ Yes |
| ACCESS_NETWORK_STATE | Check network connectivity | ✅ Yes |

### iOS Permissions

| Permission | Purpose | Required |
|-----------|---------|----------|
| NSMicrophoneUsageDescription | Microphone access explanation | ✅ Yes |
| NSCameraUsageDescription | Camera access (future use) | ⚠️ Optional |

## 🧪 Testing Permissions

### Android Testing

1. **First Run**
   ```
   - Open app
   - Navigate to Voice Agent
   - Permission dialog appears
   - Tap "Grant Permission"
   - System dialog appears
   - Tap "Allow"
   - Status shows "Permission granted"
   ```

2. **Revoke Permission**
   ```
   - Settings → Apps → Mobile → Permissions
   - Tap Microphone
   - Select "Don't allow"
   - Reopen app
   - Permission dialog appears again
   ```

3. **Check Permission Status**
   ```
   - Settings → Apps → Mobile → Permissions
   - Microphone should show "Allowed"
   ```

### iOS Testing

1. **First Run**
   ```
   - Open app
   - Navigate to Voice Agent
   - Permission dialog appears
   - Tap "Grant Permission"
   - System dialog appears
   - Tap "Allow"
   - Status shows "Permission granted"
   ```

2. **Revoke Permission**
   ```
   - Settings → Privacy → Microphone
   - Toggle off for Mobile app
   - Reopen app
   - Permission dialog appears again
   ```

3. **Check Permission Status**
   ```
   - Settings → Privacy → Microphone
   - Mobile should be listed and enabled
   ```

## 🔊 Voice Testing Checklist

- [ ] Microphone permission requested on first open
- [ ] Permission dialog shows clear explanation
- [ ] User can grant permission
- [ ] User can deny permission
- [ ] Status message updates correctly
- [ ] Can start voice session after permission granted
- [ ] Microphone captures audio
- [ ] Agent greeting is heard
- [ ] User speech is recognized
- [ ] Agent responds with voice
- [ ] Audio quality is acceptable
- [ ] No audio feedback loops
- [ ] Speaker volume is controllable

## 🎙️ Voice Agent Features

### Microphone Control
- **Mute/Unmute** - Toggle microphone during session
- **Volume Control** - Adjust recording volume
- **Audio Feedback** - Visual indicator when recording

### Speaker Control
- **Volume** - System volume controls output
- **Mute** - Mute speaker if needed
- **Audio Quality** - 16kHz, 16-bit audio

## 🚀 Setup Steps

### 1. Clean and Rebuild

```bash
cd mobile
flutter clean
flutter pub get
```

### 2. Run on Android

```bash
flutter run -d android
```

When app opens:
- Navigate to Voice Agent
- Permission dialog appears
- Grant permission
- Start voice session

### 3. Run on iOS

```bash
flutter run -d ios
```

When app opens:
- Navigate to Voice Agent
- Permission dialog appears
- Grant permission
- Start voice session

## 📝 Permission Descriptions

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### iOS (Info.plist)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to enable the voice agent feature. The microphone is used to capture your voice questions and allow the AI assistant to respond with voice.</string>
```

## 🔒 Privacy & Security

✅ Permissions only requested when needed
✅ Users can grant/deny permissions
✅ Permissions can be revoked anytime
✅ No data stored without permission
✅ Audio only transmitted during active session
✅ Microphone disabled when session ends

## 🆘 Troubleshooting

### "Permission denied - Cannot use voice agent"
**Solution:**
1. Go to Settings → Apps → Mobile
2. Tap Permissions → Microphone
3. Select "Allow"
4. Reopen app

### "Microphone not working"
**Solution:**
1. Check permission is granted
2. Check device microphone is not muted
3. Check app volume is not muted
4. Restart app

### "No audio output"
**Solution:**
1. Check device speaker is not muted
2. Check system volume is up
3. Check app volume is not muted
4. Restart app

### "Permission dialog not appearing"
**Solution:**
1. Permission already granted
2. Go to Settings to check
3. Revoke permission and reopen app

## 📚 Related Documentation

- `FIXED_SETUP_GUIDE.md` - Complete setup guide
- `CREDENTIALS_FROM_SERVER_SETUP.md` - Credentials configuration
- `VOICE_AGENT_README.md` - Technical documentation
- `VOICE_AGENT_SETUP.md` - Voice agent configuration

## ✨ Summary

The app now:
✅ Requests microphone permission properly
✅ Shows clear permission dialogs
✅ Handles permission grant/deny
✅ Configured for voice input/output
✅ Works on Android and iOS
✅ Follows platform best practices
✅ Respects user privacy

The voice agent is ready to use with proper permission handling!
