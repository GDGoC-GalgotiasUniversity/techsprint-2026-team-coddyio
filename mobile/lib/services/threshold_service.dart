import 'package:shared_preferences/shared_preferences.dart';
import '../models/sensor_data.dart';

class SensorThresholds {
  // Soil Moisture (%)
  static const double SOIL_CRITICAL_LOW = 20;
  static const double SOIL_WARNING_LOW = 30;
  static const double SOIL_OPTIMAL_MIN = 40;
  static const double SOIL_OPTIMAL_MAX = 70;
  static const double SOIL_WARNING_HIGH = 80;
  static const double SOIL_CRITICAL_HIGH = 90;

  // Temperature (°C)
  static const double TEMP_CRITICAL_LOW = 5;
  static const double TEMP_WARNING_LOW = 10;
  static const double TEMP_OPTIMAL_MIN = 15;
  static const double TEMP_OPTIMAL_MAX = 30;
  static const double TEMP_WARNING_HIGH = 35;
  static const double TEMP_CRITICAL_HIGH = 40;

  // Humidity (%)
  static const double HUMIDITY_CRITICAL_LOW = 20;
  static const double HUMIDITY_WARNING_LOW = 30;
  static const double HUMIDITY_OPTIMAL_MIN = 40;
  static const double HUMIDITY_OPTIMAL_MAX = 70;
  static const double HUMIDITY_WARNING_HIGH = 80;
  static const double HUMIDITY_CRITICAL_HIGH = 95;
}

enum AlertType {
  SOIL_CRITICAL_LOW,
  SOIL_WARNING_LOW,
  SOIL_WARNING_HIGH,
  SOIL_CRITICAL_HIGH,
  TEMP_CRITICAL_LOW,
  TEMP_WARNING_LOW,
  TEMP_WARNING_HIGH,
  TEMP_CRITICAL_HIGH,
  HUMIDITY_CRITICAL_LOW,
  HUMIDITY_WARNING_LOW,
  HUMIDITY_WARNING_HIGH,
  HUMIDITY_CRITICAL_HIGH,
}

class AlertInfo {
  final AlertType type;
  final String title;
  final String message;
  final String emoji;
  final bool isCritical;
  final String sensorType;
  final double value;
  final String unit;

  AlertInfo({
    required this.type,
    required this.title,
    required this.message,
    required this.emoji,
    required this.isCritical,
    required this.sensorType,
    required this.value,
    required this.unit,
  });
}

class ThresholdService {
  static final ThresholdService _instance = ThresholdService._internal();
  static const int NOTIFICATION_COOLDOWN_MINUTES = 30;

  factory ThresholdService() {
    return _instance;
  }

  ThresholdService._internal();

  /// Check sensor data against thresholds
  Future<List<AlertInfo>> checkThresholds(SensorData data) async {
    final alerts = <AlertInfo>[];

    // Check soil moisture
    final soilAlerts = _checkSoilMoisture(data.soilPct);
    alerts.addAll(soilAlerts);

    // Check temperature
    final tempAlerts = _checkTemperature(data.temperature);
    alerts.addAll(tempAlerts);

    // Check humidity
    final humidityAlerts = _checkHumidity(data.humidity);
    alerts.addAll(humidityAlerts);

    // Filter out alerts that were recently sent
    final filteredAlerts = await _filterRecentAlerts(alerts);

    return filteredAlerts;
  }

