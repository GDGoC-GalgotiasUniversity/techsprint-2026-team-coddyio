import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';
import '../models/plant_disease_result.dart';
import '../models/plant_status.dart';

class ApiService {
  // For Android emulator: use 10.0.2.2 to access host machine
  // For physical device: use your actual server IP
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const Duration timeout = Duration(seconds: 5);

  /// Get plant status (whether user has a plant or not)
  Future<PlantStatus?> getPlantStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/plant-status'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return PlantStatus.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('Error fetching plant status: $e');
    }
    return null;
  }

  /// Update plant status
  Future<bool> updatePlantStatus(bool hasPlant, {String? plantType}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/plant-status'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'hasPlant': hasPlant, 'plantType': plantType}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error updating plant status: $e');
    }
    return false;
  }

  Future<SensorData?> getLatestReading() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/latest'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isEmpty) return null;
        return SensorData.fromJson(data);
      }
    } on TimeoutException {
      print('Request timeout - server may be unreachable');
    } catch (e) {
      print('Error fetching latest reading: $e');
    }
    return null;
  }

  Future<List<SensorData>> getReadings({int limit = 50}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/readings?limit=$limit'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final readings = (data['readings'] as List)
            .map((item) => SensorData.fromJson(item))
            .toList();
        return readings;
      }
    } on TimeoutException {
      print('Request timeout - server may be unreachable');
    } catch (e) {
      print('Error fetching readings: $e');
    }
    return [];
  }

  /// Detect plant disease from image
  Future<PlantDiseaseResult?> detectPlantDisease(Uint8List imageBytes) async {
    try {
      final baseUrlWithoutApi = baseUrl.replaceAll('/api', '');
      final url = '$baseUrlWithoutApi/api/plant-disease/detect';

      // Convert image to base64
      final base64Image = base64Encode(imageBytes);

      final payload = {'image': base64Image};

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return PlantDiseaseResult.fromJson(data);
        }
      }
    } catch (e) {
      print('Error detecting plant disease: $e');
    }
    return null;
  }

  /// Get disease information and recommendations
  Future<Map<String, dynamic>?> getDiseaseInfo(String disease) async {
    try {
      final baseUrlWithoutApi = baseUrl.replaceAll('/api', '');
      final url = '$baseUrlWithoutApi/api/plant-disease/info/$disease';

      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        }
      }
    } catch (e) {
      print('Error getting disease info: $e');
    }
    return null;
  }

  /// Register FCM token with server
  Future<bool> registerFCMToken(String token) async {
    try {
      final baseUrlWithoutApi = baseUrl.replaceAll('/api', '');
      final url = '$baseUrlWithoutApi/api/fcm-token';

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error registering FCM token: $e');
    }
    return false;
  }
}
