# ADR-001 : Choix de la passerelle d'interopérabilité Dart/Rust (FFI)

## Contexte
Le moteur de traitement d'images haute résolution et d'inférence de réseaux de neurones (OCR) nécessite un débit élevé et une latence minimale. L'échange répété de buffers d'images matricielles brutes (RGBA, YUV) entre Dart et Rust via des canaux de sérialisation traditionnels (ex: MethodChannel JSON / StandardMessageCodec) engendre un surcoût mémoire et des copies multiples prohibitives pour le temps réel (> 30 FPS).

## Décision
Adopter une interface FFI native C-ABI (`dart:ffi` et bindings générés) avec communication par pointeurs directs de mémoire tampon (`uint8_t*` et `size_t`) :
1. **Zéro copie mémoire** : Passage direct des pointeurs de trames caméra et d'images.
2. **Cycle de vie strict** : Libération explicite des structures allouées côté Rust via `ocr_free_string` et destructeurs RAII.
3. **Sécurité FFI** : Encapsulation totale des routines Rust dans des blocs sécurisés (`catch_unwind`) empêchant toute panique native de franchir la frontière FFI.

## Conséquences
- Performances optimales et absence de saccades sur le thread UI Flutter.
- Portabilité universelle sur Windows, Linux, macOS, Android et iOS via compilation en bibliothèques dynamiques (`.dll`, `.so`, `.dylib`).
