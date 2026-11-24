import 'dart:async';
import 'dart:typed_data';
import '../models/ocr_elements.dart';
import '../configuration/ocr_config.dart';

class RealtimeOcrSession {
  final RealtimeOcrConfig config;
  final Future<OcrResult> Function(Uint8List bytes) _processor;

  final StreamController<OcrResult> _resultController =
      StreamController<OcrResult>.broadcast();
  bool _isDisposed = false;
  bool _isProcessing = false;
  DateTime _lastFrameTime = DateTime.fromMillisecondsSinceEpoch(0);

  RealtimeOcrSession({
    required this.config,
    required Future<OcrResult> Function(Uint8List bytes) processor,
  }) : _processor = processor;

  Stream<OcrResult> get results => _resultController.stream;

  Future<void> submitFrame(Uint8List frameBytes) async {
    if (_isDisposed) return;

    final now = DateTime.now();
    final minIntervalMs = 1000 ~/ config.maxFramesPerSecond;
    if (now.difference(_lastFrameTime).inMilliseconds < minIntervalMs) {
      if (config.dropObsoleteFrames) return;
    }

    if (_isProcessing && config.dropObsoleteFrames) {
      return;
    }

    _isProcessing = true;
    _lastFrameTime = now;

    try {
      final result = await _processor(frameBytes);
      if (!_isDisposed && !_resultController.isClosed) {
        _resultController.add(result);
      }
    } catch (e, st) {
      if (!_isDisposed && !_resultController.isClosed) {
        _resultController.addError(e, st);
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await _resultController.close();
  }
}
