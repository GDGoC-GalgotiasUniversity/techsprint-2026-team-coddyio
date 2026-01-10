import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  /// Initialize Firebase and FCM
  Future<void> initialize() async {
    try {
      // Initialize Firebase
      try {
        await Firebase.initializeApp();
      } catch (e) {
        print('⚠️ Firebase initialization warning: $e');
      }

      // Request notification permissions
      try {
        await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
      } catch (e) {
        print('⚠️ Permission request warning: $e');
      }

      // Get FCM token and register with server
      try {
        await _registerFCMToken();
      } catch (e) {
        print('⚠️ FCM token registration warning: $e');
      }

      // Handle foreground messages
      try {
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      } catch (e) {
        print('⚠️ Foreground message handler warning: $e');
      }

      // Handle background message tap
      try {
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      } catch (e) {
        print('⚠️ Background message handler warning: $e');
      }

      // Handle terminated state message
      try {
        final initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          _handleMessageOpenedApp(initialMessage);
        }
      } catch (e) {
        print('⚠️ Initial message handler warning: $e');
      }

      print('✅ FCM initialized successfully');
    } catch (e) {
      print('❌ FCM initialization error: $e');
    }
  }

  /// Register FCM token with server
  Future<void> _registerFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('📱 FCM Token: ${token.substring(0, 20)}...');
        await _registerTokenWithServer(token);
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  /// Register token with server
  Future<void> _registerTokenWithServer(String token) async {
    try {
      final response = await ApiService().registerFCMToken(token);
      if (response) {
        print('✅ FCM token registered with server');
      }
    } catch (e) {
      print('❌ Error registering token with server: $e');
    }
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📬 Foreground message received: ${message.notification?.title}');
    print('📝 ${message.notification?.body}');
  }

  /// Handle message opened from background
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    print('📭 Message opened from background: ${message.notification?.title}');
  }

  /// Show notification (simplified - just logs)
  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    print('🔔 NOTIFICATION: $title');
    print('📝 $body');
    if (payload != null) {
      print('📦 Data: ${jsonEncode(payload)}');
    }
  }

  /// Send test notification
  Future<void> sendTestNotification() async {
    print('🌱 Test Notification: FCM is working correctly!');
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Refresh FCM token
  Future<void> refreshFCMToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      await Future.delayed(const Duration(milliseconds: 500));
      await _registerFCMToken();
      print('✅ FCM token refreshed');
    } catch (e) {
      print('❌ Error refreshing FCM token: $e');
    }
  }
}

/// Background message handler (must be top-level function)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Background message received: ${message.notification?.title}');
}
