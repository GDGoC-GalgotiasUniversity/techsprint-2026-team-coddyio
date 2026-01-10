import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'api_service.dart';

class AgoraRtcService {
  late RtcEngine _engine;
  bool _isInitialized = false;
  String? _appId;
  bool _isDemoMode = false;

  // Callbacks
  Function(int uid)? onUserJoined;
  Function(int uid)? onUserOffline;
  Function(String error)? onError;

  /// Fetch Agora App ID from server with fallback to demo mode
  Future<bool> fetchAppId() async {
    try {
      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      developer.log(
        'Fetching credentials from: $baseUrl/api/config/credentials',
        name: 'AgoraRTC',
      );

      final response = await http
          .get(Uri.parse('$baseUrl/api/config/credentials'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _appId = data['credentials']['agora']['appId'];

          // Check if it's a valid App ID (not a placeholder)
          if (_appId != null &&
              _appId!.isNotEmpty &&
              !_appId!.contains('YOUR_')) {
            developer.log(
              'Valid App ID fetched from server: $_appId',
              name: 'AgoraRTC',
            );
            _isDemoMode = false;
            return true;
          }
        }
      }

      developer.log(
        'Could not fetch valid App ID from server, using demo mode',
        name: 'AgoraRTC',
      );
      _isDemoMode = true;
      _appId = 'demo_app_id_${DateTime.now().millisecondsSinceEpoch}';
      return true;
    } catch (e) {
      developer.log(
        'Error fetching App ID, using demo mode: $e',
        name: 'AgoraRTC',
      );
      _isDemoMode = true;
      _appId = 'demo_app_id_${DateTime.now().millisecondsSinceEpoch}';
      return true;
    }
  }

  /// Initialize Agora RTC Engine
  Future<bool> initialize() async {
    try {
      // Fetch App ID if not already fetched
      if (_appId == null) {
        final fetched = await fetchAppId();
        if (!fetched) {
          onError?.call('Failed to fetch Agora App ID');
          return false;
        }
      }

      if (_isDemoMode) {
        developer.log(
          'Running in DEMO MODE - Voice agent will not work without real Agora credentials',
          name: 'AgoraRTC',
        );
        onError?.call(
          'Demo Mode: Configure server/.env with real Agora credentials for full functionality',
        );
      }

      _engine = createAgoraRtcEngine();

      await _engine.initialize(
        RtcEngineContext(
          appId: _appId!,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      // Set up event handlers
      _setupEventHandlers();

      // Enable audio
      await _engine.enableAudio();
      await _engine.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioDefault,
      );

      _isInitialized = true;
      developer.log(
        'Agora RTC Engine initialized (Demo: $_isDemoMode)',
        name: 'AgoraRTC',
      );
      return true;
    } catch (e) {
      developer.log('Failed to initialize Agora: $e', name: 'AgoraRTC');
      onError?.call('Initialization failed: $e');
      return false;
    }
  }

  /// Set up event handlers
  void _setupEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          developer.log(
            'Joined channel: ${connection.channelId}',
            name: 'AgoraRTC',
          );
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          developer.log('User joined: $remoteUid', name: 'AgoraRTC');
          onUserJoined?.call(remoteUid);
        },
        onUserOffline: (connection, remoteUid, reason) {
          developer.log('User offline: $remoteUid', name: 'AgoraRTC');
          onUserOffline?.call(remoteUid);
        },
        onError: (err, msg) {
          developer.log('Agora error: $err - $msg', name: 'AgoraRTC');
          onError?.call('$err: $msg');
        },
        onConnectionStateChanged: (connection, state, reason) {
          developer.log(
            'Connection state: $state, reason: $reason',
            name: 'AgoraRTC',
          );
        },
      ),
    );
  }

  /// Join a channel
  Future<bool> joinChannel({
    required String token,
    required String channelName,
    required int uid,
  }) async {
    if (!_isInitialized) {
      onError?.call('Engine not initialized');
      return false;
    }

    try {
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      await _engine.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: ChannelMediaOptions(),
      );

      developer.log('Joining channel: $channelName', name: 'AgoraRTC');
      return true;
    } catch (e) {
      developer.log('Failed to join channel: $e', name: 'AgoraRTC');
      onError?.call('Join channel failed: $e');
      return false;
    }
  }

  /// Leave channel
  Future<bool> leaveChannel() async {
    if (!_isInitialized) {
      return false;
    }

    try {
      await _engine.leaveChannel();
      developer.log('Left channel', name: 'AgoraRTC');
      return true;
    } catch (e) {
      developer.log('Failed to leave channel: $e', name: 'AgoraRTC');
      onError?.call('Leave channel failed: $e');
      return false;
    }
  }

  /// Enable/disable microphone
  Future<void> enableMicrophone(bool enabled) async {
    if (!_isInitialized) return;

    try {
      await _engine.enableLocalAudio(enabled);
      developer.log(
        'Microphone ${enabled ? 'enabled' : 'disabled'}',
        name: 'AgoraRTC',
      );
    } catch (e) {
      developer.log('Failed to toggle microphone: $e', name: 'AgoraRTC');
    }
  }

  /// Set audio volume
  Future<void> setAudioVolume(int volume) async {
    if (!_isInitialized) return;

    try {
      final clampedVolume = volume.clamp(0, 100);
      await _engine.adjustRecordingSignalVolume(clampedVolume);
      developer.log('Audio volume set to: $clampedVolume', name: 'AgoraRTC');
    } catch (e) {
      developer.log('Failed to set audio volume: $e', name: 'AgoraRTC');
    }
  }

  /// Dispose and release resources
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      await _engine.leaveChannel();
      await _engine.release();
      _isInitialized = false;
      developer.log('Agora RTC Engine disposed', name: 'AgoraRTC');
    } catch (e) {
      developer.log('Error disposing Agora: $e', name: 'AgoraRTC');
    }
  }

  /// Check if engine is initialized
  bool get isInitialized => _isInitialized;

  /// Check if running in demo mode
  bool get isDemoMode => _isDemoMode;

  /// Get RTC Engine instance
  RtcEngine get engine => _engine;
}
