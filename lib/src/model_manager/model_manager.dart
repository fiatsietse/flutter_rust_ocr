import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@immutable
class OcrModelMetadata {
  final String id;
  final String version;
  final String modelType;
  final List<String> languages;
  final int sizeBytes;
  final String sha256;
  final String filename;
  final bool isInstalled;

  const OcrModelMetadata({
    required this.id,
    required this.version,
    required this.modelType,
    required this.languages,
    required this.sizeBytes,
    required this.sha256,
    required this.filename,
    this.isInstalled = false,
  });

  factory OcrModelMetadata.fromJson(Map<String, dynamic> json, {bool isInstalled = false}) {
    return OcrModelMetadata(
      id: json['id'] as String,
      version: json['version'] as String? ?? '1.0',
      modelType: json['model_type'] as String? ?? 'unknown',
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sizeBytes: json['size_bytes'] as int? ?? 0,
      sha256: json['sha256'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      isInstalled: isInstalled,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'version': version,
    'model_type': modelType,
    'languages': languages,
    'size_bytes': sizeBytes,
    'sha256': sha256,
    'filename': filename,
    'is_installed': isInstalled,
  };
}

class OcrModelManager {
  static const String _defaultManifestAsset =
      'packages/flutter_rust_ocr/assets/manifests/models.json';

  final List<OcrModelMetadata> _availableModels = [];
  final Set<String> _installedModelIds = {};

  List<OcrModelMetadata> get availableModels => List.unmodifiable(_availableModels);
  List<OcrModelMetadata> get installedModels =>
      _availableModels.where((m) => _installedModelIds.contains(m.id)).toList();

  Future<void> loadManifest([String? manifestJson]) async {
    _availableModels.clear();
    String rawJson;
    if (manifestJson != null) {
      rawJson = manifestJson;
    } else {
      try {
        rawJson = await rootBundle.loadString(_defaultManifestAsset);
      } catch (_) {
        rawJson = '{"version":"1.0","models":[]}';
      }
    }

    final parsed = jsonDecode(rawJson) as Map<String, dynamic>;
    final list = parsed['models'] as List<dynamic>? ?? [];

    for (final item in list) {
      final map = item as Map<String, dynamic>;
      final id = map['id'] as String;
      _availableModels.add(
        OcrModelMetadata.fromJson(map, isInstalled: _installedModelIds.contains(id)),
      );
    }
  }

  void markAsInstalled(String modelId) {
    _installedModelIds.add(modelId);
  }

  void markAsUninstalled(String modelId) {
    _installedModelIds.remove(modelId);
  }

  bool isModelInstalled(String modelId) => _installedModelIds.contains(modelId);
}
