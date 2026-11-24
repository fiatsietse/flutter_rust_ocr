import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_ocr/flutter_rust_ocr.dart';

void main() {
  group('Corpus de test et évaluation des métriques fonctionnelles', () {
    late String datasetJson;

    setUp(() {
      final file = File('test/corpus/dataset.json');
      datasetJson = file.readAsStringSync();
    });

    test('Validation de la structure du corpus de référence', () {
      final data = jsonDecode(datasetJson) as Map<String, dynamic>;
      final samples = data['samples'] as List<dynamic>;

      expect(samples.length, greaterThanOrEqualTo(4));

      for (final sample in samples) {
        final map = sample as Map<String, dynamic>;
        expect(map['id'], isNotNull);
        expect(map['ground_truth'], isNotEmpty);
        expect(map['language'], isNotEmpty);
      }
    });

    test('Évaluation métrique CER/WER sur le corpus synthétique', () {
      final data = jsonDecode(datasetJson) as Map<String, dynamic>;
      final samples = data['samples'] as List<dynamic>;

      for (final sample in samples) {
        final map = sample as Map<String, dynamic>;
        final groundTruth = map['ground_truth'] as String;

        // Évaluation de l'exact match
        final cer = OcrMetrics.calculateCer(groundTruth, groundTruth);
        final wer = OcrMetrics.calculateWer(groundTruth, groundTruth);
        final exact = OcrMetrics.calculateExactMatch(groundTruth, groundTruth);

        expect(cer, 0.0);
        expect(wer, 0.0);
        expect(exact, 1.0);
      }
    });

    test('Vérification MRZ sur échantillon passeport du corpus', () {
      final data = jsonDecode(datasetJson) as Map<String, dynamic>;
      final samples = data['samples'] as List<dynamic>;
      final mrzSample = samples.firstWhere((s) => s['id'] == 'sample_mrz_td3');

      final mrzText = mrzSample['ground_truth'] as String;
      final parsed = MrzParser.parse(mrzText);

      expect(parsed, isNotNull);
      expect(parsed!.format, MrzFormat.td3);
      expect(parsed.surname, 'ERIKSSON');
      expect(parsed.givenNames, 'ANNA MARIA');
      expect(parsed.documentNumber, 'L898902C3');
      expect(parsed.isValid, isTrue);
    });
  });
}
