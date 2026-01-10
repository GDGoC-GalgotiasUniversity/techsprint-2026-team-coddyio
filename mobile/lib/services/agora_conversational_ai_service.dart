import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'api_service.dart';

class AgoraConversationalAIService {
  String? _agentId;
  String? _channelName;

  /// Start a conversational AI agent via server endpoint
  Future<Map<String, dynamic>> startAgent({
    required String channelName,
    required String rtcToken,
    required String systemMessage,
    String? greetingMessage,
  }) async {
    try {
      _channelName = channelName;

      // Call server endpoint instead of Agora API directly
      // Server handles token generation with RTM2 privileges
      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      final url = '$baseUrl/api/agora-ai/start-agent';

      final agentName = 'voice_agent_${DateTime.now().millisecondsSinceEpoch}';

      final payload = {
        'channelName': channelName,
        'agentName': agentName,
        'systemMessages': [
          {
            'parts': [
              {'text': systemMessage},
            ],
            'role': 'user',
          },
        ],
      };

      developer.log(
        '🤖 Starting Agora Conversational AI agent via server',
        name: 'AgoraConversationalAI',
      );
      developer.log(
        'Channel: $channelName, Agent: $agentName',
        name: 'AgoraConversationalAI',
      );
      developer.log('URL: $url', name: 'AgoraConversationalAI');
      developer.log(
        'Payload: ${jsonEncode(payload)}',
        name: 'AgoraConversationalAI',
      );

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      developer.log(
        '📡 Server response status: ${response.statusCode}',
        name: 'AgoraConversationalAI',
      );
      developer.log(
        '📡 Server response body: ${response.body}',
        name: 'AgoraConversationalAI',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          _agentId = data['agentId'];
          developer.log(
            '✅ Agent started successfully: $_agentId',
            name: 'AgoraConversationalAI',
          );
          developer.log(
            'Status: ${data['status']}, Created: ${data['createdAt']}',
            name: 'AgoraConversationalAI',
          );
          return {
            'success': true,
            'agent_id': _agentId,
            'status': data['status'],
            'create_ts': data['createdAt'],
          };
        } else {
          developer.log(
            '❌ Server returned error: ${data['error']}',
            name: 'AgoraConversationalAI',
          );
          return {
            'success': false,
            'error': data['error'] ?? 'Unknown error from server',
          };
        }
      } else {
        developer.log(
          '❌ Server returned status ${response.statusCode}: ${response.body}',
          name: 'AgoraConversationalAI',
        );
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      developer.log(
        '❌ Error starting agent: $e',
        name: 'AgoraConversationalAI',
      );
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Stop the conversational AI agent
  Future<Map<String, dynamic>> stopAgent() async {
    if (_agentId == null) {
      return {'success': false, 'error': 'No active agent to stop'};
    }

    try {
      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      final url = '$baseUrl/api/agora-ai/stop-agent';

      developer.log(
        '🛑 Stopping agent: $_agentId',
        name: 'AgoraConversationalAI',
      );

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'agentId': _agentId}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        developer.log(
          '✅ Agent stopped successfully: $_agentId',
          name: 'AgoraConversationalAI',
        );
        _agentId = null;
        return {'success': true, 'message': 'Agent stopped successfully'};
      } else {
        developer.log(
          '❌ Failed to stop agent: ${response.statusCode}',
          name: 'AgoraConversationalAI',
        );
        return {
          'success': false,
          'error': 'Failed to stop agent: ${response.statusCode}',
        };
      }
    } catch (e) {
      developer.log(
        '❌ Error stopping agent: $e',
        name: 'AgoraConversationalAI',
      );
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Query agent status
  Future<Map<String, dynamic>> queryAgentStatus() async {
    if (_agentId == null) {
      return {'success': false, 'error': 'No active agent'};
    }

    try {
      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      final url = '$baseUrl/api/agora-ai/agent-status/$_agentId';

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'agent_id': data['agentId'],
          'status': data['status'],
          'create_ts': data['createdAt'],
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
