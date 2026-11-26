import 'package:flutter/foundation.dart';

@immutable
class OcrImageQuality {
  final bool isAcceptable;
  final double blurScore;
  final double brightnessScore;
  final double contrastScore;
  final double resolutionScore;
  final List<String> recommendations;

  const OcrImageQuality({
    required this.isAcceptable,
    required this.blurScore,
    required this.brightnessScore,
    required this.contrastScore,
    required this.resolutionScore,
    this.recommendations = const [],
  });

  factory OcrImageQuality.fromJson(Map<String, dynamic> json) {
    return OcrImageQuality(
      isAcceptable: (json['isAcceptable'] ?? json['is_acceptable']) as bool? ?? true,
      blurScore: ((json['blurScore'] ?? json['blur_score']) as num?)?.toDouble() ?? 1.0,
      brightnessScore: ((json['brightnessScore'] ?? json['brightness_score']) as num?)?.toDouble() ?? 1.0,
      contrastScore: ((json['contrastScore'] ?? json['contrast_score']) as num?)?.toDouble() ?? 1.0,
      resolutionScore: ((json['resolutionScore'] ?? json['resolution_score']) as num?)?.toDouble() ?? 1.0,
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'isAcceptable': isAcceptable,
    'blurScore': blurScore,
    'brightnessScore': brightnessScore,
    'contrastScore': contrastScore,
    'resolutionScore': resolutionScore,
    'recommendations': recommendations,
  };
}
