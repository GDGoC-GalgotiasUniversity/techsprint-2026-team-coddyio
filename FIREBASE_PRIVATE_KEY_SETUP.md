# Firebase Private Key Setup - Complete Guide

## Your Private Key ID

```
Re31yk-j54xcLaqj3SB-tN3z2qn2e-Ewod_vu3YPB-w
```

---

## Step 1: Get the Complete Private Key

The private key ID alone is not enough. You need the **full private key** from Firebase Console.

### How to Get It:

1. Go to [Firebase Console](https://console.firebase.google.com/project/groot-7d03b)
2. Click **⚙️ Project Settings** (gear icon, top left)
3. Go to **Service Accounts** tab
4. Click **Generate New Private Key** button
5. A JSON file will download with the complete private key

### The JSON File Will Contain:

```json
{
  "type": "service_account",
  "project_id": "groot-7d03b",
  "private_key_id": "Re31yk-j54xcLaqj3SB-tN3z2qn2e-Ewod_vu3YPB-w",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC7VJTUt9Us8cKj\nMzEfYyjiWA4/4ggCHnWHNxN2HwZQxxx...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@groot-7d03b.iam.gserviceaccount.com",
  "client_id": "320654510322",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40groot-7d03b.iam.gserviceaccount.com"
}
```

---

## Step 2: Copy the Entire JSON

1. Open the downloaded JSON file
2. Copy **all the content**
3. Paste it into: `server/firebase-service-account.json`

---

## Step 3: Verify the File

The file should have:
- ✅ `"type": "service_account"`
- ✅ `"project_id": "groot-7d03b"`
- ✅ `"private_key_id": "Re31yk-j54xcLaqj3SB-tN3z2qn2e-Ewod_vu3YPB-w"`
- ✅ `"private_key": "-----BEGIN PRIVATE KEY-----\n..."`
- ✅ `"client_email": "firebase-adminsdk-...@groot-7d03b.iam.gserviceaccount.com"`
- ✅ `"client_id": "320654510322"`

---

## Step 4: Update .env

The `.env` file is already updated with:

```env
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
FIREBASE_DATABASE_URL=https://groot-7d03b.firebaseio.com
FIREBASE_PROJECT_ID=groot-7d03b
FIREBASE_API_KEY=AIzaSyCn3eSz8v77Knm_gu95es9cGW-KSNdH9K0
```

---

## Step 5: Install Dependencies

```bash
npm install --prefix server
```

---

## Step 6: Start Server

```bash
npm start --prefix server
```

You should see:
```
✅ Firebase Admin SDK initialized
✅ FCM token registered: device_token_xxx...
```

---

## Step 7: Run Mobile App

```bash
flutter run
```

---

## Testing

### Test 1: Check Server Logs

When you start the server, you should see:
```
✅ Firebase Admin SDK initialized
```

If you see a warning instead, the JSON file is not correct.

### Test 2: Send Test Notification

```bash
curl -X POST http://localhost:3000/api/test-notification \
  -H "Content-Type: application/json" \
  -d '{"token":"your_fcm_token_here"}'
```

### Test 3: Trigger Alert

```bash
curl -X POST http://localhost:3000/api/send-alert \
  -H "Content-Type: application/json" \
  -d '{
    "token":"your_fcm_token_here",
    "alertType":"SOIL_CRITICAL_LOW",
    "sensorValue":15,
    "unit":"%",
    "plantName":"Tomato"
  }'
```

---

## Troubleshooting

### Error: "Firebase not initialized"

**Cause**: JSON file is missing or invalid

**Solution**:
1. Download JSON from Firebase Console again
2. Copy entire content
3. Paste into `server/firebase-service-account.json`
4. Verify file is valid JSON (use JSON validator)
5. Restart server

### Error: "Cannot find module 'firebase-admin'"

**Solution**:
```bash
npm install --prefix server
```

### Error: "ENOENT: no such file or directory"

**Cause**: File path is wrong

**Solution**:
1. Check file is at: `server/firebase-service-account.json`
2. Check `.env` has: `FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json`
3. Restart server

### Error: "Invalid service account"

**Cause**: JSON file is corrupted or incomplete

**Solution**:
1. Download fresh JSON from Firebase Console
2. Verify it has all required fields
3. Use JSON validator to check syntax
4. Replace file and restart

---

## Security

⚠️ **IMPORTANT**:
- Never commit `firebase-service-account.json` to git
- It's already in `.gitignore`
- Keep the private key secret
- Don't share the JSON file
- Don't paste it in chat or emails

---

## File Locations

```
server/
├── .env                              ✅ Updated
├── firebase-service-account.json     ⏳ You need to update this
├── fcm-service.js                    ✅ Ready
└── server.js                         ✅ Ready

mobile/
├── android/app/
│   └── google-services.json          ✅ Placed
├── lib/
│   ├── main.dart                     ✅ Ready
│   └── services/
│       ├── notification_service.dart ✅ Ready
│       └── threshold_service.dart    ✅ Ready
└── pubspec.yaml                      ✅ Ready
```

---

## Quick Setup Checklist

- [ ] Download service account JSON from Firebase Console
- [ ] Copy entire JSON content
- [ ] Paste into `server/firebase-service-account.json`
- [ ] Verify file has all required fields
- [ ] Run `npm install --prefix server`
- [ ] Run `npm start --prefix server`
- [ ] Check for "✅ Firebase Admin SDK initialized"
- [ ] Run `flutter run`
- [ ] Test notification with curl command
- [ ] Verify notification appears on device

---

## Next Steps

1. **Download JSON** from Firebase Console (2 min)
2. **Update File** `server/firebase-service-account.json` (1 min)
3. **Install Dependencies** `npm install --prefix server` (2 min)
4. **Start Server** `npm start --prefix server` (1 min)
5. **Run App** `flutter run` (1 min)
6. **Test** Send notification (1 min)

**Total time: ~10 minutes**

---

## Support

If you're stuck:
1. Check server logs: `npm start --prefix server`
2. Verify JSON file is valid
3. Check Firebase Console settings
4. Review this guide
5. Check network connectivity

---

## Summary

You have the private key ID. Now you need:
1. Download the **complete** JSON file from Firebase Console
2. Replace `server/firebase-service-account.json` with it
3. Restart server
4. Everything will work!

The private key ID alone is not enough - you need the full private key from the JSON file.
