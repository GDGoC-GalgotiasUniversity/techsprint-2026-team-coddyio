import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';
import '../models/voice_session.dart';
import '../services/agora_rtc_service.dart';
import '../services/agora_conversational_ai_service.dart';
import '../services/voice_permission_service.dart';
import '../services/api_service.dart';

class VoiceAgentScreen extends StatefulWidget {
  final SensorData? sensorData;

  const VoiceAgentScreen({super.key, this.sensorData});

  @override
  State<VoiceAgentScreen> createState() => _VoiceAgentScreenState();
}

class _VoiceAgentScreenState extends State<VoiceAgentScreen> {
  late AgoraRtcService _agoraRtcService;
  late AgoraConversationalAIService _agoraAIService;

  VoiceSession? _currentSession;
  bool _isInitializing = false;
  bool _isSessionActive = false;
  bool _isMicrophoneEnabled = true;
  String _statusMessage = 'Ready to start voice session';
  Timer? _sessionTimer;
  Duration _sessionDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _agoraRtcService = AgoraRtcService();
    _agoraAIService = AgoraConversationalAIService();
    _setupEventHandlers();
    _requestPermissionsOnInit();
  }

  /// Request microphone permission on screen init
  Future<void> _requestPermissionsOnInit() async {
    final hasPermission =
        await VoicePermissionService.isMicrophonePermissionGranted();
    if (!hasPermission) {
      if (mounted) {
        _showPermissionDialog();
      }
    }
  }

  /// Show permission request dialog
  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
          'The voice agent needs microphone access to hear your questions and respond with voice. '
          'Please grant microphone permission to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final granted =
                  await VoicePermissionService.requestMicrophonePermission();
              if (mounted) {
                setState(() {
                  _statusMessage = granted
                      ? 'Permission granted - Ready to start'
                      : 'Permission denied - Cannot use voice agent';
                });
              }
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  void _setupEventHandlers() {
    _agoraRtcService.onUserJoined = (uid) {
      setState(() {
        _statusMessage = 'Agent joined (UID: $uid)';
      });
    };

    _agoraRtcService.onUserOffline = (uid) {
      setState(() {
        _statusMessage = 'Agent disconnected';
      });
    };

    _agoraRtcService.onError = (error) {
      setState(() {
        _statusMessage = 'Error: $error';
      });
      _showErrorDialog(error);
    };
  }

  /// Start voice agent session
  Future<void> _startVoiceSession() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
      _statusMessage = 'Checking permissions...';
    });

    try {
      // Check and request permissions
      final hasPermission =
          await VoicePermissionService.requestAllVoicePermissions();
      if (!hasPermission) {
        setState(() {
          _statusMessage = 'Microphone permission denied';
          _isInitializing = false;
        });
        _showErrorDialog('Microphone permission is required for voice agent');
        return;
      }

      setState(() {
        _statusMessage = 'Initializing Agora...';
      });

      // Initialize Agora RTC
      final rtcInitialized = await _agoraRtcService.initialize();
      if (!rtcInitialized) {
        throw Exception('Failed to initialize Agora RTC');
      }

      // Check if running in demo mode
      if (_agoraRtcService.isDemoMode) {
        setState(() {
          _statusMessage =
              'Demo Mode: Configure server/.env with real Agora credentials';
          _isInitializing = false;
        });
        _showErrorDialog(
          'Demo Mode Active\n\n'
          'To use the voice agent, please:\n\n'
          '1. Get Agora credentials from https://console.agora.io\n'
          '2. Update server/.env with:\n'
          '   - AGORA_APP_ID\n'
          '   - AGORA_CUSTOMER_ID\n'
          '   - AGORA_CUSTOMER_SECRET\n'
          '   - AGORA_APP_CERTIFICATE\n'
          '3. Restart the server\n'
          '4. Restart the app',
        );
        return;
      }

      setState(() {
        _statusMessage = 'Generating RTC token...';
      });

      // Generate RTC token from server
      final channelName =
          'voice_agent_${DateTime.now().millisecondsSinceEpoch}';
      final rtcToken = await _generateRtcToken(channelName, 1002);

      setState(() {
        _statusMessage = 'Joining channel...';
      });

      // Join RTC channel
      final joined = await _agoraRtcService.joinChannel(
        token: rtcToken,
        channelName: channelName,
        uid: 1002, // User UID
      );

      if (!joined) {
        throw Exception('Failed to join RTC channel');
      }

      setState(() {
        _statusMessage = 'Starting AI agent...';
      });

      // Start conversational AI agent
      final systemMessage = _buildSystemMessage();
      final agentResult = await _agoraAIService.startAgent(
        channelName: channelName,
        rtcToken: rtcToken,
        systemMessage: systemMessage,
        greetingMessage:
            'Hello! I am your agricultural assistant. How can I help you with your farm today?',
      );

      if (!agentResult['success']) {
        throw Exception(agentResult['error'] ?? 'Failed to start agent');
      }

      // Create voice session
      _currentSession = VoiceSession(
        sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
        channelName: channelName,
        rtcToken: rtcToken,
        agentId: agentResult['agent_id'],
        startTime: DateTime.now(),
      );

      setState(() {
        _isSessionActive = true;
        _statusMessage = 'Voice session active - Speak now!';
        _isInitializing = false;
      });

      // Start session timer
      _startSessionTimer();
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
        _isInitializing = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  /// Stop voice agent session
  Future<void> _stopVoiceSession() async {
    try {
      setState(() {
        _statusMessage = 'Stopping session...';
      });

      // Stop AI agent
      if (_agoraAIService.isAgentActive) {
        await _agoraAIService.stopAgent();
      }

      // Leave RTC channel
      await _agoraRtcService.leaveChannel();

      // Stop session timer
      _sessionTimer?.cancel();

      setState(() {
        _isSessionActive = false;
        _statusMessage = 'Session ended';
        _sessionDuration = Duration.zero;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error stopping session: $e';
      });
      _showErrorDialog(e.toString());
    }
  }

  /// Toggle microphone
  Future<void> _toggleMicrophone() async {
    try {
      _isMicrophoneEnabled = !_isMicrophoneEnabled;
      await _agoraRtcService.enableMicrophone(_isMicrophoneEnabled);

      setState(() {
        _statusMessage = _isMicrophoneEnabled
            ? 'Microphone enabled'
            : 'Microphone muted';
      });
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  /// Start session timer
  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _sessionDuration = _currentSession?.duration ?? Duration.zero;
      });
    });
  }

  /// Build system message with sensor context
  String _buildSystemMessage() {
    if (widget.sensorData == null) {
      return '''You are an expert agricultural assistant for IoT-based farm monitoring. 
Help farmers understand their sensor data and provide actionable recommendations.
Be concise, friendly, and practical in your responses.''';
    }

    final sensor = widget.sensorData!;
    return '''You are an expert agricultural assistant for IoT-based farm monitoring.
Current farm conditions:
- Temperature: ${sensor.temperature.toStringAsFixed(1)}°C
- Humidity: ${sensor.humidity.toStringAsFixed(1)}%
- Soil Moisture: ${sensor.soilPct.toStringAsFixed(1)}%
- Last Updated: ${sensor.timestamp}

Help farmers understand their sensor data and provide actionable recommendations based on these readings.
Be concise, friendly, and practical in your responses.''';
  }

  /// Generate RTC token from server
  Future<String> _generateRtcToken(String channelName, int uid) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiService.baseUrl.replaceAll('/api', '')}/api/rtc-token',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'channelName': channelName, 'uid': uid}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['token'];
        }
      }
      throw Exception('Failed to generate token: ${response.statusCode}');
    } catch (e) {
      throw Exception('Token generation error: $e');
    }
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Format duration
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _agoraRtcService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Agent'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Session Status Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Status indicator
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isSessionActive
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.2),
                          border: Border.all(
                            color: _isSessionActive
                                ? Colors.green
                                : Colors.grey,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _isSessionActive ? Icons.mic : Icons.mic_none,
                            size: 40,
                            color: _isSessionActive
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Status message
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      // Session duration
                      if (_isSessionActive)
                        Text(
                          'Duration: ${_formatDuration(_sessionDuration)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sensor Data Display
              if (widget.sensorData != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Farm Conditions',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 12),
                        _buildSensorRow(
                          'Temperature',
                          '${widget.sensorData!.temperature.toStringAsFixed(1)}°C',
                          Icons.thermostat,
                        ),
                        _buildSensorRow(
                          'Humidity',
                          '${widget.sensorData!.humidity.toStringAsFixed(1)}%',
                          Icons.opacity,
                        ),
                        _buildSensorRow(
                          'Soil Moisture',
                          '${widget.sensorData!.soilPct.toStringAsFixed(1)}%',
                          Icons.water_drop,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Control Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSessionActive ? null : _startVoiceSession,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Session'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.green,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSessionActive ? _stopVoiceSession : null,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop Session'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.red,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Microphone Toggle
              if (_isSessionActive)
                ElevatedButton.icon(
                  onPressed: _toggleMicrophone,
                  icon: Icon(_isMicrophoneEnabled ? Icons.mic : Icons.mic_off),
                  label: Text(
                    _isMicrophoneEnabled
                        ? 'Mute Microphone'
                        : 'Unmute Microphone',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: _isMicrophoneEnabled
                        ? Colors.blue
                        : Colors.orange,
                  ),
                ),
              const SizedBox(height: 24),

              // Info Card
              Card(
                elevation: 1,
                color: Colors.blue.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How to Use',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Tap "Start Session" to begin\n'
                        '2. Wait for the agent to greet you\n'
                        '3. Speak your questions naturally\n'
                        '4. The agent will respond with recommendations\n'
                        '5. Tap "Stop Session" when done',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
