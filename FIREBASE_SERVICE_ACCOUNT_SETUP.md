# Firebase Service Account Setup for groot-7d03b

## Your Firebase Project Details

- **Project ID**: `groot-7d03b`
- **Project Number**: `320654510322`
- **Storage Bucket**: `groot-7d03b.firebasestorage.app`
- **API Key**: `AIzaSyCn3eSz8v77Knm_gu95es9cGW-KSNdH9K0`

---

## Step 1: Get Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project **groot-7d03b**
3. Click **⚙️ Project Settings** (gear icon, top left)
4. Go to **Service Accounts** tab
5. Click **Generate New Private Key** button
6. A JSON file will download automatically

---

## Step 2: Save the File

Save the downloaded JSON file as:
```
server/firebase-service-account.json
```

The file should look like:
```json
{
  "type": "service_account",
  "project_id": "groot-7d03b",
  "private_key_id": "xxxxx",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...",
  "client_email": "firebase-adminsdk-xxxxx@groot-7d03b.iam.gserviceaccount.com",
  "client_id": "xxxxx",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/..."
}
```

---

## Step 3: Verify Setup

Check that you have:

- ✅ `mobile/android/app/google-services.json` (already placed)
- ✅ `server/firebase-service-account.json` (download and place)
- ✅ `server/.env` updated with Firebase config (already done)

---

## Step 4: Test Firebase Connection

```bash
# Install dependencies
npm install --prefix server

# Start server
npm start --prefix server
```

You should see:
```
✅ Firebase Admin SDK initialized
```

If you see a warning instead:
- Check file path is correct
- Verify JSON file is valid
- Restart server

---

## Step 5: Enable Cloud Messaging API

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project **groot-7d03b**
3. Go to **Build** → **Cloud Messaging**
4. Click **Enable** if not already enabled

---

## Step 6: Test Notifications

```bash
# Get your FCM token from mobile app logs
# Then test with:

curl -X POST http://localhost:3000/api/test-notification \
  -H "Content-Type: application/json" \
  -d '{"token":"your_fcm_token_here"}'
```

---

## Files Already Set Up

✅ **Android Configuration**
- `mobile/android/app/google-services.json` - Placed automatically

✅ **Server Configuration**
- `server/.env` - Updated with project ID and API key

✅ **Mobile Configuration**
- `mobile/pubspec.yaml` - Firebase packages added
- `mobile/lib/main.dart` - FCM initialization added
- `mobile/lib/services/notification_service.dart` - Created

---

## What You Need to Do

1. **Download Service Account JSON**
   - Go to Firebase Console
   - Project Settings → Service Accounts
   - Generate New Private Key
   - Save as: `server/firebase-service-account.json`

2. **Restart Server**
   ```bash
   npm start --prefix server
   ```

3. **Run Mobile App**
   ```bash
   flutter run
   ```

4. **Test Notifications**
   - Wait for sensor data
   - When threshold crossed, notification appears

---

## Security

⚠️ **IMPORTANT**:
- Never commit `firebase-service-account.json` to git
- It's already in `.gitignore`
- Keep the private key secret
- Don't share the JSON file

---

## Troubleshooting

### "Firebase not initialized"
- Check `FIREBASE_SERVICE_ACCOUNT_PATH` in `.env`
- Verify JSON file exists at that path
- Verify JSON is valid (use JSON validator)
- Restart server

### "Cannot find module 'firebase-admin'"
- Run: `npm install --prefix server`
- Restart server

### "Notifications not received"
- Check app has notification permissions
- Verify FCM token is registered
- Check server logs for errors
- Verify Cloud Messaging API is enabled

---

## Next Steps

1. Download service account JSON (see Step 1-2)
2. Place in `server/firebase-service-account.json`
3. Restart server: `npm start --prefix server`
4. Check for "✅ Firebase Admin SDK initialized"
5. Run mobile app: `flutter run`
6. Test notifications when thresholds crossed

**Setup time: ~5 minutes**
