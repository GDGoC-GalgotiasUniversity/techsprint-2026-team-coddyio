import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';
import '../models/plant_status.dart';
import 'api_service.dart';

class GeminiService {
  GenerativeModel? _model;
  String? _apiKey;
  String? _modelName;
  bool _isInitializing = false;

  /// Initialize Gemini service by fetching credentials from server
  Future<bool> initialize() async {
    // If already initialized, return true
    if (_model != null) {
      return true;
    }

    // If currently initializing, wait for it to complete
    if (_isInitializing) {
      int attempts = 0;
      while (_model == null && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      return _model != null;
    }

    _isInitializing = true;

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
              data['credentials']['gemini']['model'] ?? 'gemini-1.5-flash';

          _model = GenerativeModel(model: _modelName!, apiKey: _apiKey!);
          _isInitializing = false;
          return true;
        }
      }
      _isInitializing = false;
      return false;
    } catch (e) {
      print('Error initializing Gemini: $e');
      _isInitializing = false;
      return false;
    }
  }

  Future<String> askQuestion(
    String question,
    SensorData? sensorData, {
    PlantStatus? plantStatus,
  }) async {
    if (_model == null) {
      final initialized = await initialize();
      if (!initialized) {
        return "Gemini service not initialized. Please check server configuration.";
      }
    }

    if (sensorData == null) {
      return "No sensor data available yet. Please wait for the first reading.";
    }

    // Build plant-specific context
    String plantContext = '';
    String plantAdvice = '';

    if (plantStatus != null && plantStatus.hasPlant) {
      final plantName = plantStatus.plantType ?? 'your plant';
      plantContext =
          '''
🌱 Plant Information:
- Plant Type: $plantName
- Status: Active monitoring

You are providing care advice specifically for $plantName based on current conditions.
''';

      // Add plant-specific guidance
      plantAdvice =
          '''

PLANT-SPECIFIC GUIDANCE FOR $plantName:
- Tailor all recommendations to $plantName's specific needs
- Consider optimal temperature, humidity, and soil moisture ranges for $plantName
- Provide specific care tips relevant to $plantName
- Mention any seasonal considerations for $plantName
''';
    } else {
      plantContext = '''
Plant Information:
- Status: No plant currently being monitored

Provide general environmental and agricultural recommendations.
''';
    }

    final context =
        '''
You are an expert agricultural assistant for IoT-based farm monitoring. Answer questions about sensor readings and provide practical, actionable advice.

$plantContext

Current Sensor Data:
- Temperature: ${sensorData.temperature.toStringAsFixed(1)}°C
- Humidity: ${sensorData.humidity.toStringAsFixed(1)}%
- Soil Moisture: ${sensorData.soilPct.toStringAsFixed(1)}% (Raw: ${sensorData.soilRaw})
- Last Updated: ${sensorData.timestamp}

RESPONSE GUIDELINES:
- Use simple, layman-friendly language (no scientific jargon)
- Keep responses short and practical
- Provide specific, actionable recommendations
- Use home remedies and household items when suggesting treatments
- Be encouraging and supportive$plantAdvice

User Question: $question
''';

    try {
      final response = await _model!.generateContent([Content.text(context)]);
      return response.text ?? 'Sorry, I could not generate a response.';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  /// Get home remedies for plant disease
  Future<String> getRemedieSuggestions(String prompt) async {
    if (_model == null) {
      final initialized = await initialize();
      if (!initialized) {
        return "Gemini service not initialized. Please check server configuration.";
      }
    }

    try {
      print('📤 Sending prompt to Gemini: ${_modelName}');
      final response = await _model!.generateContent(
        [Content.text(prompt)],
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
      );

      final result = response.text ?? 'Sorry, I could not generate remedies.';
      print('📥 Received response from Gemini: ${result.substring(0, 100)}...');
      return result;
    } catch (e) {
      print('❌ Gemini error: $e');
      return 'Error generating remedies: ${e.toString()}';
    }
  }
}
