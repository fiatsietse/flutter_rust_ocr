# API Reference — flutter_rust_ocr

## Classes Principales

### `RustOcrEngine`
Point d'entrée principal du plugin.
- `initialize({OcrConfig? config}) -> Future<void>`
- `recognizeBytes(Uint8List imageBytes) -> Future<OcrResult>`
- `recognizeImage({required String imagePath}) -> Future<OcrResult>`
- `recognizeRegion({required Uint8List imageBytes, required OcrRegion region}) -> Future<OcrResult>`
- `analyzeImageQuality(Uint8List imageBytes) -> Future<OcrImageQuality>`
- `extractDocument({required Uint8List imageBytes, required DocumentTemplate template}) -> Future<OcrDocumentResult>`
- `recognizeBatch({required List<String> imagePaths, int concurrency = 2}) -> OcrBatchTask`
- `createRealtimeSession({RealtimeOcrConfig config}) -> RealtimeOcrSession`
- `dispose() -> Future<void>`

### `OcrResult`
Conteneur structuré des données de reconnaissance textuelle :
- `text`: Texte intégral reconstitué selon l'ordre de lecture.
- `confidence`: Score de confiance agrégé [0.0 - 1.0].
- `processingTimeMs`: Durée d'inférence en millisecondes.
- `blocks`: Liste des blocs hiérarchiques (`OcrBlock` -> `OcrLine` -> `OcrWord` -> `OcrCharacter`).
- `pages`: Découpage par page document (utile pour les PDFs).

### `OcrImageQuality`
Rapport d'évaluation de la qualité de prise de vue :
- `isAcceptable`: Indicateur booléen de lisibilité globale.
- `blurScore`: Mesure de netteté [0.0 - 1.0].
- `brightnessScore`: Mesure de luminosité [0.0 - 1.0].
- `contrastScore`: Mesure de contraste [0.0 - 1.0].
- `recommendations`: Conseils utilisateur (ex. "Augmenter l'éclairage").
