# Architecture de flutter_rust_ocr

## Vue d'ensemble

Le plugin `flutter_rust_ocr` est architecturé selon le modèle Clean Architecture adapté aux SDKs de traitement d'images haute performance :

```text
┌────────────────────────────────────────────────────────┐
│               Application Flutter Clientes             │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                    API Publique Dart                   │
│   (RustOcrEngine, OcrResult, OcrConfig, RealtimeSession)│
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│       Plateforme & FFI Bridge (Dart FFI / FRB)         │
└───────────────────────────┬────────────────────────────┘
                            │ Native C ABI / Zero-Copy
┌───────────────────────────▼────────────────────────────┐
│                  Moteur OCR Rust Core                  │
│                                                        │
│  ├─ Preprocessing (Resize, Grayscale, Otsu Binarize)  │
│  ├─ Image Quality Assessment (Blur, Brightness, Contr) │
│  ├─ Document Extractor (Templates, Regex, MRZ)        │
│  └─ Inference Abstraction (PaddleOCR DBNet + CRNN)     │
└────────────────────────────────────────────────────────┘
```

## Principes de conception

1. **Isolation mémoire** : Les allocations volumineuses d'images sont traitées côté Rust et nettoyées explicitement via `ocr_free_string` et libération RAII Rust.
2. **Offline-First** : Aucun composant réseau n'est invoqué durant les phases de prétraitement, détection ou reconnaissance.
3. **Traversée FFI sécurisée** : Aucune panique (`panic!`) Rust ne traverse la frontière FFI vers Dart ; les erreurs sont capturées (`catch_unwind` ou `Result`) et sérialisées en codes d'erreur explicites.
