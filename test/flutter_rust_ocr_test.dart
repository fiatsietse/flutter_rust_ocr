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

    test('DocumentTemplate parsing', () {
      final json = {
        'id': 'cni_fr',
        'version': '1.0',
        'name': 'Carte Nationale d\'Identité',
        'fields': [
          {
            'name': 'docNumber',
            'type': 'string',
            'required': true,
            'labels': ['Numéro', 'N°'],
            'pattern': r'^[0-9A-Z]{12}$',
          }
        ]
      };

      final template = DocumentTemplate.fromJson(json);
      expect(template.id, 'cni_fr');
      expect(template.fields.length, 1);
      expect(template.fields.first.required, isTrue);
    });
  });
}
