# ADR-002 : Architecture des modèles OCR embarqués (PaddleOCR ONNX)

## Contexte
Les applications professionnelles nécessitent une détection et une reconnaissance de caractères précises, rapides et indépendantes de toute connexion réseau, avec un support prioritaire du français (accents, ligatures) et de l'anglais.

## Décision
Retenir l'architecture légère PaddleOCR au format ONNX :
1. **Détection de texte** : Modèle DBNet (Differentiable Binarization), robuste aux textes inclinés et orientations arbitraires.
2. **Reconnaissance de texte** : Modèle CRNN (CNN + RNN + décodeur CTC) avec dictionnaire latin étendu incluant tous les diacritiques français (`à`, `é`, `è`, `ê`, `ë`, `ô`, `ù`, `û`, `ç`, `œ`, `æ`).
3. **Classification d'orientation** : Modèle léger 180° pour réaligner les lignes inversées.

## Conséquences
- Compatibilité multiplateforme grâce aux runtimes ONNX (CPU / DirectML / CoreML / XNNPACK).
- Modèles compacts (< 20 Mo au total pour la détection et la reconnaissance).
- Possibilité d'étendre ultérieurement à d'autres langues via simple ajout au manifeste.
