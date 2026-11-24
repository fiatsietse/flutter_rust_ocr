# Getting Started with flutter_rust_ocr

## Quick Start

### 1. Add dependency

Add `flutter_rust_ocr` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_rust_ocr: ^0.1.0
```

### 2. Basic Initialization

Initialize the engine before calling any OCR functions:

```dart
import 'package:flutter_rust_ocr/flutter_rust_ocr.dart';

final engine = RustOcrEngine();

await engine.initialize(
  config: const OcrConfig(
    languages: ['fr', 'en'],
    modelProfile: OcrModelProfile.balanced,
  ),
);
```

### 3. Image OCR

```dart
// Recognize text from bytes
final result = await engine.recognizeBytes(imageBytes);
print('Detected text: ${result.text}');
print('Processing latency: ${result.processingTimeMs} ms');

// Recognize text from a specific region
final regionResult = await engine.recognizeRegion(
  imageBytes: imageBytes,
  region: const OcrRegion(x: 50, y: 100, width: 300, height: 80),
);
```

### 4. Dispose when done

```dart
await engine.dispose();
```