  /// Check soil moisture thresholds
  List<AlertInfo> _checkSoilMoisture(double soilPct) {
    final alerts = <AlertInfo>[];

    if (soilPct <= SensorThresholds.SOIL_CRITICAL_LOW) {
      alerts.add(
        AlertInfo(
          type: AlertType.SOIL_CRITICAL_LOW,
          title: '🚨 Urgent: Water Your Plant NOW',
          message:
              'Soil moisture is critically low at ${soilPct.toStringAsFixed(1)}%. Your plant needs water immediately!',
          emoji: '🚨',
          isCritical: true,
          sensorType: 'Soil Moisture',
          value: soilPct,
          unit: '%',
        ),
      );
    } else if (soilPct <= SensorThresholds.SOIL_WARNING_LOW) {
      alerts.add(
        AlertInfo(
          type: AlertType.SOIL_WARNING_LOW,
          title: '⚠️ Water Your Plant Soon',
          message:
              'Soil moisture is low at ${soilPct.toStringAsFixed(1)}%. Water your plant in the next few hours.',
          emoji: '⚠️',
          isCritical: false,
          sensorType: 'Soil Moisture',
          value: soilPct,
          unit: '%',
        ),
      );
    } else if (soilPct >= SensorThresholds.SOIL_CRITICAL_HIGH) {
      alerts.add(
        AlertInfo(
          type: AlertType.SOIL_CRITICAL_HIGH,
          title: '🚨 Urgent: Drain Excess Water',
          message:
              'Soil moisture is critically high at ${soilPct.toStringAsFixed(1)}%. Risk of root rot! Improve drainage immediately.',
          emoji: '🚨',
          isCritical: true,
          sensorType: 'Soil Moisture',
          value: soilPct,
          unit: '%',
        ),
      );
    } else if (soilPct >= SensorThresholds.SOIL_WARNING_HIGH) {
      alerts.add(
        AlertInfo(
          type: AlertType.SOIL_WARNING_HIGH,
          title: '⚠️ Soil Too Wet',
          message:
              'Soil moisture is high at ${soilPct.toStringAsFixed(1)}%. Reduce watering to prevent root rot.',
          emoji: '⚠️',
          isCritical: false,
          sensorType: 'Soil Moisture',
          value: soilPct,
          unit: '%',
        ),
      );
    }

    return alerts;
  }

  /// Check temperature thresholds
  List<AlertInfo> _checkTemperature(double temp) {
    final alerts = <AlertInfo>[];

    if (temp <= SensorThresholds.TEMP_CRITICAL_LOW) {
      alerts.add(
        AlertInfo(
          type: AlertType.TEMP_CRITICAL_LOW,
          title: '🚨 Frost Risk!',
          message:
              'Temperature is critically low at ${temp.toStringAsFixed(1)}°C. Frost risk! Protect your plant immediately.',
          emoji: '🚨',
          isCritical: true,
          sensorType: 'Temperature',
          value: temp,
          unit: '°C',
        ),
      );
    } else if (temp <= SensorThresholds.TEMP_WARNING_LOW) {
      alerts.add(
        AlertInfo(
          type: AlertType.TEMP_WARNING_LOW,
          title: '⚠️ Temperature Too Low',
          message:
              'Temperature is low at ${temp.toStringAsFixed(1)}°C. Cold stress risk. Consider protection.',
          emoji: '⚠️',
          isCritical: false,
          sensorType: 'Temperature',
          value: temp,
          unit: '°C',
        ),
      );
    } else if (temp >= SensorThresholds.TEMP_CRITICAL_HIGH) {
      alerts.add(
        AlertInfo(
          type: AlertType.TEMP_CRITICAL_HIGH,
          title: '🚨 Critical Heat!',
          message:
              'Temperature is critically high at ${temp.toStringAsFixed(1)}°C. Heat stress! Provide shade immediately.',
          emoji: '🚨',
          isCritical: true,
          sensorType: 'Temperature',
          value: temp,
          unit: '°C',
        ),
      );
    } else if (temp >= SensorThresholds.TEMP_WARNING_HIGH) {
      alerts.add(
        AlertInfo(
          type: AlertType.TEMP_WARNING_HIGH,
          title: '⚠️ Temperature Too High',
          message:
              'Temperature is high at ${temp.toStringAsFixed(1)}°C. Heat stress risk. Provide shade or water.',
          emoji: '⚠️',
          isCritical: false,
          sensorType: 'Temperature',
          value: temp,
          unit: '°C',
        ),
      );
    }

    return alerts;
  }

