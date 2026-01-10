import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'api_service.dart';

class PlantDiseaseService {
  /// Detect plant disease from image
  Future<Map<String, dynamic>> detectDisease(Uint8List imageBytes) async {
    try {
      developer.log(
        '🌱 Detecting plant disease from image...',
        name: 'PlantDiseaseService',
      );

      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      final url = '$baseUrl/api/plant-disease/detect';

      // Convert image to base64
      final base64Image = base64Encode(imageBytes);

      final payload = {'image': base64Image};

      developer.log(
        'Image size: ${imageBytes.length} bytes',
        name: 'PlantDiseaseService',
      );

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 60));

      developer.log(
        '📡 Server response status: ${response.statusCode}',
        name: 'PlantDiseaseService',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          developer.log(
            '✅ Disease detected: ${data['prediction']}',
            name: 'PlantDiseaseService',
          );
          developer.log(
            '📊 Confidence: ${(data['confidence'] * 100).toStringAsFixed(2)}%',
            name: 'PlantDiseaseService',
          );

          return {
            'success': true,
            'prediction': data['prediction'],
            'confidence': data['confidence'],
            'class_index': data['class_index'],
            'is_healthy': data['is_healthy'],
            'top_predictions': data['top_predictions'],
          };
        } else {
          developer.log(
            '❌ Detection failed: ${data['error']}',
            name: 'PlantDiseaseService',
          );
          return {'success': false, 'error': data['error'] ?? 'Unknown error'};
        }
      } else {
        developer.log(
          '❌ Server error: ${response.statusCode}',
          name: 'PlantDiseaseService',
        );
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      developer.log(
        '❌ Error detecting disease: $e',
        name: 'PlantDiseaseService',
      );
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Get disease information and recommendations
  Future<Map<String, dynamic>> getDiseaseInfo(String disease) async {
    try {
      developer.log(
        '📖 Getting disease information for: $disease',
        name: 'PlantDiseaseService',
      );

      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      final url = '$baseUrl/api/plant-disease/info/$disease';

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          developer.log(
            '✅ Disease info retrieved',
            name: 'PlantDiseaseService',
          );

          return {
            'success': true,
            'plant': data['plant'],
            'condition': data['condition'],
            'is_healthy': data['is_healthy'],
            'recommendations': data['recommendations'],
          };
        } else {
          return {'success': false, 'error': data['error'] ?? 'Unknown error'};
        }
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      developer.log(
        '❌ Error getting disease info: $e',
        name: 'PlantDiseaseService',
      );
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  /// Format disease name for display
  String formatDiseaseName(String disease) {
    final parts = disease.split('___');
    if (parts.length == 2) {
      final plant = parts[0].replaceAll('_', ' ');
      final condition = parts[1].replaceAll('_', ' ');
      return '$plant - $condition';
    }
    return disease.replaceAll('_', ' ');
  }

  /// Get confidence percentage
  String getConfidencePercentage(double confidence) {
    return '${(confidence * 100).toStringAsFixed(2)}%';
  }

  /// Check if disease is healthy
  bool isHealthy(String disease) {
    return disease.toLowerCase().contains('healthy');
  }
}
