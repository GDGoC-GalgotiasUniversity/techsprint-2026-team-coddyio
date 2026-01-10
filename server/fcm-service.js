const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin SDK
let firebaseInitialized = false;
let firebaseError = null;

function initializeFirebase() {
  if (firebaseInitialized || firebaseError) {
    return;
  }

  try {
    // Check if service account path is provided
    const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
    
    if (!serviceAccountPath) {
      firebaseError = 'FIREBASE_SERVICE_ACCOUNT_PATH not set in .env';
      console.warn('⚠️ Firebase not configured:', firebaseError);
      console.warn('   To enable FCM notifications:');
      console.warn('   1. Go to https://console.firebase.google.com');
      console.warn('   2. Select project "groot-7d03b"');
      console.warn('   3. Go to Project Settings → Service Accounts');
      console.warn('   4. Click "Generate New Private Key"');
      console.warn('   5. Save the downloaded JSON to server/firebase-service-account.json');
      console.warn('   6. Restart the server');
      return;
    }

    let serviceAccount;
    try {
      serviceAccount = require(path.resolve(serviceAccountPath));
    } catch (e) {
      firebaseError = `Could not load service account from ${serviceAccountPath}`;
      console.warn('⚠️ Firebase initialization failed:', firebaseError);
      console.warn('   File not found or invalid JSON');
      return;
    }

    // Validate service account has required fields
    if (!serviceAccount.private_key || !serviceAccount.client_email || !serviceAccount.project_id) {
      firebaseError = 'Service account JSON missing required fields (private_key, client_email, project_id)';
      console.warn('⚠️ Firebase initialization failed:', firebaseError);
      console.warn('   Make sure you downloaded the complete service account JSON from Firebase Console');
      return;
    }

    // Validate private key format
    if (!serviceAccount.private_key.includes('BEGIN PRIVATE KEY')) {
      firebaseError = 'Private key has invalid format';
      console.warn('⚠️ Firebase initialization failed:', firebaseError);
      console.warn('   Private key must be in PEM format starting with "-----BEGIN PRIVATE KEY-----"');
      return;
    }

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      databaseURL: process.env.FIREBASE_DATABASE_URL
    });

    firebaseInitialized = true;
    console.log('✅ Firebase Admin SDK initialized successfully');
    console.log(`   Project: ${serviceAccount.project_id}`);
    console.log(`   Service Account: ${serviceAccount.client_email}`);
  } catch (error) {
    firebaseError = error.message;
    console.warn('⚠️ Firebase initialization failed:', error.message);
    console.warn('   FCM notifications will not be sent');
    console.warn('   App will continue to work without push notifications');
  }
}

/**
 * Send FCM notification to device
 */
async function sendNotification(fcmToken, title, body, data = {}) {
  if (!firebaseInitialized) {
    console.warn('⚠️ Firebase not initialized, skipping notification');
    return false;
  }

  try {
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        ...data,
        timestamp: new Date().toISOString(),
      },
      token: fcmToken,
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'plant_alerts',
        },
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
            },
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    const response = await admin.messaging().send(message);
    console.log(`✅ Notification sent to ${fcmToken.substring(0, 20)}...: ${response}`);
    return true;
  } catch (error) {
    console.error(`❌ Error sending notification: ${error.message}`);
    return false;
  }
}

/**
 * Send multicast notification to multiple devices
 */
async function sendMulticastNotification(fcmTokens, title, body, data = {}) {
  if (!firebaseInitialized) {
    console.warn('⚠️ Firebase not initialized, skipping notification');
    return { successCount: 0, failureCount: fcmTokens.length };
  }

  try {
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        ...data,
        timestamp: new Date().toISOString(),
      },
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'plant_alerts',
        },
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
            },
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    const response = await admin.messaging().sendMulticast({
      ...message,
      tokens: fcmTokens,
    });

    console.log(`✅ Multicast notification sent: ${response.successCount} success, ${response.failureCount} failed`);
    return response;
  } catch (error) {
    console.error(`❌ Error sending multicast notification: ${error.message}`);
    return { successCount: 0, failureCount: fcmTokens.length };
  }
}

/**
 * Send alert notification based on sensor thresholds
 */
async function sendAlertNotification(fcmToken, alertType, sensorValue, unit, plantName = null) {
  const alerts = {
    SOIL_CRITICAL_LOW: {
      title: '🚨 Urgent: Water Your Plant NOW',
      body: `Soil moisture is critically low at ${sensorValue}${unit}. Your plant needs water immediately!`,
    },
    SOIL_WARNING_LOW: {
      title: '⚠️ Water Your Plant Soon',
      body: `Soil moisture is low at ${sensorValue}${unit}. Water your plant in the next few hours.`,
    },
    SOIL_WARNING_HIGH: {
      title: '⚠️ Soil Too Wet',
      body: `Soil moisture is high at ${sensorValue}${unit}. Reduce watering to prevent root rot.`,
    },
    SOIL_CRITICAL_HIGH: {
      title: '🚨 Urgent: Drain Excess Water',
      body: `Soil moisture is critically high at ${sensorValue}${unit}. Risk of root rot! Improve drainage immediately.`,
    },
    TEMP_CRITICAL_LOW: {
      title: '🚨 Frost Risk!',
      body: `Temperature is critically low at ${sensorValue}${unit}. Frost risk! Protect your plant immediately.`,
    },
    TEMP_WARNING_LOW: {
      title: '⚠️ Temperature Too Low',
      body: `Temperature is low at ${sensorValue}${unit}. Cold stress risk. Consider protection.`,
    },
    TEMP_WARNING_HIGH: {
      title: '⚠️ Temperature Too High',
      body: `Temperature is high at ${sensorValue}${unit}. Heat stress risk. Provide shade or water.`,
    },
    TEMP_CRITICAL_HIGH: {
      title: '🚨 Critical Heat!',
      body: `Temperature is critically high at ${sensorValue}${unit}. Heat stress! Provide shade immediately.`,
    },
    HUMIDITY_CRITICAL_LOW: {
      title: '🚨 Severe Drought Stress',
      body: `Humidity is critically low at ${sensorValue}${unit}. Severe drought stress! Increase watering.`,
    },
    HUMIDITY_WARNING_LOW: {
      title: '⚠️ Low Humidity',
      body: `Humidity is low at ${sensorValue}${unit}. Increase watering or mist leaves.`,
    },
    HUMIDITY_WARNING_HIGH: {
      title: '⚠️ High Humidity',
      body: `Humidity is high at ${sensorValue}${unit}. Fungal disease risk. Improve air circulation.`,
    },
    HUMIDITY_CRITICAL_HIGH: {
      title: '🚨 Fungal Disease Risk!',
      body: `Humidity is critically high at ${sensorValue}${unit}. Severe fungal disease risk! Improve ventilation.`,
    },
  };

  const alert = alerts[alertType];
  if (!alert) {
    console.warn(`⚠️ Unknown alert type: ${alertType}`);
    return false;
  }

  return await sendNotification(fcmToken, alert.title, alert.body, {
    type: alertType,
    value: sensorValue.toString(),
    unit: unit,
    plantName: plantName || 'Unknown',
    action: 'open_home_screen',
  });
}

module.exports = {
  initializeFirebase,
  sendNotification,
  sendMulticastNotification,
  sendAlertNotification,
};
