import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';
import 'api_service.dart';

class GeminiService {
  late final GenerativeModel _model;
  String? _apiKey;
  String? _modelName;

  /// Initialize Gemini service by fetching credentials from server
  Future<bool> initialize() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiService.baseUrl.replaceAll('/api', '')}/api/config/credentials',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _apiKey = data['credentials']['gemini']['apiKey'];
          _modelName =
              data['credentials']['gemini']['model'] ?? 'gemini-2.5-flash';

          _model = GenerativeModel(model: _modelName!, apiKey: _apiKey!);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error initializing Gemini: $e');
      return false;
    }
  }

  Future<String> askQuestion(String question, SensorData? sensorData) async {
    if (_apiKey == null || _modelName == null) {
      final initialized = await initialize();
      if (!initialized) {
        return "Gemini service not initialized. Please check server configuration.";
      }
    }

    if (sensorData == null) {
      return "No sensor data available yet. Please wait for the first reading.";
    }

    final context =
        '''
You are an IoT sensor assistant. Answer questions about the current sensor readings.

Current Sensor Data:
- Temperature: ${sensorData.temperature.toStringAsFixed(1)}°C
- Humidity: ${sensorData.humidity.toStringAsFixed(1)}%
- Soil Moisture: ${sensorData.soilPct.toStringAsFixed(1)}% (Raw: ${sensorData.soilRaw})
- Last Updated: ${sensorData.timestamp}

Provide helpful, concise answers about the sensor data, environmental conditions, or recommendations based on these readings.

User Question: $question
''';

    try {
      final response = await _model.generateContent([Content.text(context)]);
      return response.text ?? 'Sorry, I could not generate a response.';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
