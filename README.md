# flutter_rust_ocr

Moteur OCR multiplateforme (Android, iOS, Windows, Linux, macOS, Web) haute performance et privacy-first basé sur Rust pour Flutter.

## Fonctionnalités

- **100% Hors-ligne** : Aucune donnée n'est transmise à un serveur cloud.
- **Support multilingue** : Français, Anglais et langues configurables.
- **Évaluation de qualité d'image** : Détection du flou, contraste, luminosité avant reconnaissance.
- **Extraction documentaire structurée** : Support des gabarits JSON (CNI, factures, formulaires, MRZ).
- **Temps réel & flux vidéo** : Gestion du backpressure et stabilisation des résultats.
- **Traitement par lots** : File d'attente avec progression et annulation.
- **Multi-plateforme natif** : Cœur de calcul compilé en Rust avec interopérabilité Dart FFI zero-copy.

## Documentation

- [Architecture](docs/architecture.md)
- [Guide de démarrage](docs/getting_started.md)
- [Référence de l'API](docs/api_reference.md)
- [Statut du projet](PROJECT_STATUS.md)

## Licence

MIT OR Apache-2.0
