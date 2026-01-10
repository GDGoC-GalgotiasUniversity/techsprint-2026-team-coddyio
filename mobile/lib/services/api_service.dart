import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';

class ApiService {
  // Change this to your server IP address
  static const String
  baseUrl = 'http://10.10.180.11:3000/api';
  static const Duration
  timeout = Duration(
    seconds: 5,
  );

  Future<
    SensorData?
  >
  getLatestReading() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/latest',
            ),
          )
          .timeout(
            timeout,
          );

      if (response.statusCode ==
          200) {
        final data = json.decode(
          response.body,
        );
        if (data.isEmpty) return null;
        return SensorData.fromJson(
          data,
        );
      }
    } on TimeoutException {
      print(
        'Request timeout - server may be unreachable',
      );
    } catch (
      e
    ) {
      print(
        'Error fetching latest reading: $e',
      );
    }
    return null;
  }

  Future<
    List<
      SensorData
    >
  >
  getReadings({
    int limit = 50,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/readings?limit=$limit',
            ),
          )
          .timeout(
            timeout,
          );

      if (response.statusCode ==
          200) {
        final data = json.decode(
          response.body,
        );
        final readings =
            (data['readings']
                    as List)
                .map(
                  (
                    item,
                  ) => SensorData.fromJson(
                    item,
                  ),
                )
                .toList();
        return readings;
      }
    } on TimeoutException {
      print(
        'Request timeout - server may be unreachable',
      );
    } catch (
      e
    ) {
      print(
        'Error fetching readings: $e',
      );
    }
    return [];
  }
}
