# Gemini AI Setup

## Get Your API Key

1. Go to: https://makersuite.google.com/app/apikey
2. Click "Create API Key"
3. Copy the API key

## Add to App

Open `mobile/lib/services/gemini_service.dart` and replace:

```dart
static const String apiKey = 'AIzaSyBNdTjEonDMxXgJqjXCdgXHGInBMRLlz70';
```

With your actual key:

```dart
static const String apiKey = 'AIzaSy...your-actual-key';
```

## Install Dependencies

```bash
cd mobile
flutter pub get
```

## Run the App

```bash
flutter run
```

## How to Use

1. Open the app
2. Tap the AI Assistant icon (robot) in the top right
3. Ask questions like:
   - "Is the temperature normal?"
   - "Should I water the plant?"
   - "What's the humidity level?"
   - "Is the soil too dry?"

The AI will analyze your current sensor data and provide helpful answers!
