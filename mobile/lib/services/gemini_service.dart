import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/sensor_data.dart';

class GeminiService {
  // Replace with your Gemini API key from https://makersuite.google.com/app/apikey
  static const String
  apiKey = 'AIzaSyBNdTjEonDMxXgJqjXCdgXHGInBMRLlz70';

  late final GenerativeModel
  _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  Future<
    String
  >
  askQuestion(
    String question,
    SensorData? sensorData,
  ) async {
    if (sensorData ==
        null) {
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
      final response = await _model.generateContent(
        [
          Content.text(
            context,
          ),
        ],
      );
      return response.text ??
          'Sorry, I could not generate a response.';
    } catch (
      e
    ) {
      return 'Error: ${e.toString()}';
    }
  }
}
