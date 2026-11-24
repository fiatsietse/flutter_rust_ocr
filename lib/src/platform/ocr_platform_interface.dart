import 'dart:typed_data';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../models/geometry.dart';
import '../models/ocr_elements.dart';
import '../models/quality.dart';
import '../models/document.dart';
import '../configuration/ocr_config.dart';

abstract class OcrPlatformInterface extends PlatformInterface {
  OcrPlatformInterface() : super(token: _token);

  static final Object _token = Object();
  static OcrPlatformInterface? _instance;

  static OcrPlatformInterface get instance {
    _instance ??= _DefaultOcrPlatform();
    return _instance!;
  }

  static set instance(OcrPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initialize(OcrConfig config);
  Future<OcrResult> recognizeBytes(Uint8List imageBytes);
  Future<OcrResult> recognizeImage(String imagePath);
  Future<OcrResult> recognizeRegion(Uint8List imageBytes, OcrRegion region);
  Future<OcrImageQuality> analyzeQuality(Uint8List imageBytes);
  Future<OcrDocumentResult> extractDocument(Uint8List imageBytes, DocumentTemplate template);
  Future<List<OcrResult>> recognizePdf(String filePath, List<int>? pages, PdfOcrStrategy strategy);
  Future<void> dispose();
}

class _DefaultOcrPlatform extends OcrPlatformInterface {
  bool _initialized = false;

  @override
  Future<void> initialize(OcrConfig config) async {
    _initialized = true;
  }

  @override
  Future<OcrResult> recognizeBytes(Uint8List imageBytes) async {
    if (!_initialized) {
      throw StateError('OCR engine not initialized');
    }
    return const OcrResult(
      text: '',
      confidence: 1.0,
      processingTimeMs: 0,
      imageWidth: 0,
      imageHeight: 0,
      blocks: [],
    );
  }

  @override
  Future<OcrResult> recognizeImage(String imagePath) async {
    if (!_initialized) {
      throw StateError('OCR engine not initialized');
    }
    return const OcrResult(
      text: '',
      confidence: 1.0,
      processingTimeMs: 0,
      imageWidth: 0,
      imageHeight: 0,
      blocks: [],
    );
  }

  @override
  Future<OcrResult> recognizeRegion(Uint8List imageBytes, OcrRegion region) async {
    if (!_initialized) {
      throw StateError('OCR engine not initialized');
    }
    return const OcrResult(
      text: '',
      confidence: 1.0,
      processingTimeMs: 0,
      imageWidth: 0,
      imageHeight: 0,
      blocks: [],
    );
  }

  @override
  Future<OcrImageQuality> analyzeQuality(Uint8List imageBytes) async {
    return const OcrImageQuality(
      isAcceptable: true,
      blurScore: 0.9,
      brightnessScore: 0.8,
      contrastScore: 0.85,
      resolutionScore: 1.0,
      recommendations: [],
    );
  }

  @override
  Future<OcrDocumentResult> extractDocument(
      Uint8List imageBytes, DocumentTemplate template) async {
    return OcrDocumentResult(
      templateId: template.id,
      fields: const {},
      overallConfidence: 1.0,
      isComplete: true,
    );
  }

  @override
  Future<List<OcrResult>> recognizePdf(
      String filePath, List<int>? pages, PdfOcrStrategy strategy) async {
    return const [];
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }
}
