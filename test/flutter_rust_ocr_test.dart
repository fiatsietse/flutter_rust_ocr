import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_ocr/flutter_rust_ocr.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RustOcrEngine unit tests', () {
    late RustOcrEngine engine;

    setUp(() {
      engine = RustOcrEngine();
    });

    tearDown(() async {
      await engine.dispose();
    });

    test('Throws EngineNotInitializedException when calling before initialize', () async {
      expect(
        () => engine.recognizeBytes(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<EngineNotInitializedException>()),
      );
    });

    test('Initializes with default config properly', () async {
      expect(engine.isInitialized, isFalse);
      await engine.initialize();
      expect(engine.isInitialized, isTrue);
      expect(engine.config?.languages, contains('fr'));
    });

    test('Throws InvalidImageException on empty image bytes', () async {
      await engine.initialize();
      expect(
        () => engine.recognizeBytes(Uint8List(0)),
        throwsA(isA<InvalidImageException>()),
      );
    });

    test('Recognize bytes returns valid OcrResult structure', () async {
      await engine.initialize();
      final bytes = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]);
      final result = await engine.recognizeBytes(bytes);

      expect(result, isA<OcrResult>());
      expect(result.processingTime, isNotNull);
    });

    test('Analyze quality returns OcrImageQuality', () async {
      await engine.initialize();
      final bytes = Uint8List.fromList([1, 2, 3]);
      final quality = await engine.analyzeImageQuality(bytes);

      expect(quality, isA<OcrImageQuality>());
      expect(quality.isAcceptable, isTrue);
    });

    test('Batch task reports progress and resolves', () async {
      await engine.initialize();
      final batch = engine.recognizeBatch(imagePaths: []);
      final results = await batch.result;
      expect(results, isEmpty);
    });

    test('Dispose marks engine disposed and subsequent calls throw EngineDisposedException', () async {
      await engine.initialize();
      await engine.dispose();
      expect(engine.isInitialized, isFalse);
      expect(
        () => engine.initialize(),
        throwsA(isA<EngineDisposedException>()),
      );
    });
  });

  group('Models serialization & parsing', () {
    test('OcrPoint & OcrBoundingBox serialization', () {
      const point = OcrPoint(x: 12.5, y: 34.0);
      final jsonP = point.toJson();
      expect(OcrPoint.fromJson(jsonP), equals(point));

      const bbox = OcrBoundingBox(x: 10, y: 20, width: 100, height: 50);
      expect(bbox.left, 10);
      expect(bbox.right, 110);
      expect(bbox.top, 20);
      expect(bbox.bottom, 70);
      expect(OcrBoundingBox.fromJson(bbox.toJson()), equals(bbox));
    });

    test('OcrModelManager loads manifest correctly', () async {
      final manager = OcrModelManager();
      const manifestSample = '''
      {
        "version": "1.0",
        "models": [
          {
            "id": "ch_PP-OCRv4_rec",
            "version": "4.0",
            "model_type": "recognition",
            "languages": ["fr", "en"],
            "size_bytes": 10500000,
            "sha256": "abc123hash",
            "filename": "ch_PP-OCRv4_rec.onnx"
          }
        ]
      }
      ''';

      await manager.loadManifest(manifestSample);
      expect(manager.availableModels.length, 1);
      expect(manager.availableModels.first.id, 'ch_PP-OCRv4_rec');
      expect(manager.isModelInstalled('ch_PP-OCRv4_rec'), isFalse);

      manager.markAsInstalled('ch_PP-OCRv4_rec');
      expect(manager.isModelInstalled('ch_PP-OCRv4_rec'), isTrue);
    });

    test('MrzParser computes checksum and parses TD3 passport properly', () {
      expect(MrzParser.computeCheckDigit('520727'), 3);
      expect(MrzParser.verifyCheckDigit('520727', '3'), isTrue);

      const l1 = 'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<';
      const l2 = 'L898902C36UTO7408122F1204159ZE184226B<<<<<10';
      final res = MrzParser.parse('$l1\n$l2');

      expect(res, isNotNull);
      expect(res!.format, MrzFormat.td3);
      expect(res.surname, 'ERIKSSON');
      expect(res.givenNames, 'ANNA MARIA');
      expect(res.documentNumber, 'L898902C3');
      expect(res.isDocumentNumberValid, isTrue);
      expect(res.isValid, isTrue);
    });

    test('OcrMetrics calculates CER, WER, and Levenshtein distance', () {
      expect(OcrMetrics.levenshteinDistance('chat', 'chats'), 1);
      expect(OcrMetrics.calculateCer('chat', 'chat'), 0.0);
      expect(OcrMetrics.calculateCer('chat', 'chats'), 0.25);

      expect(OcrMetrics.calculateWer('bonjour le monde', 'bonjour le monde'), 0.0);
      expect(OcrMetrics.calculateWer('bonjour le monde', 'bonjour monde'), 1 / 3);
      expect(OcrMetrics.calculateExactMatch('Test', 'Test'), 1.0);
      expect(OcrMetrics.calculateExactMatch('Test', 'Other'), 0.0);
    });

    test('PdfDocumentHandler selects appropriate strategy', () {
      final stratAuto = PdfDocumentHandler.resolveStrategy(
        requestedStrategy: PdfOcrStrategy.automatic,
        nativeText: 'This is a high quality native PDF document layer with plenty of text.',
        imageResolutionDpi: 300,
      );
      expect(stratAuto, PdfOcrStrategy.nativeTextOnly);

      final stratOcr = PdfDocumentHandler.resolveStrategy(
        requestedStrategy: PdfOcrStrategy.automatic,
        nativeText: null,
        imageResolutionDpi: 300,
      );
      expect(stratOcr, PdfOcrStrategy.ocrOnly);
    });

    test('FfiOcrPlatform initialization and execution', () async {
      final ffiPlatform = FfiOcrPlatform();
      await ffiPlatform.initialize(const OcrConfig());
      final quality = await ffiPlatform.analyzeQuality(Uint8List.fromList([1, 2, 3]));
      expect(quality.isAcceptable, isTrue);

      final result = await ffiPlatform.recognizeBytes(Uint8List.fromList([1, 2, 3]));
      expect(result.text, isEmpty);
      await ffiPlatform.dispose();
    });
  });
}
