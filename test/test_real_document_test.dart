import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_ocr/flutter_rust_ocr.dart';

void main() {
  test('Test sur un document réel spécifié par IMAGE_PATH', () async {
    const customPath = String.fromEnvironment('IMAGE_PATH');

    if (customPath.isEmpty) {
      print('================================================================');
      print('Pour tester un document réel depuis le terminal, lancez :');
      print('flutter test test/test_real_document_test.dart --dart-define=IMAGE_PATH="C:\\chemin\\vers\\mon_document.jpg"');
      print('================================================================');
      return;
    }

    final file = File(customPath);
    expect(file.existsSync(), isTrue, reason: 'Le fichier $customPath doit exister.');

    print('[*] Analyse du fichier réel : $customPath (${file.lengthSync()} octets)');
    final bytes = await file.readAsBytes();

    final engine = RustOcrEngine();
    await engine.initialize(
      config: const OcrConfig(
        languages: ['fr', 'en'],
        modelProfile: OcrModelProfile.balanced,
      ),
    );

    // 1. Évaluation qualité
    final quality = await engine.analyzeImageQuality(bytes);
    print('[+] Qualité d\'image :');
    print('    - Lisibilité : ${quality.isAcceptable ? "Acceptable" : "Dégradée"}');
    print('    - Score netteté : ${(quality.blurScore * 100).toStringAsFixed(1)}%');
    print('    - Score contraste : ${(quality.contrastScore * 100).toStringAsFixed(1)}%');
    print('    - Recommandations : ${quality.recommendations}');

    // 2. Reconnaissance de texte
    final stopwatch = Stopwatch()..start();
    final result = await engine.recognizeBytes(bytes);
    stopwatch.stop();

    print('[+] Résultat OCR (${stopwatch.elapsedMilliseconds} ms) :');
    print('----------------------------------------------------');
    print(result.text.isEmpty ? '(Aucun texte détecté)' : result.text);
    print('----------------------------------------------------');

    // 3. Détection éventuelle de MRZ (CNI / Passeport)
    if (result.text.contains('<')) {
      final mrz = MrzParser.parse(result.text);
      if (mrz != null) {
        print('[+] Zone MRZ détectée :');
        print('    - Titulaire : ${mrz.surname} ${mrz.givenNames}');
        print('    - N° Document : ${mrz.documentNumber} (Valide: ${mrz.isDocumentNumberValid})');
        print('    - Format : ${mrz.format.name}');
      }
    }

    await engine.dispose();
  });
}
