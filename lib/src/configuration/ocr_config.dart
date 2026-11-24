import 'package:flutter/foundation.dart';

enum OcrModelProfile {
  lightweight,
  balanced,
  accurate,
  custom,
}

enum OcrExecutionProvider {
  cpu,
  directMl,
  coreMl,
  cuda,
}

enum PdfOcrStrategy {
  nativeTextOnly,
  ocrOnly,
  automatic,
}

enum PreprocessingProfile {
  automatic,
  document,
  photograph,
  lowLight,
  receipt,
  identityDocument,
  custom,
}

@immutable
class OcrConfig {
  final List<String> languages;
  final OcrModelProfile modelProfile;
  final OcrExecutionProvider executionProvider;
  final bool detectOrientation;
  final double confidenceThreshold;
  final int maxThreads;
  final PreprocessingProfile preprocessingProfile;
  final String? customModelsPath;

  const OcrConfig({
    this.languages = const ['fr', 'en'],
    this.modelProfile = OcrModelProfile.balanced,
    this.executionProvider = OcrExecutionProvider.cpu,
    this.detectOrientation = true,
    this.confidenceThreshold = 0.5,
    this.maxThreads = 4,
    this.preprocessingProfile = PreprocessingProfile.automatic,
    this.customModelsPath,
  });

  Map<String, dynamic> toJson() => {
    'languages': languages,
    'modelProfile': modelProfile.name,
    'executionProvider': executionProvider.name,
    'detectOrientation': detectOrientation,
    'confidenceThreshold': confidenceThreshold,
    'maxThreads': maxThreads,
    'preprocessingProfile': preprocessingProfile.name,
    if (customModelsPath != null) 'customModelsPath': customModelsPath,
  };
}

@immutable
class RealtimeOcrConfig {
  final int maxFramesPerSecond;
  final bool dropObsoleteFrames;
  final double confidenceThreshold;
  final bool stabilizeResults;

  const RealtimeOcrConfig({
    this.maxFramesPerSecond = 5,
    this.dropObsoleteFrames = true,
    this.confidenceThreshold = 0.6,
    this.stabilizeResults = true,
  });

  Map<String, dynamic> toJson() => {
    'maxFramesPerSecond': maxFramesPerSecond,
    'dropObsoleteFrames': dropObsoleteFrames,
    'confidenceThreshold': confidenceThreshold,
    'stabilizeResults': stabilizeResults,
  };
}
