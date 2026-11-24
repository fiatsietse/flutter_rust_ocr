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
      isAcceptable: json['isAcceptable'] as bool? ?? true,
      blurScore: (json['blurScore'] as num?)?.toDouble() ?? 1.0,
      brightnessScore: (json['brightnessScore'] as num?)?.toDouble() ?? 1.0,
      contrastScore: (json['contrastScore'] as num?)?.toDouble() ?? 1.0,
      resolutionScore: (json['resolutionScore'] as num?)?.toDouble() ?? 1.0,
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
