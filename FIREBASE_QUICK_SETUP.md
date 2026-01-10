# Firebase Quick Setup - Get Your Credentials

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Create a project"**
3. Enter project name: `KisanGuide`
4. Click **"Continue"**
5. Disable Google Analytics (optional)
6. Click **"Create project"**
7. Wait for project to be created

---

## Step 2: Download Service Account Key

1. In Firebase Console, click the **gear icon** (Project Settings) at top left
2. Go to **"Service Accounts"** tab
3. Click **"Generate New Private Key"** button
4. A JSON file will download automatically
5. **Save this file as**: `server/firebase-service-account.json`

**File contents will look like:**
```json
{
  "type": "service_account",
  "project_id": "kisanguide-xxxxx",
  "private_key_id": "xxxxx",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...",
  "client_email": "firebase-adminsdk-xxxxx@kisanguide-xxxxx.iam.gserviceaccount.com",
  "client_id": "xxxxx",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/..."
}
```

---

## Step 3: Get Project ID

From the JSON file you just downloaded, find the `"project_id"` field.

Example: `"project_id": "kisanguide-12345"`

---

## Step 4: Enable Cloud Messaging API

1. In Firebase Console, go to **"Build"** → **"Cloud Messaging"**
2. Click **"Enable"** if not already enabled
3. Note the **Server API Key** (you'll see it on this page)

---

## Step 5: Add to .env

Add these lines to `server/.env`:

```env
# ============================================================================
# FIREBASE Configuration
# ============================================================================
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
FIREBASE_DATABASE_URL=https://YOUR_PROJECT_ID.firebaseio.com
```

Replace `YOUR_PROJECT_ID` with your actual project ID from Step 3.

Example:
```env
FIREBASE_DATABASE_URL=https://kisanguide-12345.firebaseio.com
```

---

## Step 6: Save Service Account JSON

1. Place the downloaded JSON file in: `server/firebase-service-account.json`
2. Add to `.gitignore` to keep it secret:

```bash
# Add to server/.gitignore
firebase-service-account.json
```

---

## Step 7: Verify Setup

Run the server:
```bash
npm start --prefix server
```

You should see:
```
✅ Firebase Admin SDK initialized
```

If you see a warning instead, check:
1. File path is correct
2. JSON file is valid
3. .env variables are set correctly

---

## Android Setup (Optional but Recommended)

1. In Firebase Console, click **"Add app"** → **"Android"**
2. Enter package name: `com.example.mobile`
3. Download `google-services.json`
4. Place in: `mobile/android/app/google-services.json`

---

## iOS Setup (Optional but Recommended)

1. In Firebase Console, click **"Add app"** → **"iOS"**
2. Enter bundle ID: `com.example.mobile`
3. Download `GoogleService-Info.plist`
4. Place in: `mobile/ios/Runner/GoogleService-Info.plist`

---

## Testing

After setup, test with:

```bash
# Send test notification
curl -X POST http://localhost:3000/api/test-notification \
  -H "Content-Type: application/json" \
  -d '{"token":"test_token_here"}'
```

---

## Troubleshooting

**Error: "Cannot find module 'firebase-admin'"**
- Run: `npm install --prefix server`

**Error: "Firebase not initialized"**
- Check `FIREBASE_SERVICE_ACCOUNT_PATH` in .env
- Verify JSON file exists at that path
- Restart server

**Error: "ENOENT: no such file or directory"**
- Check file path is correct
- Verify JSON file is in `server/` directory
- Check .env path matches actual file location

---

## Security

⚠️ **IMPORTANT**: 
- Never commit `firebase-service-account.json` to git
- Add to `.gitignore`
- Keep `FIREBASE_SERVICE_ACCOUNT_PATH` secret
- Don't share the JSON file

---

## Next Steps

1. Complete steps 1-6 above
2. Restart server: `npm start --prefix server`
3. Check for "✅ Firebase Admin SDK initialized" message
4. Test with curl command above
5. Run mobile app: `flutter run`
6. Notifications will now work!
