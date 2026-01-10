# How to Get Agora Credentials

The app is currently running in **Demo Mode** because the Agora credentials are not configured. Follow these steps to get real credentials and enable the voice agent.

## Step 1: Create Agora Account

1. Go to https://console.agora.io
2. Click "Sign Up" or "Sign In"
3. Create a new account or log in

## Step 2: Create a Project

1. In Agora Console, click "Create Project"
2. Enter project name (e.g., "KisanGuide")
3. Select "Secure mode"
4. Click "Create"

## Step 3: Get App ID

1. In your project, go to "Project Settings"
2. Copy the **App ID**
3. Save it for later

## Step 4: Get App Certificate

1. In "Project Settings", find "App Certificate"
2. Click "Copy" to copy the certificate
3. Save it for later

## Step 5: Get Customer ID and Secret

1. Go to "Account" → "Credentials"
2. Copy **Customer ID**
3. Copy **Customer Secret**
4. Save both for later

## Step 6: Enable Conversational AI

1. In Agora Console, go to "Products"
2. Find "Conversational AI"
3. Click "Enable" if not already enabled

## Step 7: Update Server Configuration

Edit `server/.env` and update these values:

```env
AGORA_APP_ID=YOUR_APP_ID_HERE
AGORA_CUSTOMER_ID=YOUR_CUSTOMER_ID_HERE
AGORA_CUSTOMER_SECRET=YOUR_CUSTOMER_SECRET_HERE
AGORA_APP_CERTIFICATE=YOUR_APP_CERTIFICATE_HERE
```

Replace the placeholder values with your actual credentials from Agora Console.

## Step 8: Restart Server

```bash
cd server
npm start
```

You should see:
```
Server running on port 3000
Accepting connections from all network interfaces
MongoDB connected
```

## Step 9: Restart Mobile App

1. Close the app
2. Run: `flutter run`
3. Open the app
4. Tap the voice agent button
5. The app should now work with real Agora credentials

## Verification

After restarting, the app should:
- ✅ Not show "Demo Mode" message
- ✅ Allow you to start voice sessions
- ✅ Connect to Agora RTC
- ✅ Enable voice conversations

## Troubleshooting

### "Still showing Demo Mode"
- Verify credentials are correct in `server/.env`
- Check server is running: `npm start`
- Restart the app

### "Failed to fetch credentials"
- Ensure server is running
- Check server URL is correct
- Verify network connectivity

### "Agora initialization failed"
- Verify App ID is correct
- Check Conversational AI is enabled
- Verify all credentials are correct

## Security Notes

⚠️ **Important:**
- Never commit `server/.env` to git
- Keep credentials private
- Don't share your App ID or secrets
- Rotate credentials regularly

## Next Steps

1. ✅ Get Agora credentials
2. ✅ Update `server/.env`
3. ✅ Restart server
4. ✅ Restart app
5. ✅ Test voice agent

## Support

For issues:
- Check Agora documentation: https://docs.agora.io
- Review troubleshooting section above
- Check server logs: `npm start`
- Check app logs: `flutter run`

---

Once you have real credentials configured, the voice agent will be fully functional!
