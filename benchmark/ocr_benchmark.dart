import 'dart:typed_data';
import 'package:flutter_rust_ocr/flutter_rust_ocr.dart';

void main() async {
  print('=== Démarrage du Benchmark flutter_rust_ocr ===');

  final engine = RustOcrEngine();
  await engine.initialize(
    config: const OcrConfig(
      languages: ['fr', 'en'],
      modelProfile: OcrModelProfile.balanced,
    ),
  );

  final dummyBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

  const warmup = 10;
  for (int i = 0; i < warmup; i++) {
    await engine.recognizeBytes(dummyBytes);
  }

  const iterations = 100;
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < iterations; i++) {
    await engine.recognizeBytes(dummyBytes);
  }

  stopwatch.stop();

  final totalMs = stopwatch.elapsedMilliseconds;
  final avgMs = totalMs / iterations;
  final fps = 1000.0 / avgMs;

  print('Itérations: $iterations');
  print('Temps total: $totalMs ms');
  print('Latence moyenne: ${avgMs.toStringAsFixed(3)} ms');
  print('Débit estimé: ${fps.toStringAsFixed(1)} FPS');

  await engine.dispose();
  print('=== Benchmark terminé avec succès ===');
}
