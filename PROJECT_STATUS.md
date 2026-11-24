# État d'avancement du projet flutter_rust_ocr

Dernière mise à jour : 24 novembre 2026

## 1. Statut global des phases

| Phase | Description | Statut |
|---|---|---|
| Phase 0 | Audit technique & Décisions d'architecture | Terminé |
| Phase 1 | Fondation du package Flutter & Crate Rust | En cours |
| Phase 2 | Moteur OCR MVP (Détection & Reconnaissance) | En attente |
| Phase 3 | Prétraitement, Robustesse & Formats structurés | En attente |
| Phase 4 | OCR Temps Réel & Flux Caméra | En attente |
| Phase 5 | OCR Documentaire (PDF, Gabarits, MRZ) | En attente |
| Phase 6 | Multiplateforme (Desktop, Mobile, Web) | En attente |
| Phase 7 | Tests, Benchmarks & Préparation Publication | En attente |

## 2. Matrice de compatibilité et fonctionnalités

| Fonctionnalité | Statut | Android | iOS | Windows | Linux | macOS | Web |
|---|---|---|---|---|---|---|---|
| Initialisation moteur | In progress | - | - | Planned | - | - | - |
| Reconnaissance d'image | In progress | - | - | Planned | - | - | - |
| Reconnaissance sur région (ROI) | Planned | - | - | Planned | - | - | - |
| Évaluation qualité image | Planned | - | - | Planned | - | - | - |
| Traitement par lots | Planned | - | - | Planned | - | - | - |
| Flux temps réel / caméra | Planned | - | - | Planned | - | - | - |
| Support PDF (pages/ocr) | Planned | - | - | Planned | - | - | - |
| Extraction structurée / gabarits | Planned | - | - | Planned | - | - | - |

Légende des statuts :
- `Not started` : Non commencé
- `In progress` : En cours de développement
- `Implemented` : Implémenté mais non testé
- `Tested` : Validé par tests automatisés
- `Blocked` : Bloqué

## 3. Décisions techniques majeures (ADR)

- **ADR-001 - FFI & Bridge** : Utilisation d'une interface FFI Dart / Rust typée et asynchrone (via flutter_rust_bridge v2 / dynamic library loading) pour éliminer la surcharge de sérialisation et assurer un transfert zero-copy ou à faible latence des images.
- **ADR-002 - Modèles OCR** : Support en priorité des architectures légères PaddleOCR (DBNet pour la détection, CRNN pour la reconnaissance) au format ONNX, avec abstraction pour autoriser des moteurs d'inférence complémentaires (rten / ort).
- **ADR-003 - Offline First & Confidentialité** : Traitement 100% embarqué. Aucun appel réseau requis pour la reconnaissance. Validation des modèles par empreinte cryptographique SHA-256.

## 4. Historique des tests et validation

- Validation de l'environnement : Flutter 3.24.1, Dart 3.5.1, Git 2.45.2, MSVC VS Community disponibles.
