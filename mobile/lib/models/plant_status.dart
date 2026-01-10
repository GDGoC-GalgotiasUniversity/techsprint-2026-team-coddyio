class PlantStatus {
  final bool hasPlant;
  final String? plantType;
  final DateTime? lastUpdated;

  PlantStatus({required this.hasPlant, this.plantType, this.lastUpdated});

  factory PlantStatus.fromJson(Map<String, dynamic> json) {
    return PlantStatus(
      hasPlant: json['hasPlant'] ?? false,
      plantType: json['plantType'],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasPlant': hasPlant,
      'plantType': plantType,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }
}
