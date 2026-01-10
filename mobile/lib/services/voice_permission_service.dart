import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

class VoicePermissionService {
  /// Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();

      developer.log('Microphone permission: $status', name: 'VoicePermission');

      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        developer.log('Microphone permission denied', name: 'VoicePermission');
        return false;
      } else if (status.isPermanentlyDenied) {
        developer.log(
          'Microphone permission permanently denied',
          name: 'VoicePermission',
        );
        openAppSettings();
        return false;
      }
      return false;
    } catch (e) {
      developer.log(
        'Error requesting microphone permission: $e',
        name: 'VoicePermission',
      );
      return false;
    }
  }

  /// Check if microphone permission is granted
  static Future<bool> isMicrophonePermissionGranted() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      developer.log(
        'Error checking microphone permission: $e',
        name: 'VoicePermission',
      );
      return false;
    }
  }

  /// Request all required permissions for voice agent
  static Future<bool> requestAllVoicePermissions() async {
    try {
      final micPermission = await requestMicrophonePermission();

      if (!micPermission) {
        developer.log(
          'Failed to get required permissions',
          name: 'VoicePermission',
        );
        return false;
      }

      developer.log('All voice permissions granted', name: 'VoicePermission');
      return true;
    } catch (e) {
      developer.log(
        'Error requesting voice permissions: $e',
        name: 'VoicePermission',
      );
      return false;
    }
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      developer.log('Error opening app settings: $e', name: 'VoicePermission');
    }
  }
}