  /// Check humidity thresholds
  List<AlertInfo> _checkHumidity(double humidity) {
    final alerts = <AlertInfo>[];

    if (humidity <= SensorThresholds.HUMIDITY_CRITICAL_LOW) {
      alerts.add(
        AlertInfo(
          type: AlertType.HUMIDITY_CRITICAL_LOW,
          title: '🚨 Severe Drought Stress',
          message:
              'Humidity is critically low at ${humidity.toStringAsFixed(1)}%. Severe drought stress! Increase watering.',
          emoji: '🚨',
          isCritical: true,
          sensorType: 'Humidity',
          value: humidity,
          unit: '%',
        ),
      );
    } else if (humidity <= SensorThresholds.HUMIDITY_WARNING_LOW) {
      alerts.add(
        AlertInfo(
          type: AlertType.HUMIDITY_WARNING_LOW,
          title: '⚠️ Low Humidity',
          message:
              'Humidity is low at ${humidity.toStringAsFixed(1)}%. Increase watering or mist leaves.',
          emoji: '⚠️',
          isCritical: false,
          sensorType: 'Humidity',
          value: humidity,
          unit: '%',
        ),
      );
    } else if (humidity >= SensorThresholds.HUMIDITY_CRITICAL_HIGH) {
      alerts.add(
        AlertInfo(
          type: AlertType.HUMIDITY_CRITICAL_HIGH,
          title: '🚨 Fungal Disease Risk!',
          message:
              'Humidity is critically high at ${humidity.toStringAsFixed(1)}%. Severe fungal disease risk! Improve ventilation.',
          emoji: '🚨',
          isCritical: true,
          sensorType: 'Humidity',
          value: humidity,
          unit: '%',
        ),
      );
    } else if (humidity >= SensorThresholds.HUMIDITY_WARNING_HIGH) {
      alerts.add(
        AlertInfo(
          type: AlertType.HUMIDITY_WARNING_HIGH,
          title: '⚠️ High Humidity',
          message:
              'Humidity is high at ${humidity.toStringAsFixed(1)}%. Fungal disease risk. Improve air circulation.',
          emoji: '⚠️',
          isCritical: false,
          sensorType: 'Humidity',
          value: humidity,
          unit: '%',
        ),
      );
    }

    return alerts;
  }

  /// Filter out alerts that were recently sent
  Future<List<AlertInfo>> _filterRecentAlerts(List<AlertInfo> alerts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final filtered = <AlertInfo>[];

      for (final alert in alerts) {
        try {
          final key = 'alert_${alert.type.toString()}';
          final lastSentStr = prefs.getString(key);

          if (lastSentStr == null) {
            // Never sent before
            filtered.add(alert);
            try {
              await prefs.setString(key, now.toIso8601String());
            } catch (e) {
              print('⚠️ Error saving alert timestamp: $e');
            }
          } else {
            final lastSent = DateTime.parse(lastSentStr);
            final diff = now.difference(lastSent);

            if (diff.inMinutes >= NOTIFICATION_COOLDOWN_MINUTES) {
              // Enough time has passed
              filtered.add(alert);
              try {
                await prefs.setString(key, now.toIso8601String());
              } catch (e) {
                print('⚠️ Error updating alert timestamp: $e');
              }
            }
          }
        } catch (e) {
          print('⚠️ Error processing alert: $e');
          // If there's an error, include the alert anyway
          filtered.add(alert);
        }
      }

      return filtered;
    } catch (e) {
      print('⚠️ Error filtering alerts (returning all): $e');
      // If SharedPreferences fails, return all alerts
      return alerts;
    }
  }

  /// Reset alert cooldown (for testing)
  Future<void> resetAlertCooldown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('alert_')) {
          await prefs.remove(key);
        }
      }
      print('✅ Alert cooldown reset');
    } catch (e) {
      print('Error resetting alert cooldown: $e');
    }
  }

  /// Get alert history
  Future<Map<String, String>> getAlertHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = <String, String>{};
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith('alert_')) {
          final value = prefs.getString(key);
          if (value != null) {
            history[key] = value;
          }
        }
      }

      return history;
    } catch (e) {
      print('Error getting alert history: $e');
      return {};
    }
  }
}
