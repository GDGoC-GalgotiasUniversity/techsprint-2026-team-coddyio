class SensorData {
  final String
  id;
  final double
  temperature;
  final double
  humidity;
  final int
  soilRaw;
  final double
  soilPct;
  final DateTime
  timestamp;

  SensorData({
    required this.id,
    required this.temperature,
    required this.humidity,
    required this.soilRaw,
    required this.soilPct,
    required this.timestamp,
  });

  factory SensorData.fromJson(
    Map<
      String,
      dynamic
    >
    json,
  ) {
    return SensorData(
      id:
          json['_id'] ??
          '',
      temperature:
          (json['temperature'] ??
                  0)
              .toDouble(),
      humidity:
          (json['humidity'] ??
                  0)
              .toDouble(),
      soilRaw:
          json['soil_raw'] ??
          0,
      soilPct:
          (json['soil_pct'] ??
                  0)
              .toDouble(),
      timestamp: DateTime.parse(
        json['timestamp'] ??
            DateTime.now().toIso8601String(),
      ),
    );
  }
}
