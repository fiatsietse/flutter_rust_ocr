# État d'avancement du projet flutter_rust_ocr

Dernière mise à jour : 24 novembre 2026

## 1. Statut global des phases

| Phase | Description | Statut |
|---|---|---|
| Phase 0 | Audit technique & Décisions d'architecture | Terminé |
| Phase 1 | Fondation du package Flutter & Crate Rust | Terminé |
| Phase 2 | Moteur OCR MVP (Détection & Reconnaissance) | Terminé |
| Phase 3 | Prétraitement, Robustesse & Formats structurés | Terminé |
| Phase 4 | OCR Temps Réel & Flux Caméra | Terminé |
| Phase 5 | OCR Documentaire (Gabarits & Extractions) | Terminé |
| Phase 6 | Multiplateforme (Architecture FFI & Desktop) | Implémenté |
| Phase 7 | Tests & Application d'exemple | Terminé |

## 2. Matrice de compatibilité et fonctionnalités

| Fonctionnalité | Statut | Android | iOS | Windows | Linux | macOS | Web |
|---|---|---|---|---|---|---|---|
| Initialisation moteur | Tested | Planned | Planned | Tested | Planned | Planned | Planned |
| Reconnaissance d'image | Tested | Planned | Planned | Tested | Planned | Planned | Planned |
| Reconnaissance sur région (ROI) | Tested | Planned | Planned | Tested | Planned | Planned | Planned |
| Évaluation qualité image | Tested | Planned | Planned | Tested | Planned | Planned | Planned |
| Traitement par lots | Tested | Planned | Planned | Tested | Planned | Planned | Planned |
| Flux temps réel / caméra | Tested | Planned | Planned | Tested | Planned | Planned | Planned |
| Support PDF (pages/ocr) | Tested | Planned | Planned | Tested | Planned | Planned | Planned |
| Extraction structurée / gabarits | Tested | Planned | Planned | Tested | Planned | Planned | Planned |
| Décodage MRZ (Passeports/CNI) | Tested | Planned | Planned | Tested | Planned | Planned | Planned |
| Métriques de qualité (CER / WER) | Tested | Planned | Planned | Tested | Planned | Planned | Planned |
| Gestionnaire de modèles (SHA-256) | Tested | Planned | Planned | Tested | Planned | Planned | Planned |

## 3. Historique des tests et validation

- **Tests unitaires Dart SDK** : 16/16 tests validés (`test/flutter_rust_ocr_test.dart` et `test/ocr_corpus_eval_test.dart`).
- **Tests fonctionnels Application Démo** : Validés (`example/test/widget_test.dart`).
- **Composants Rust Core** :
  - Décodeur CTC (`CtcDecoder`) avec support multilingue et accents français (à, é, è, ê, ô, etc.).
  - Post-traitement DBNet (`DbNetPostProcessor`) avec détection de composantes connexes et expansion unclip.
  - Parser MRZ (ICAO 9303, TD1/TD3 avec validation de clé de contrôle).
  - Gestionnaire de modèles et vérification d'empreinte SHA-256 (`ModelManager`).
- **Outillage & Qualité** :
  - Corpus synthétique de validation OCR (`test/corpus/dataset.json`).
  - Métriques d'évaluation de précision OCR (CER, WER, Levenshtein, Exact Match).
  - Scripts d'export et téléchargement (`scripts/export_paddleocr_to_onnx.py`, `scripts/download_models.py`).
  - Architecture Decision Records (`doc/adr/ADR-001...`, `ADR-002...`, `ADR-003...`).
  - Workflow CI GitHub Actions (`.github/workflows/ci.yml`).
  - Script de benchmarks (`benchmarks/ocr_benchmark.dart`).
