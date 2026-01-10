class PlantDiseaseResult {
  final String prediction;
  final double confidence;
  final int classIndex;
  final bool isHealthy;
  final List<TopPrediction> topPredictions;

  PlantDiseaseResult({
    required this.prediction,
    required this.confidence,
    required this.classIndex,
    required this.isHealthy,
    required this.topPredictions,
  });

  factory PlantDiseaseResult.fromJson(Map<String, dynamic> json) {
    return PlantDiseaseResult(
      prediction: json['prediction'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0).toDouble(),
      classIndex: json['class_index'] ?? 0,
      isHealthy: json['is_healthy'] ?? false,
      topPredictions:
          (json['top_predictions'] as List?)
              ?.map((p) => TopPrediction.fromJson(p))
              .toList() ??
          [],
    );
  }

  String get formattedPrediction {
    final parts = prediction.split('___');
    if (parts.length == 2) {
      final plant = parts[0].replaceAll('_', ' ');
      final condition = parts[1].replaceAll('_', ' ');
      return '$plant - $condition';
    }
    return prediction.replaceAll('_', ' ');
  }

  String get confidencePercentage {
    return '${(confidence * 100).toStringAsFixed(2)}%';
  }

  String get plant {
    final parts = prediction.split('___');
    return parts.isNotEmpty ? parts[0].replaceAll('_', ' ') : 'Unknown';
  }

  String get condition {
    final parts = prediction.split('___');
    return parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Unknown';
  }
}

class TopPrediction {
  final String className;
  final double confidence;

  TopPrediction({required this.className, required this.confidence});

  factory TopPrediction.fromJson(Map<String, dynamic> json) {
    return TopPrediction(
      className: json['class'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }

  String get formattedClass {
    final parts = className.split('___');
    if (parts.length == 2) {
      final plant = parts[0].replaceAll('_', ' ');
      final condition = parts[1].replaceAll('_', ' ');
      return '$plant - $condition';
    }
    return className.replaceAll('_', ' ');
  }

  String get confidencePercentage {
    return '${(confidence * 100).toStringAsFixed(2)}%';
  }
}
