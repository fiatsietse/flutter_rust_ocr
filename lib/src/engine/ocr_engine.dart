import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import '../configuration/ocr_config.dart';
import '../exceptions/ocr_exceptions.dart';
import '../models/batch.dart';
import '../models/document.dart';
import '../models/geometry.dart';
import '../models/ocr_elements.dart';
import '../models/quality.dart';
import '../platform/ocr_platform_interface.dart';
import '../realtime/realtime_session.dart';

class RustOcrEngine {
  bool _isInitialized = false;
  bool _isDisposed = false;
  OcrConfig? _config;

  bool get isInitialized => _isInitialized && !_isDisposed;
  OcrConfig? get config => _config;

  Future<void> initialize({OcrConfig? config}) async {
    if (_isDisposed) {
      throw const EngineDisposedException();
    }
    _config = config ?? const OcrConfig();
    await OcrPlatformInterface.instance.initialize(_config!);
    _isInitialized = true;
  }

  void _checkState() {
    if (_isDisposed) throw const EngineDisposedException();
    if (!_isInitialized) throw const EngineNotInitializedException();
  }

  Future<OcrResult> recognizeImage({required String imagePath}) async {
    _checkState();
    if (!File(imagePath).existsSync()) {
      throw InvalidImageException('Image file does not exist: $imagePath');
    }
    return await OcrPlatformInterface.instance.recognizeImage(imagePath);
  }

  Future<OcrResult> recognizeBytes(Uint8List imageBytes) async {
    _checkState();
    if (imageBytes.isEmpty) {
      throw const InvalidImageException('Image bytes cannot be empty');
    }
    return await OcrPlatformInterface.instance.recognizeBytes(imageBytes);
  }

  Future<OcrResult> recognizeRegion({
    required Uint8List imageBytes,
    required OcrRegion region,
  }) async {
    _checkState();
    if (region.width <= 0 || region.height <= 0) {
      throw const InvalidImageException('Region dimensions must be strictly positive');
    }
    return await OcrPlatformInterface.instance.recognizeRegion(imageBytes, region);
  }

  Future<OcrImageQuality> analyzeImageQuality(Uint8List imageBytes) async {
    _checkState();
    return await OcrPlatformInterface.instance.analyzeQuality(imageBytes);
  }

  Future<OcrDocumentResult> extractDocument({
    required Uint8List imageBytes,
    required DocumentTemplate template,
  }) async {
    _checkState();
    return await OcrPlatformInterface.instance.extractDocument(imageBytes, template);
  }

  Future<List<OcrResult>> recognizePdf({
    required String filePath,
    List<int>? pages,
    PdfOcrStrategy strategy = PdfOcrStrategy.automatic,
  }) async {
    _checkState();
    if (!File(filePath).existsSync()) {
      throw InvalidImageException('PDF file does not exist: $filePath');
    }
    return await OcrPlatformInterface.instance.recognizePdf(filePath, pages, strategy);
  }

  OcrBatchTask recognizeBatch({
    required List<String> imagePaths,
    int concurrency = 2,
  }) {
    _checkState();
    final progressController = StreamController<OcrProgress>.broadcast();
    final completer = Completer<List<OcrResult>>();
    bool isCancelled = false;

    Future<void> runBatch() async {
      final results = <OcrResult>[];
      int completed = 0;
      int failed = 0;
      final total = imagePaths.length;

      for (int i = 0; i < total; i++) {
        if (isCancelled) {
          completer.completeError(const ProcessingCancelledException());
          await progressController.close();
          return;
        }

        final path = imagePaths[i];
        progressController.add(OcrProgress(
          total: total,
          completed: completed,
          failed: failed,
          currentItem: path,
        ));

        try {
          final res = await recognizeImage(imagePath: path);
          results.add(res);
          completed++;
        } catch (_) {
          failed++;
        }
      }

      progressController.add(OcrProgress(
        total: total,
        completed: completed,
        failed: failed,
      ));

      await progressController.close();
      completer.complete(results);
    }

    runBatch();

    return OcrBatchTask(
      progress: progressController.stream,
      result: completer.future,
      onCancel: () {
        isCancelled = true;
      },
    );
  }

  RealtimeOcrSession createRealtimeSession({
    RealtimeOcrConfig config = const RealtimeOcrConfig(),
  }) {
    _checkState();
    return RealtimeOcrSession(
      config: config,
      processor: (bytes) => recognizeBytes(bytes),
    );
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _isInitialized = false;
    await OcrPlatformInterface.instance.dispose();
  }
}
