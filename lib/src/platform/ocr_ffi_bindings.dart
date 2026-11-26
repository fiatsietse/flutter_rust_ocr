import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

import '../configuration/ocr_config.dart';
import '../exceptions/ocr_exceptions.dart';
import '../models/document.dart';
import '../models/geometry.dart';
import '../models/ocr_elements.dart';
import '../models/quality.dart';
import 'ocr_platform_interface.dart';

typedef OcrEngineInitNative = ffi.Int32 Function(ffi.Pointer<Utf8>);
typedef OcrEngineInitDart = int Function(ffi.Pointer<Utf8>);

typedef OcrEngineDisposeNative = ffi.Int32 Function();
typedef OcrEngineDisposeDart = int Function();

typedef OcrAnalyzeQualityBytesNative = ffi.Pointer<Utf8> Function(
    ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef OcrAnalyzeQualityBytesDart = ffi.Pointer<Utf8> Function(
    ffi.Pointer<ffi.Uint8>, int);

typedef OcrRecognizeBytesNative = ffi.Pointer<Utf8> Function(
    ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef OcrRecognizeBytesDart = ffi.Pointer<Utf8> Function(
    ffi.Pointer<ffi.Uint8>, int);

typedef OcrExtractDocumentNative = ffi.Pointer<Utf8> Function(
    ffi.Pointer<Utf8>, ffi.Pointer<Utf8>);
typedef OcrExtractDocumentDart = ffi.Pointer<Utf8> Function(
    ffi.Pointer<Utf8>, ffi.Pointer<Utf8>);

typedef OcrFreeStringNative = ffi.Void Function(ffi.Pointer<Utf8>);
typedef OcrFreeStringDart = void Function(ffi.Pointer<Utf8>);

class NativeOcrBindings {
  final ffi.DynamicLibrary? _dylib;

  late final OcrEngineInitDart? _init;
  late final OcrEngineDisposeDart? _dispose;
  late final OcrAnalyzeQualityBytesDart? _analyzeQuality;
  late final OcrRecognizeBytesDart? _recognizeBytes;
  late final OcrExtractDocumentDart? _extractDocument;
  late final OcrFreeStringDart? _freeString;

  NativeOcrBindings({ffi.DynamicLibrary? dylib}) : _dylib = dylib {
    if (_dylib != null) {
      _init = _dylib.lookupFunction<OcrEngineInitNative, OcrEngineInitDart>(
          'ocr_engine_init');
      _dispose = _dylib.lookupFunction<OcrEngineDisposeNative, OcrEngineDisposeDart>(
          'ocr_engine_dispose');
      _analyzeQuality = _dylib.lookupFunction<OcrAnalyzeQualityBytesNative,
          OcrAnalyzeQualityBytesDart>('ocr_analyze_quality_bytes');
      _recognizeBytes = _dylib.lookupFunction<OcrRecognizeBytesNative,
          OcrRecognizeBytesDart>('ocr_recognize_bytes');
      _extractDocument = _dylib.lookupFunction<OcrExtractDocumentNative,
          OcrExtractDocumentDart>('ocr_extract_document_template');
      _freeString = _dylib.lookupFunction<OcrFreeStringNative, OcrFreeStringDart>(
          'ocr_free_string');
    }
  }

  bool get isLoaded => _dylib != null;

  static ffi.DynamicLibrary? openLibrary({String? customPath}) {
    if (customPath != null && customPath.isNotEmpty) {
      try {
        return ffi.DynamicLibrary.open(customPath);
      } catch (e) {
        debugPrint('FlutterRustOcr: Échec ouverture bibliothèque custom à $customPath: $e');
        return null;
      }
    }

    try {
      if (Platform.isAndroid || Platform.isLinux) {
        return ffi.DynamicLibrary.open('libflutter_rust_ocr.so');
      } else if (Platform.isWindows) {
        try {
          return ffi.DynamicLibrary.open('flutter_rust_ocr.dll');
        } catch (_) {
          final candidates = [
            'rust/target/release/flutter_rust_ocr.dll',
            'rust/target/debug/flutter_rust_ocr.dll',
            'target/release/flutter_rust_ocr.dll',
            'target/debug/flutter_rust_ocr.dll',
          ];
          for (final path in candidates) {
            try {
              if (File(path).existsSync()) {
                return ffi.DynamicLibrary.open(path);
              }
            } catch (_) {}
          }
          return null;
        }
      } else if (Platform.isMacOS || Platform.isIOS) {
        try {
          return ffi.DynamicLibrary.process();
        } catch (_) {
          try {
            return ffi.DynamicLibrary.open('flutter_rust_ocr.framework/flutter_rust_ocr');
          } catch (_) {
            return null;
          }
        }
      }
    } catch (e) {
      debugPrint('FlutterRustOcr: Bibliothèque native non chargée ($e)');
      return null;
    }
    return null;
  }

  int initEngine(String configJson) {
    if (_init == null) return -99;
    final ptr = configJson.toNativeUtf8();
    try {
      return _init(ptr);
    } finally {
      malloc.free(ptr);
    }
  }

  int disposeEngine() {
    if (_dispose == null) return -99;
    return _dispose();
  }

  Map<String, dynamic>? analyzeQuality(Uint8List bytes) {
    if (_analyzeQuality == null || _freeString == null) return null;
    final ptr = malloc<ffi.Uint8>(bytes.length);
    final byteList = ptr.asTypedList(bytes.length);
    byteList.setAll(0, bytes);

    try {
      final resPtr = _analyzeQuality(ptr, bytes.length);
      if (resPtr == ffi.nullptr) return null;
      try {
        final jsonStr = resPtr.toDartString();
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      } finally {
        _freeString(resPtr);
      }
    } finally {
      malloc.free(ptr);
    }
  }

  Map<String, dynamic>? recognize(Uint8List bytes) {
    if (_recognizeBytes == null || _freeString == null) return null;
    final ptr = malloc<ffi.Uint8>(bytes.length);
    final byteList = ptr.asTypedList(bytes.length);
    byteList.setAll(0, bytes);

    try {
      final resPtr = _recognizeBytes(ptr, bytes.length);
      if (resPtr == ffi.nullptr) return null;
      try {
        final jsonStr = resPtr.toDartString();
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      } finally {
        _freeString(resPtr);
      }
    } finally {
      malloc.free(ptr);
    }
  }

  Map<String, dynamic>? extractDocument(String ocrText, String templateJson) {
    if (_extractDocument == null || _freeString == null) return null;
    final textPtr = ocrText.toNativeUtf8();
    final tmplPtr = templateJson.toNativeUtf8();

    try {
      final resPtr = _extractDocument(textPtr, tmplPtr);
      if (resPtr == ffi.nullptr) return null;
      try {
        final jsonStr = resPtr.toDartString();
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      } finally {
        _freeString(resPtr);
      }
    } finally {
      malloc.free(textPtr);
      malloc.free(tmplPtr);
    }
  }
}

class FfiOcrPlatform extends OcrPlatformInterface {
  NativeOcrBindings? _bindings;
  bool _initialized = false;

  FfiOcrPlatform({NativeOcrBindings? bindings}) : _bindings = bindings;

  @override
  bool get isNative => _bindings != null && _bindings!.isLoaded;

  bool get isNativeLoaded => isNative;

  static FfiOcrPlatform autoLoad({String? customLibraryPath}) {
    final dylib = NativeOcrBindings.openLibrary(customPath: customLibraryPath);
    if (dylib != null) {
      return FfiOcrPlatform(bindings: NativeOcrBindings(dylib: dylib));
    }
    return FfiOcrPlatform();
  }

  static bool autoRegister({String? customLibraryPath}) {
    final dylib = NativeOcrBindings.openLibrary(customPath: customLibraryPath);
    if (dylib != null) {
      OcrPlatformInterface.instance =
          FfiOcrPlatform(bindings: NativeOcrBindings(dylib: dylib));
      return true;
    }
    return false;
  }

  void setBindings(NativeOcrBindings bindings) {
    _bindings = bindings;
  }

  @override
  Future<void> initialize(OcrConfig config) async {
    _initialized = true;
    if (_bindings != null && _bindings!.isLoaded) {
      _bindings!.initEngine(jsonEncode(config.toJson()));
    }
  }

  @override
  Future<OcrResult> recognizeBytes(Uint8List imageBytes) async {
    if (!_initialized) {
      throw StateError('OCR engine not initialized');
    }
    if (_bindings != null && _bindings!.isLoaded) {
      final json = _bindings!.recognize(imageBytes);
      if (json != null) {
        if (json.containsKey('error')) {
          throw InvalidImageException(json['error'].toString());
        }
        return OcrResult.fromJson(json);
      }
    }
    return const OcrResult(
      text: '',
      confidence: 1.0,
      processingTimeMs: 1,
      imageWidth: 0,
      imageHeight: 0,
      blocks: [],
    );
  }

  @override
  Future<OcrResult> recognizeImage(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    return recognizeBytes(bytes);
  }

  @override
  Future<OcrResult> recognizeRegion(Uint8List imageBytes, OcrRegion region) async {
    return recognizeBytes(imageBytes);
  }

  @override
  Future<OcrImageQuality> analyzeQuality(Uint8List imageBytes) async {
    if (_bindings != null && _bindings!.isLoaded) {
      final json = _bindings!.analyzeQuality(imageBytes);
      if (json != null) {
        return OcrImageQuality.fromJson(json);
      }
    }
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
    final ocr = await recognizeBytes(imageBytes);
    if (_bindings != null && _bindings!.isLoaded) {
      final json = _bindings!.extractDocument(ocr.text, jsonEncode(template.toJson()));
      if (json != null) {
        return OcrDocumentResult.fromJson(json);
      }
    }
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
    if (_bindings != null && _bindings!.isLoaded) {
      _bindings!.disposeEngine();
    }
    _initialized = false;
  }
}
