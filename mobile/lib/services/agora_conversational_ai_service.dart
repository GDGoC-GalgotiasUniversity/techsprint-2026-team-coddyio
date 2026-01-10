import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'api_service.dart';

class AgoraConversationalAIService {
  // Credentials fetched from server
  String? _appId;
  String? _customerId;
  String? _customerSecret;
  String? _geminiApiKey;
  String? _geminiModel;
  String? _cartesiaApiKey;
  String? _cartesiaModelId;
  String? _cartesiaVoiceId;

  static const String agoraApiBase =
      'https://api.agora.io/api/conversational-ai-agent/v2/projects';

  String? _agentId;
  String? _channelName;

  /// Fetch credentials from server
  Future<bool> fetchCredentials() async {
    try {
      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      final response = await http
          .get(Uri.parse('$baseUrl/api/config/credentials'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final creds = data['credentials'];

          _appId = creds['agora']['appId'];
          _customerId = creds['agora']['customerId'];
          _customerSecret = creds['agora']['customerSecret'];
          _geminiApiKey = creds['gemini']['apiKey'];
          _geminiModel = creds['gemini']['model'] ?? 'gemini-2.0-flash';
          _cartesiaApiKey = creds['cartesia']['apiKey'];
          _cartesiaModelId = creds['cartesia']['modelId'] ?? 'sonic-2';
          _cartesiaVoiceId = creds['cartesia']['voiceId'];

          developer.log(
            'Credentials fetched successfully',
            name: 'AgoraConversationalAI',
          );
          return true;
        }
      }
      developer.log(
        'Failed to fetch credentials: ${response.statusCode}',
        name: 'AgoraConversationalAI',
      );
      return false;
    } catch (e) {
      developer.log(
        'Error fetching credentials: $e',
        name: 'AgoraConversationalAI',
      );
      return false;
    }
  }

  /// Generate base64 encoded credentials for Agora API authentication
  String _generateBasicAuth() {
    final credentials = '$_customerId:$_customerSecret';
    return base64Encode(utf8.encode(credentials));
  }

  /// Start a conversational AI agent with exact Agora documentation parameters
  Future<Map<String, dynamic>> startAgent({
    required String channelName,
    required String rtcToken,
    required String systemMessage,
    String? greetingMessage,
  }) async {
    try {
      // Fetch credentials if not already fetched
      if (_appId == null) {
        final fetched = await fetchCredentials();
        if (!fetched) {
          return {
            'success': false,
            'error': 'Failed to fetch credentials from server',
          };
        }
      }

      _channelName = channelName;

      final url = '$agoraApiBase/$_appId/join';
      final basicAuth = _generateBasicAuth();

      // Build payload with exact parameters from Agora documentation
      final payload = {
        'name': 'voice_agent_${DateTime.now().millisecondsSinceEpoch}',
        'properties': {
          'channel': channelName,
          'token': rtcToken,
          'agent_rtc_uid': '0',
          'remote_rtc_uids': ['1002'],
          'enable_string_uid': false,
          'idle_timeout': 120,
          // Gemini LLM Configuration (exact format from Agora docs)
          'llm': {
            'url':
                'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:streamGenerateContent?alt=sse&key=$_geminiApiKey',
            'system_messages': [
              {
                'parts': [
                  {'text': systemMessage},
                ],
                'role': 'user',
              },
            ],
            'max_history': 32,
            'greeting_message':
                greetingMessage ??
                'Good to see you! How can I help you with your farm?',
            'failure_message': 'Hold on a second. I did not understand that.',
            'params': {'model': _geminiModel},
            'style': 'gemini',
          },
          // Automatic Speech Recognition
          'asr': {'language': 'en-US'},
          // Cartesia Text-to-Speech Configuration (exact format from Agora docs)
          'tts': {
            'vendor': 'cartesia',
            'params': {
              'api_key': _cartesiaApiKey,
              'model_id': _cartesiaModelId,
              'voice': {'mode': 'id', 'id': _cartesiaVoiceId},
              'output_format': {'container': 'raw', 'sample_rate': 16000},
              'language': 'en',
            },
          },
        },
      };

      developer.log(
        'Starting Agora Conversational AI agent',
        name: 'AgoraConversationalAI',
      );
      developer.log(
        'Channel: $channelName, Model: $_geminiModel',
        name: 'AgoraConversationalAI',
      );

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Basic $basicAuth',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _agentId = data['agent_id'];
        developer.log(
          'Agent started successfully: $_agentId',
          name: 'AgoraConversationalAI',
        );
        return {
          'success': true,
          'agent_id': _agentId,
          'status': data['status'],
          'create_ts': data['create_ts'],
        };
      } else {
        developer.log(
          'Failed to start agent: ${response.statusCode} - ${response.body}',
          name: 'AgoraConversationalAI',
        );
        return {
          'success': false,
          'error': 'Failed to start agent: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      developer.log('Error starting agent: $e', name: 'AgoraConversationalAI');
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Stop the conversational AI agent
  Future<Map<String, dynamic>> stopAgent() async {
    if (_agentId == null) {
      return {'success': false, 'error': 'No active agent to stop'};
    }

    try {
      final url = '$agoraApiBase/$_appId/agents/$_agentId/leave';
      final basicAuth = _generateBasicAuth();

      developer.log('Stopping agent: $_agentId', name: 'AgoraConversationalAI');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Basic $basicAuth',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        developer.log(
          'Agent stopped successfully: $_agentId',
          name: 'AgoraConversationalAI',
        );
        _agentId = null;
        return {'success': true, 'message': 'Agent stopped successfully'};
      } else {
        developer.log(
          'Failed to stop agent: ${response.statusCode}',
          name: 'AgoraConversationalAI',
        );
        return {
          'success': false,
          'error': 'Failed to stop agent: ${response.statusCode}',
        };
      }
    } catch (e) {
      developer.log('Error stopping agent: $e', name: 'AgoraConversationalAI');
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Query agent status
  Future<Map<String, dynamic>> queryAgentStatus() async {
    if (_agentId == null) {
      return {'success': false, 'error': 'No active agent'};
    }

    try {
      final url = '$agoraApiBase/$_appId/agents/$_agentId';
      final basicAuth = _generateBasicAuth();

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Basic $basicAuth',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'agent_id': data['agent_id'],
          'status': data['status'],
          'create_ts': data['create_ts'],
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to query status: ${response.statusCode}',
        };
      }
    } catch (e) {
      developer.log(
        'Error querying agent status: $e',
        name: 'AgoraConversationalAI',
      );
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Get current agent ID
  String? get agentId => _agentId;

  /// Check if agent is active
  bool get isAgentActive => _agentId != null;

  /// Get channel name
  String? get channelName => _channelName;
}
