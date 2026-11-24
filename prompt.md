# PROMPT — Développement d'un plugin Flutter OCR multiplateforme basé sur Rust

## 1. Rôle et expertise

Tu es un architecte logiciel senior et un expert en développement spécialisé dans :

- Flutter et Dart ;
- Rust et la programmation système ;
- Foreign Function Interface (FFI) ;
- Computer Vision et traitement d'images ;
- Optical Character Recognition (OCR) ;
- Deep Learning et inférence embarquée ;
- ONNX Runtime ;
- PaddleOCR ;
- Développement de SDK et de plugins multiplateformes ;
- Optimisation des performances CPU, GPU et mémoire ;
- Architecture logicielle, sécurité et qualité du code.

Ta mission consiste à concevoir, développer, tester et documenter intégralement un plugin Flutter OCR basé sur Rust, destiné à être utilisé dans des applications professionnelles et à être publié sur pub.dev.

Tu dois agir comme un agent de développement autonome. Ne te limite pas à proposer une architecture, des recommandations ou des extraits de code : crée réellement les fichiers, implémente les fonctionnalités, installe les dépendances, exécute les tests et corrige les erreurs rencontrées.

---

## 2. Présentation du projet

### 2.1. Nom du projet

Nom provisoire du package :

`flutter_rust_ocr`

Le nom doit être facilement modifiable avant publication.

### 2.2. Objectif général

Développer un moteur OCR accessible depuis Flutter, dont le cœur de traitement est implémenté en Rust, capable de reconnaître, localiser, extraire et structurer du texte provenant de différentes sources.

Le plugin doit fonctionner entièrement hors ligne une fois les modèles nécessaires installés.

Il doit constituer une alternative indépendante aux solutions telles que :

- Google ML Kit Text Recognition ;
- Google Cloud Vision ;
- Microsoft Azure AI Vision ;
- Amazon Textract ;
- Les autres services OCR nécessitant une connexion Internet.

Le plugin ne doit dépendre d'aucune API distante pour effectuer la reconnaissance de texte.

### 2.3. Principes fondamentaux

La solution doit respecter les principes suivants :

- Offline-first ;
- Privacy by design ;
- Architecture modulaire et extensible ;
- Performances élevées ;
- Faible consommation de mémoire ;
- API Flutter simple et intuitive ;
- Compatibilité multiplateforme ;
- Sécurité mémoire ;
- Traitement asynchrone ;
- Indépendance vis-à-vis des fournisseurs cloud ;
- Facilité d'intégration dans des applications existantes ;
- Possibilité de remplacer les modèles et moteurs OCR ;
- Maintenabilité à long terme ;
- Absence de dépendance à Python en production.

---

## 3. Plateformes cibles

Le plugin doit viser les plateformes suivantes :

| Plateforme | Priorité |
|---|---|
| Android | P0 |
| iOS | P0 |
| Windows | P0 |
| Linux | P1 |
| macOS | P1 |
| Web | P2 |

Architectures matérielles à prendre en considération :

- ARM64 ;
- ARMv7, lorsque les dépendances le permettent ;
- x86_64 ;
- WebAssembly pour le Web.

Pour le Web, étudier la faisabilité d'une implémentation utilisant Rust compilé en WebAssembly, ONNX Runtime Web ou un moteur d'inférence compatible.

Ne pas compromettre les performances ou la stabilité des plateformes natives pour imposer une implémentation Web identique.

Utiliser une architecture fédérée ou des implémentations conditionnelles lorsque cela est nécessaire.

Ne déclarer une plateforme officiellement supportée que lorsque sa compilation et son fonctionnement ont été vérifiés.

---

## 4. Stack technique

### 4.1. Flutter et Dart

Utiliser :

- Flutter stable ;
- Dart stable ;
- flutter_rust_bridge ;
- Dart FFI lorsque nécessaire ;
- Des interfaces typées ;
- Des API asynchrones ;
- Des Streams pour les traitements continus ;
- Des imports conditionnels pour les plateformes spécifiques.

### 4.2. Rust

Étudier et utiliser les bibliothèques pertinentes parmi :

| Bibliothèque | Responsabilité |
|---|---|
| flutter_rust_bridge | Interopérabilité Flutter/Rust |
| image | Décodage et manipulation d'images |
| imageproc | Traitement d'images |
| ort | Inférence ONNX Runtime |
| rten | Moteur d'inférence alternatif |
| ocrs | Moteur OCR alternatif |
| serde | Sérialisation |
| rayon | Parallélisation CPU |
| thiserror | Gestion des erreurs |
| tracing | Journalisation |
| ndarray | Manipulation des tenseurs |
| sha2 | Vérification d'intégrité des modèles |

Cette liste n'est pas une obligation d'utiliser toutes les bibliothèques.

Avant l'implémentation :

1. Vérifier les versions stables disponibles.
2. Vérifier la compatibilité entre les dépendances.
3. Vérifier la compatibilité mobile et desktop.
4. Examiner les licences.
5. Vérifier les exigences de compilation native.
6. Éliminer les dépendances inutiles.
7. Documenter les décisions techniques.

Ne pas inventer de bibliothèques, de méthodes, de paramètres ou d'API inexistantes.

---

## 5. Architecture logicielle

Adopter une architecture modulaire inspirée de Clean Architecture, adaptée à un SDK de traitement d'images.

### 5.1. Architecture globale

```text
Flutter Application
        |
Public Dart SDK
        |
Platform Interface
        |
Flutter Rust Bridge / FFI
        |
Rust OCR Engine
        |
        +-- Engine Configuration
        +-- Image Processing
        +-- Text Detection
        +-- Orientation Classification
        +-- Text Recognition
        +-- Layout Analysis
        +-- Post Processing
        +-- Document Processing
        +-- Structured Extraction
        +-- Model Management
        +-- Inference Abstraction
        +-- Performance Management
        |
Inference Backend
        |
        +-- ONNX Runtime
        +-- RTen
        +-- Other compatible backends
        |
OCR Models
```

### 5.2. Séparation des responsabilités

Le code Flutter doit principalement gérer :

- L'API publique du SDK ;
- La configuration du moteur ;
- Le cycle de vie du moteur ;
- Les entrées et sorties ;
- Les événements et notifications ;
- L'intégration avec les plugins caméra ;
- La gestion des ressources spécifiques aux plateformes ;
- La présentation des résultats aux applications clientes.

Le code Rust doit principalement gérer :

- Le décodage des images ;
- Le prétraitement ;
- Les transformations géométriques ;
- La détection des zones de texte ;
- La reconnaissance des caractères ;
- L'inférence des modèles ;
- Le post-traitement ;
- L'analyse de la structure documentaire ;
- La parallélisation ;
- La gestion des ressources de calcul ;
- La construction des résultats OCR.

Éviter les transferts répétés de données volumineuses entre Dart et Rust.

### 5.3. Abstraction du moteur OCR

Créer une abstraction permettant d'utiliser plusieurs moteurs OCR sans modifier l'API publique Flutter.

Prévoir notamment les concepts suivants :

- OcrBackend ;
- InferenceBackend ;
- TextDetector ;
- TextRecognizer ;
- OrientationClassifier ;
- ImagePreprocessor ;
- LayoutAnalyzer ;
- ModelProvider ;
- DocumentProcessor.

PaddleOCR doit être le moteur principal envisagé.

OCRS ou d'autres moteurs compatibles peuvent être intégrés ultérieurement à travers les interfaces prévues.

Ne pas imposer une abstraction excessivement complexe pour des fonctionnalités qui ne nécessitent pas plusieurs implémentations.

---

## 6. Moteur OCR

### 6.1. PaddleOCR

Utiliser en priorité des modèles PaddleOCR compatibles avec une exécution embarquée.

Étudier les familles de modèles stables disponibles au moment du développement, notamment les variantes légères destinées aux appareils mobiles.

Le pipeline doit permettre :

1. Le chargement de l'image.
2. Le prétraitement.
3. La détection des régions contenant du texte.
4. L'extraction des régions détectées.
5. La correction de perspective.
6. La classification de l'orientation si nécessaire.
7. La reconnaissance du texte.
8. Le décodage des prédictions.
9. Le calcul des scores disponibles.
10. La reconstruction de l'ordre de lecture.
11. La structuration des résultats.

Utiliser des modèles ONNX compatibles avec le runtime retenu.

Si une conversion de modèles est nécessaire, fournir les scripts de conversion et documenter la procédure. Python peut être utilisé pour la préparation des modèles pendant le développement, mais ne doit pas être requis à l'exécution du plugin.

Respecter précisément les spécifications de chaque modèle :

- Dimensions d'entrée ;
- Normalisation ;
- Ordre des canaux ;
- Format des tenseurs ;
- Algorithmes de redimensionnement ;
- Dictionnaires de caractères ;
- Décodage CTC ou autre ;
- Algorithmes de post-traitement ;
- Seuils de détection ;
- Versions et opsets ONNX.

Ne pas supposer que tous les modèles PaddleOCR utilisent les mêmes paramètres.

---

## 7. Fonctionnalités attendues

### 7.1. Sources d'entrée

Le plugin doit pouvoir traiter :

- Une image depuis un chemin de fichier ;
- Une image sous forme de Uint8List ;
- Une image provenant de la galerie ;
- Une photographie ;
- Une image provenant d'un flux caméra ;
- Plusieurs images simultanément ;
- Un document PDF ;
- Une région spécifique d'une image.

Formats d'images prioritaires :

- JPEG ;
- PNG ;
- BMP ;
- WebP ;
- TIFF.

Étudier également la prise en charge de HEIC et HEIF selon les capacités des plateformes.

L'intégration de la galerie et de la caméra doit rester optionnelle afin de ne pas imposer des permissions inutiles aux applications clientes.

### 7.2. Prétraitement des images

Implémenter un pipeline configurable comprenant :

- Redimensionnement intelligent ;
- Conversion en niveaux de gris ;
- Normalisation ;
- Ajustement du contraste ;
- Ajustement de la luminosité ;
- Réduction du bruit ;
- Binarisation ;
- Seuillage adaptatif ;
- Correction gamma ;
- Accentuation de la netteté ;
- Correction de rotation ;
- Correction de l'inclinaison ;
- Correction de perspective ;
- Gestion de l'orientation EXIF ;
- Détection des bordures documentaires ;
- Recadrage automatique ;
- Réduction des ombres lorsque cela est pertinent.

Le pipeline doit permettre d'activer ou de désactiver individuellement chaque opération.

Ne pas appliquer systématiquement des transformations susceptibles de dégrader les performances des modèles neuronaux.

Prévoir des profils :

- Automatic ;
- Document ;
- Photograph ;
- LowLight ;
- Receipt ;
- IdentityDocument ;
- Custom.

### 7.3. Évaluation de la qualité des images

Implémenter un module capable d'évaluer :

- Le flou ;
- La luminosité ;
- Le contraste ;
- La résolution ;
- La présence de reflets ;
- L'inclinaison ;
- Le cadrage ;
- La lisibilité potentielle.

Retourner des indicateurs et recommandations exploitables par l'application Flutter.

Exemples :

- Image trop sombre ;
- Image floue ;
- Document partiellement visible ;
- Résolution insuffisante ;
- Repositionnement recommandé.

Les scores de qualité doivent être présentés comme des indicateurs heuristiques lorsqu'ils ne proviennent pas de modèles validés.

### 7.4. Détection de texte

Détecter les zones contenant du texte.

Retourner, lorsque les modèles le permettent :

- Les rectangles englobants ;
- Les polygones ;
- Les coordonnées des quatre sommets ;
- L'orientation ;
- Les scores de détection ;
- L'identifiant de la région.

Prendre en charge les textes inclinés et les documents photographiés sous différents angles.

Les coordonnées doivent pouvoir être converties dans le référentiel de l'image originale.

### 7.5. Reconnaissance de texte

Reconnaître notamment :

- Les caractères alphabétiques ;
- Les chiffres ;
- Les caractères accentués ;
- Les caractères spéciaux ;
- La ponctuation ;
- Les textes multilignes ;
- Les textes multilingues ;
- Les textes de tailles variables.

Le français et l'anglais doivent être prioritaires.

Prévoir une architecture permettant d'ajouter d'autres langues :

- Espagnol ;
- Portugais ;
- Allemand ;
- Arabe ;
- Chinois ;
- Autres langues selon les modèles disponibles.

Ne pas annoncer la reconnaissance de l'écriture manuscrite sans modèle dédié et validation spécifique.

### 7.6. Analyse de la structure documentaire

Le plugin doit pouvoir reconstruire, selon les capacités des modèles :

- Les blocs ;
- Les paragraphes ;
- Les lignes ;
- Les mots ;
- Les colonnes ;
- Les titres ;
- Les en-têtes ;
- Les pieds de page ;
- Les tableaux ;
- L'ordre de lecture.

Distinguer clairement :

- Les éléments directement détectés par les modèles ;
- Les éléments reconstruits par des algorithmes géométriques ;
- Les éléments inférés par des heuristiques.

Pour les mots et caractères, ne pas inventer de coordonnées ou de scores individuels si le modèle ne les fournit pas.

### 7.7. OCR sur une région spécifique

Permettre de limiter le traitement à une ou plusieurs régions d'intérêt.

Cas d'utilisation :

- Reconnaissance d'un numéro de document ;
- Extraction d'un champ de formulaire ;
- Lecture d'une date ;
- Lecture d'un numéro de série ;
- Extraction d'une référence ;
- Reconnaissance dans une zone sélectionnée par l'utilisateur.

Prendre en charge les coordonnées absolues et normalisées.

### 7.8. Traitement par lots

Permettre de traiter plusieurs images ou documents.

Fonctionnalités attendues :

- File d'attente ;
- Limitation de la concurrence ;
- Progression globale ;
- Progression individuelle ;
- Annulation ;
- Gestion des erreurs partielles ;
- Conservation de l'ordre des résultats ;
- Réutilisation des modèles déjà chargés ;
- Contrôle de la consommation mémoire.

Une erreur sur une image ne doit pas systématiquement interrompre le traitement de l'ensemble du lot.

---

## 8. OCR en temps réel

Implémenter une API permettant d'effectuer la reconnaissance depuis un flux d'images caméra.

Le module doit pouvoir être utilisé pour :

- Scanner un document ;
- Lire un numéro de série ;
- Lire un texte affiché ;
- Capturer des informations administratives ;
- Scanner des reçus ;
- Afficher les zones de texte en temps réel.

### Contraintes techniques

- Ne jamais bloquer le thread UI.
- Limiter la fréquence d'inférence.
- Éviter l'accumulation des frames.
- Implémenter un mécanisme de backpressure.
- Permettre l'abandon des frames obsolètes.
- Réutiliser les buffers lorsque cela est possible.
- Permettre de configurer la résolution de traitement.
- Permettre de configurer une région d'intérêt.
- Prendre en charge l'orientation du capteur.
- Gérer les transformations entre coordonnées caméra et aperçu Flutter.
- Gérer les formats YUV420, NV21 et BGRA8888 selon les plateformes.
- Stabiliser les résultats entre plusieurs frames.
- Permettre l'annulation et la libération des ressources.

Prévoir plusieurs modes :

- Continuous ;
- SingleShot ;
- StableResult ;
- RegionOfInterest.

Le mode StableResult doit pouvoir attendre qu'un texte soit détecté de manière suffisamment stable avant de le retourner.

---

## 9. Traitement des documents PDF

Le plugin doit permettre :

- L'ouverture de documents PDF ;
- La sélection des pages à traiter ;
- Le rendu des pages sous forme d'images ;
- L'OCR des documents numérisés ;
- L'extraction du texte natif lorsque disponible ;
- La gestion des documents mixtes ;
- La restitution des résultats par page ;
- Le traitement progressif des documents volumineux ;
- L'annulation du traitement ;
- La configuration de la résolution de rendu.

Étudier l'utilisation de PDFium ou d'une autre bibliothèque compatible avec les plateformes et les exigences de licence.

Éviter de charger toutes les pages en mémoire simultanément.

Prévoir trois stratégies :

- NativeTextOnly ;
- OcrOnly ;
- Automatic.

En mode Automatic, privilégier le texte natif lorsqu'il est exploitable et effectuer l'OCR sur les pages ou régions nécessitant une reconnaissance visuelle.

La présence d'une couche texte ne garantit pas sa qualité : prévoir une stratégie configurable pour détecter les couches texte incomplètes ou inutilisables.

---

## 10. Extraction de données structurées

Créer une couche optionnelle d'extraction d'informations au-dessus du moteur OCR générique.

### 10.1. Documents ciblés

- Cartes nationales d'identité ;
- Passeports ;
- Permis de conduire ;
- Actes de naissance ;
- Documents administratifs ;
- Factures ;
- Reçus ;
- Formulaires ;
- Attestations ;
- Diplômes.

### 10.2. Types de données

Permettre l'extraction de :

- Noms ;
- Prénoms ;
- Dates ;
- Numéros de documents ;
- Numéros de téléphone ;
- Adresses e-mail ;
- Adresses postales ;
- Montants ;
- Devises ;
- Références ;
- Identifiants ;
- Zones MRZ des documents compatibles.

### 10.3. Approche configurable

Ne pas coder en dur tous les formats documentaires dans le moteur principal.

Prévoir un système de templates documentaires configurables en JSON comprenant :

- Le type de document ;
- Les champs attendus ;
- Les libellés possibles ;
- Les expressions régulières ;
- Les régions d'intérêt ;
- Les règles de normalisation ;
- Les règles de validation ;
- Les champs obligatoires ;
- Les relations spatiales entre champs.

Exemple :

```json
{
  "id": "identity_document",
  "version": "1.0",
  "fields": [
    {
      "name": "documentNumber",
      "type": "string",
      "required": true,
      "labels": [
        "Numéro",
        "Document Number"
      ],
      "pattern": "[A-Z0-9]{6,20}"
    },
    {
      "name": "dateOfBirth",
      "type": "date",
      "required": true,
      "labels": [
        "Date de naissance",
        "Date of birth"
      ]
    }
  ]
}
```

Permettre aux développeurs de définir leurs propres extracteurs et templates.

Préserver le texte original avant normalisation.

Ne jamais inventer une valeur absente ou illisible.

L'extraction d'informations ne doit pas être présentée comme une vérification de l'authenticité du document.

---

## 11. Gestion des modèles OCR

Créer un Model Manager complet.

### Fonctionnalités

- Modèles embarqués dans les assets ;
- Modèles fournis par l'application cliente ;
- Téléchargement à la demande ;
- Gestion des versions ;
- Gestion des langues ;
- Vérification SHA-256 ;
- Vérification de compatibilité ;
- Cache local ;
- Chargement paresseux ;
- Préchargement ;
- Suppression des modèles ;
- Gestion de l'espace disque ;
- Téléchargement reprenable lorsque possible ;
- Gestion des erreurs réseau ;
- Installation atomique ;
- Conservation d'une version fonctionnelle en cas d'échec de mise à jour.

Prévoir plusieurs profils de modèles :

| Profil | Objectif |
|---|---|
| Lightweight | Faible consommation de ressources |
| Balanced | Compromis précision et performances |
| Accurate | Privilégier la qualité de reconnaissance |
| Custom | Modèles fournis par le développeur |

Créer un manifeste contenant notamment :

- Identifiant du modèle ;
- Version ;
- Type de modèle ;
- Langues ;
- Taille ;
- URL de téléchargement ;
- Empreinte SHA-256 ;
- Licence ;
- Format ;
- Runtime compatible ;
- Paramètres de prétraitement ;
- Dictionnaire associé ;
- Configuration de post-traitement.

Le téléchargement doit être facultatif.

Une application doit pouvoir embarquer tous les modèles nécessaires et fonctionner dès son premier lancement sans connexion Internet.

Ne pas télécharger automatiquement de modèles sans configuration explicite de l'application cliente.

---

## 12. API publique Flutter

Concevoir une API moderne, intuitive, fortement typée et cohérente avec les conventions Flutter.

Les exemples suivants définissent le contrat fonctionnel souhaité. Adapter les signatures si nécessaire, en documentant les modifications.

### 12.1. Initialisation

```dart
final engine = RustOcrEngine();

await engine.initialize(
  config: OcrConfig(
    languages: ['fr', 'en'],
    modelProfile: OcrModelProfile.balanced,
    executionProvider: OcrExecutionProvider.cpu,
    detectOrientation: true,
    confidenceThreshold: 0.75,
    maxThreads: 4,
  ),
);
```

### 12.2. Reconnaissance depuis un fichier

```dart
final result = await engine.recognizeImage(
  imagePath: imagePath,
);

print(result.text);
print(result.processingTime);
```

### 12.3. Reconnaissance depuis des bytes

```dart
final result = await engine.recognizeBytes(
  imageBytes,
);
```

### 12.4. Reconnaissance d'une région

```dart
final result = await engine.recognizeRegion(
  imageBytes: imageBytes,
  region: OcrRegion(
    x: 100,
    y: 200,
    width: 400,
    height: 150,
  ),
);
```

### 12.5. Traitement PDF

```dart
final result = await engine.recognizePdf(
  filePath: pdfPath,
  pages: [1, 2, 3],
  strategy: PdfOcrStrategy.automatic,
);
```

Documenter explicitement la convention de numérotation des pages.

### 12.6. Traitement par lots

```dart
final task = engine.recognizeBatch(
  imagePaths: images,
);

task.progress.listen((progress) {
  print(progress.percentage);
});

final results = await task.result;
```

### 12.7. Reconnaissance en temps réel

```dart
final session = engine.createRealtimeSession(
  config: RealtimeOcrConfig(
    maxFramesPerSecond: 5,
    dropObsoleteFrames: true,
  ),
);

session.results.listen((result) {
  print(result.text);
});

await session.submitFrame(frame);
```

### 12.8. Extraction structurée

```dart
final result = await engine.extractDocument(
  imageBytes: imageBytes,
  template: documentTemplate,
);

print(result.fields);
```

### 12.9. Évaluation de la qualité

```dart
final quality = await engine.analyzeImageQuality(
  imageBytes,
);

print(quality.isAcceptable);
print(quality.recommendations);
```

### 12.10. Libération des ressources

```dart
await session.dispose();
await engine.dispose();
```

Le moteur doit gérer correctement :

- Les initialisations concurrentes ;
- Les appels avant initialisation ;
- Les appels après libération ;
- Les appels simultanés ;
- Les annulations ;
- Les erreurs d'inférence ;
- La réutilisation des sessions ;
- Les ressources natives.

---

## 13. Modèles de données

Créer des modèles Dart et Rust cohérents.

Prévoir notamment :

- OcrResult ;
- OcrPage ;
- OcrBlock ;
- OcrParagraph ;
- OcrLine ;
- OcrWord ;
- OcrCharacter, lorsque disponible ;
- OcrPoint ;
- OcrPolygon ;
- OcrBoundingBox ;
- OcrRegion ;
- OcrConfig ;
- OcrProgress ;
- OcrException ;
- OcrModelInfo ;
- OcrDocumentResult ;
- OcrExtractedField ;
- OcrImageQuality ;
- OcrProcessingMetrics.

Exemple de résultat sérialisé :

```json
{
  "text": "Bonjour le monde",
  "confidence": 0.97,
  "processingTimeMs": 245,
  "imageWidth": 1920,
  "imageHeight": 1080,
  "blocks": [
    {
      "id": "block_1",
      "text": "Bonjour le monde",
      "confidence": 0.97,
      "boundingBox": {
        "x": 100,
        "y": 200,
        "width": 350,
        "height": 45
      },
      "polygon": [
        {"x": 100, "y": 200},
        {"x": 450, "y": 200},
        {"x": 450, "y": 245},
        {"x": 100, "y": 245}
      ],
      "lines": [
        {
          "text": "Bonjour le monde",
          "confidence": 0.97
        }
      ]
    }
  ]
}
```

Les valeurs de cet exemple sont illustratives.

Les scores non disponibles doivent être nullables. Documenter la méthode de calcul des scores agrégés et préciser qu'ils ne constituent pas nécessairement des probabilités calibrées.

---

## 14. Structure du repository

Adopter une structure similaire à celle-ci, en tenant compte des fichiers réellement générés par flutter_rust_bridge et les outils de compilation retenus.

```text
flutter_rust_ocr/
├── lib/
│   ├── flutter_rust_ocr.dart
│   └── src/
│       ├── engine/
│       ├── models/
│       ├── configuration/
│       ├── platform/
│       ├── exceptions/
│       ├── realtime/
│       ├── document/
│       ├── model_manager/
│       └── rust/
├── rust/
│   ├── Cargo.toml
│   ├── src/
│   │   ├── lib.rs
│   │   ├── api/
│   │   ├── engine/
│   │   ├── preprocessing/
│   │   ├── detection/
│   │   ├── recognition/
│   │   ├── orientation/
│   │   ├── postprocessing/
│   │   ├── inference/
│   │   ├── layout/
│   │   ├── extraction/
│   │   ├── document/
│   │   ├── realtime/
│   │   ├── model_manager/
│   │   ├── errors/
│   │   └── utils/
│   ├── tests/
│   └── benches/
├── assets/
│   ├── manifests/
│   └── models/
├── android/
├── ios/
├── windows/
├── linux/
├── macos/
├── web/
├── example/
├── test/
├── integration_test/
├── benchmarks/
├── scripts/
├── docs/
├── .github/
│   └── workflows/
├── pubspec.yaml
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

Ne pas créer de dossiers ou fichiers vides uniquement pour donner l'impression que l'architecture est complète.

---

## 15. Optimisation des performances

### 15.1. CPU

- Exploiter les optimisations SIMD disponibles ;
- Utiliser le multithreading lorsque pertinent ;
- Éviter la surallocation de threads ;
- Réutiliser les sessions d'inférence ;
- Réutiliser les buffers ;
- Limiter les copies mémoire ;
- Optimiser les opérations sur les tenseurs ;
- Traiter les grandes images de manière contrôlée.

### 15.2. GPU et accélération matérielle

Étudier, selon les plateformes et le runtime :

- Core ML ;
- XNNPACK ;
- NNAPI lorsque pertinent et disponible ;
- DirectML ;
- CUDA ;
- Metal ;
- WebGPU pour le Web.

Le CPU doit constituer le backend de référence.

Implémenter un mécanisme de détection des capacités matérielles et un fallback CPU configurable.

Ne pas prétendre supporter un accélérateur qui n'a pas été effectivement intégré et testé.

### 15.3. Gestion de la mémoire

- Éviter les fuites mémoire ;
- Limiter les allocations temporaires ;
- Libérer les tenseurs inutilisés ;
- Éviter de charger plusieurs fois les mêmes modèles ;
- Permettre de configurer les limites mémoire ;
- Gérer les images de très grande résolution ;
- Prévenir les dépassements de capacité ;
- Limiter le nombre de tâches concurrentes.

### 15.4. Modes de performance

Prévoir des modes :

- LowPower ;
- Balanced ;
- HighPerformance ;
- Custom.

Chaque mode doit avoir une configuration documentée.

---

## 16. Sécurité et confidentialité

Le plugin doit être conçu pour traiter des documents potentiellement sensibles.

Respecter les exigences suivantes :

- Aucun envoi automatique de documents vers un serveur ;
- Aucune télémétrie activée par défaut ;
- Aucun stockage permanent des images sans demande explicite ;
- Aucun enregistrement du texte reconnu dans les logs par défaut ;
- Suppression des fichiers temporaires créés par le plugin ;
- Validation des entrées ;
- Limitation de la taille des images ;
- Limitation de la taille et du nombre de pages PDF ;
- Protection contre les images malformées ;
- Protection contre les décompressions excessives ;
- Validation des modèles téléchargés ;
- Vérification de l'intégrité des fichiers ;
- Contrôle des chemins de fichiers ;
- Gestion sécurisée des erreurs FFI ;
- Réduction du code Rust unsafe ;
- Audit des dépendances.

Documenter les responsabilités de l'application cliente concernant les permissions, le stockage des documents et la protection des données.

---

## 17. Gestion des erreurs

Créer une hiérarchie d'erreurs explicites et exploitables depuis Dart.

Prévoir notamment :

- EngineNotInitialized ;
- EngineDisposed ;
- UnsupportedPlatform ;
- UnsupportedImageFormat ;
- InvalidImage ;
- ImageTooLarge ;
- InvalidRegion ;
- ModelNotFound ;
- ModelDownloadFailed ;
- ModelIntegrityError ;
- ModelCompatibilityError ;
- InferenceError ;
- UnsupportedLanguage ;
- UnsupportedExecutionProvider ;
- PdfProcessingError ;
- InsufficientMemory ;
- ProcessingCancelled ;
- ProcessingTimeout ;
- InternalError.

Chaque erreur doit contenir :

- Un code stable ;
- Un message compréhensible ;
- Un contexte technique non sensible ;
- Une indication sur la possibilité de réessayer.

Ne jamais laisser une panic Rust traverser une frontière FFI.

---

## 18. Application Flutter de démonstration

Développer une application de démonstration complète dans le dossier `example`.

L'application doit présenter une interface moderne, responsive et professionnelle.

### Écrans attendus

#### 18.1. Accueil

- Reconnaissance d'image ;
- OCR caméra ;
- OCR PDF ;
- Traitement par lots ;
- Extraction documentaire ;
- Gestion des modèles ;
- Paramètres ;
- Benchmarks.

#### 18.2. Reconnaissance d'image

- Sélection d'une image ;
- Aperçu ;
- Rotation ;
- Recadrage ;
- Évaluation de la qualité ;
- Lancement de la reconnaissance ;
- Indicateur de progression ;
- Affichage du résultat.

#### 18.3. Visualisation des résultats

- Affichage de l'image originale ;
- Superposition des zones détectées ;
- Affichage des polygones ;
- Sélection des blocs ;
- Affichage des scores disponibles ;
- Affichage du texte reconnu ;
- Copie du texte ;
- Export TXT ;
- Export JSON.

#### 18.4. OCR caméra

- Aperçu caméra ;
- Zone de cadrage ;
- Détection en temps réel ;
- Superposition des régions détectées ;
- Indicateurs de qualité ;
- Capture automatique configurable ;
- Affichage des résultats stabilisés.

#### 18.5. OCR PDF

- Sélection du document ;
- Sélection des pages ;
- Aperçu ;
- Progression ;
- Résultats par page ;
- Export des résultats.

#### 18.6. Gestion des modèles

- Modèles disponibles ;
- Modèles installés ;
- Langues ;
- Taille ;
- Téléchargement ;
- Progression ;
- Suppression ;
- Sélection du modèle actif.

#### 18.7. Benchmarks

- Temps d'initialisation ;
- Temps de prétraitement ;
- Temps de détection ;
- Temps de reconnaissance ;
- Temps de post-traitement ;
- Temps total ;
- Backend utilisé ;
- Consommation mémoire lorsque mesurable ;
- Informations sur l'appareil.

L'application doit utiliser exclusivement l'API publique du plugin pour les fonctionnalités OCR afin de démontrer sa facilité d'intégration.

---

## 19. Tests et assurance qualité

### 19.1. Tests Rust

Implémenter des tests couvrant :

- Le décodage des images ;
- Le prétraitement ;
- Les transformations géométriques ;
- Les tenseurs ;
- Le décodage des prédictions ;
- Le post-traitement ;
- Le chargement des modèles ;
- La gestion des erreurs ;
- La concurrence ;
- L'annulation ;
- L'extraction structurée ;
- Les entrées invalides.

### 19.2. Tests Flutter

Implémenter :

- Tests unitaires ;
- Tests des modèles ;
- Tests de sérialisation ;
- Tests de configuration ;
- Tests de l'API publique ;
- Tests du cycle de vie ;
- Tests des Streams ;
- Tests d'intégration ;
- Tests de l'application de démonstration.

### 19.3. Tests fonctionnels OCR

Créer un corpus de test contenant des images et documents dont le texte de référence est connu.

Inclure :

- Textes français ;
- Textes anglais ;
- Caractères accentués ;
- Documents inclinés ;
- Images floues ;
- Images sombres ;
- Documents multicolonnes ;
- Reçus ;
- Formulaires ;
- Documents PDF ;
- Images sans texte ;
- Images de grande résolution ;
- Fichiers invalides.

Utiliser des documents synthétiques ou des documents dont la licence autorise la redistribution.

Ne pas intégrer de véritables documents d'identité personnels au repository.

### 19.4. Métriques OCR

Calculer notamment :

- Character Error Rate (CER) ;
- Word Error Rate (WER) ;
- Précision de détection ;
- Rappel de détection ;
- F1-score ;
- Intersection over Union (IoU) ;
- Exact Match ;
- Latence moyenne ;
- Latence médiane ;
- Latence P95 ;
- Débit de traitement ;
- Consommation mémoire ;
- Taille des modèles.

Documenter le protocole d'évaluation, les conditions matérielles et les règles de normalisation.

---

## 20. Benchmarks

Créer un système reproductible de benchmarks.

Comparer lorsque possible :

- PaddleOCR ;
- OCRS ;
- Tesseract ;
- Différents modèles PaddleOCR ;
- Différents profils de performance ;
- CPU et accélérateurs disponibles.

Les comparaisons doivent utiliser les mêmes données et des conditions comparables.

Générer des rapports contenant :

- Le modèle utilisé ;
- La plateforme ;
- Le matériel ;
- La configuration ;
- Le temps de chargement ;
- Le temps de traitement ;
- La qualité de reconnaissance ;
- La consommation mémoire ;
- La taille des modèles ;
- Les limites observées.

Ne jamais inventer des résultats de benchmarks.

Si un benchmark ne peut pas être exécuté, fournir le script et indiquer explicitement qu'il reste à exécuter.

---

## 21. CI/CD et compilation

Configurer GitHub Actions pour automatiser, selon les environnements disponibles :

- Flutter analyze ;
- Dart format ;
- Flutter test ;
- Cargo fmt ;
- Cargo clippy ;
- Cargo test ;
- Tests d'intégration ;
- Vérification des dépendances ;
- Audit de sécurité ;
- Génération des bindings ;
- Compilation Android ;
- Compilation iOS ;
- Compilation Windows ;
- Compilation Linux ;
- Compilation macOS ;
- Compilation Web si supportée.

Documenter les prérequis :

- Rust toolchain ;
- Flutter SDK ;
- Android SDK ;
- Android NDK ;
- Xcode ;
- CMake ;
- Visual Studio Build Tools ;
- Outils de génération FFI ;
- Dépendances natives du runtime.

La compilation doit être reproductible.

Les bibliothèques natives doivent être correctement intégrées aux packages distribués.

L'application cliente ne doit pas avoir besoin d'installer manuellement Rust pour une intégration standard du plugin distribué, sauf contrainte technique explicitement documentée.

---

## 22. Documentation

Rédiger la documentation principale en anglais pour faciliter l'adoption internationale.

Prévoir également un README en français.

Créer notamment :

```text
docs/
├── architecture.md
├── getting_started.md
├── installation.md
├── configuration.md
├── image_ocr.md
├── realtime_ocr.md
├── pdf_ocr.md
├── document_extraction.md
├── model_management.md
├── custom_models.md
├── performance.md
├── benchmarks.md
├── platform_support.md
├── security.md
├── troubleshooting.md
├── limitations.md
└── api_reference.md
```

La documentation doit expliquer :

- L'installation ;
- Les prérequis ;
- L'utilisation ;
- Les paramètres ;
- Les résultats ;
- Les erreurs ;
- Les modèles compatibles ;
- Les langues disponibles ;
- Les performances ;
- Les limitations ;
- Les permissions ;
- L'intégration dans une application existante ;
- L'ajout de nouveaux modèles ;
- L'ajout de nouveaux backends.

Créer des Architecture Decision Records (ADR) pour les décisions techniques importantes.

---

## 23. Publication sur pub.dev

Préparer le plugin pour sa publication.

Vérifier :

- La structure du package ;
- Les métadonnées ;
- Les contraintes de versions ;
- Les dépendances ;
- Les plateformes déclarées ;
- Les exemples ;
- La documentation publique ;
- Les licences ;
- Le CHANGELOG ;
- Les fichiers distribués ;
- La taille du package ;
- Les liens vers le repository.

Exécuter :

```bash
dart pub publish --dry-run
```

Ne pas publier réellement le package sans autorisation explicite.

Étudier une licence permissive telle que MIT ou Apache-2.0, sous réserve de compatibilité avec les dépendances, modèles et bibliothèques natives.

Documenter séparément les licences du code, des modèles et des composants tiers.

---

## 24. Méthodologie de développement

Procéder par phases successives et vérifiables.

### Phase 0 — Audit technique

- Examiner l'environnement existant.
- Vérifier les outils installés.
- Étudier les dépendances.
- Vérifier les modèles disponibles.
- Vérifier les licences.
- Identifier les contraintes multiplateformes.
- Produire les décisions d'architecture.
- Définir les critères d'acceptation.

### Phase 1 — Fondation

- Initialiser le repository.
- Créer le package Flutter.
- Initialiser le projet Rust.
- Configurer flutter_rust_bridge.
- Générer les bindings.
- Valider les échanges Dart/Rust.
- Configurer les tests et outils de qualité.

### Phase 2 — MVP OCR

- Charger un modèle de détection.
- Charger un modèle de reconnaissance.
- Traiter une image réelle.
- Retourner le texte et les régions détectées.
- Valider le fonctionnement hors ligne.
- Tester le français et l'anglais.

### Phase 3 — Robustesse du moteur

- Prétraitement configurable ;
- Correction d'orientation ;
- Gestion des erreurs ;
- Optimisation mémoire ;
- Gestion des modèles ;
- Résultats structurés ;
- Traitement par lots.

### Phase 4 — OCR temps réel

- Flux caméra ;
- Backpressure ;
- Stabilisation ;
- Annulation ;
- Optimisation ;
- Application de démonstration.

### Phase 5 — OCR documentaire

- PDF ;
- Analyse de mise en page ;
- Ordre de lecture ;
- Colonnes ;
- Tableaux ;
- Extraction structurée ;
- Templates personnalisés.

### Phase 6 — Multiplateforme

- Android ;
- iOS ;
- Windows ;
- Linux ;
- macOS ;
- Étude et implémentation Web.

### Phase 7 — Qualité et publication

- Tests complets ;
- Benchmarks ;
- Audit de sécurité ;
- Documentation ;
- CI/CD ;
- Vérification du package ;
- Préparation de la publication.

Chaque phase doit produire du code fonctionnel et des résultats vérifiables avant de passer à la suivante.

---

## 25. Critères d'acceptation

Le projet sera considéré comme fonctionnel lorsque les critères applicables seront satisfaits.

| ID | Critère |
|---|---|
| AC-001 | Le plugin compile sur les plateformes déclarées supportées. |
| AC-002 | Flutter communique correctement avec Rust. |
| AC-003 | Un véritable modèle OCR est exécuté localement. |
| AC-004 | Le moteur fonctionne sans connexion Internet après installation des modèles. |
| AC-005 | Une image réelle peut être traitée. |
| AC-006 | Le texte français et anglais est reconnu sur le corpus de validation. |
| AC-007 | Les régions détectées sont retournées dans le référentiel documenté. |
| AC-008 | L'interface Flutter reste réactive pendant le traitement. |
| AC-009 | Les ressources natives sont correctement libérées. |
| AC-010 | Les modèles peuvent être chargés depuis des assets locaux. |
| AC-011 | Les modèles externes sont validés avant utilisation. |
| AC-012 | Les erreurs sont correctement propagées vers Dart. |
| AC-013 | Les traitements longs peuvent être annulés. |
| AC-014 | Le traitement par lots fonctionne. |
| AC-015 | Le traitement PDF fonctionne sur les plateformes annoncées. |
| AC-016 | L'OCR caméra fonctionne sur les plateformes mobiles annoncées. |
| AC-017 | Les résultats peuvent être sérialisés en JSON. |
| AC-018 | L'application de démonstration fonctionne. |
| AC-019 | Les tests automatisés passent. |
| AC-020 | Les benchmarks sont reproductibles. |
| AC-021 | Aucun document n'est envoyé automatiquement vers un serveur. |
| AC-022 | La documentation permet une intégration indépendante. |
| AC-023 | Les dépendances et modèles respectent les exigences de licence. |
| AC-024 | Le package passe les vérifications de publication applicables. |

---

## 26. Règles impératives de développement

1. Ne pas produire uniquement une proposition d'architecture.
2. Créer réellement les fichiers du projet.
3. Ne pas utiliser de résultats OCR simulés dans l'implémentation de production.
4. Ne pas retourner de valeurs codées en dur pour masquer une fonctionnalité manquante.
5. Ne pas laisser de TODO critiques dans les fonctionnalités annoncées comme terminées.
6. Ne pas inventer d'API ou de dépendances.
7. Vérifier la documentation officielle des bibliothèques utilisées.
8. Ne pas masquer les erreurs de compilation.
9. Corriger les erreurs rencontrées avant de poursuivre.
10. Exécuter réellement les tests disponibles.
11. Ne pas inventer les résultats des tests.
12. Ne pas déclarer une plateforme fonctionnelle sans validation.
13. Ne pas imposer de connexion Internet pour la reconnaissance.
14. Ne pas introduire de dépendance à Google ML Kit.
15. Ne pas introduire de dépendance à une API OCR distante.
16. Éviter les dépendances inutiles.
17. Respecter les conventions Flutter, Dart et Rust.
18. Documenter les décisions techniques.
19. Maintenir la compatibilité de l'API publique.
20. Préserver les fonctionnalités existantes lors des évolutions.
21. Utiliser des données de test autorisées.
22. Signaler explicitement les fonctionnalités non implémentées ou non vérifiées.
23. Ne pas désactiver les tests ou les contrôles de sécurité pour obtenir artificiellement une compilation réussie.
24. Ne pas effectuer d'opérations destructives sur un repository existant sans autorisation.
25. Ne pas publier le package ou engager de dépenses sans autorisation.

---

## 27. Suivi de l'avancement

Maintenir à la racine du projet un fichier `PROJECT_STATUS.md` contenant :

- Les fonctionnalités terminées ;
- Les fonctionnalités en cours ;
- Les fonctionnalités restantes ;
- Les décisions techniques ;
- Les problèmes rencontrés ;
- Les solutions appliquées ;
- Les tests exécutés ;
- Les résultats des tests ;
- Les plateformes effectivement validées ;
- Les limitations connues ;
- Les prochaines étapes.

Maintenir également une matrice de compatibilité par plateforme et par fonctionnalité.

Utiliser les statuts suivants :

- Not started ;
- In progress ;
- Implemented ;
- Tested ;
- Blocked.

Ne pas confondre une fonctionnalité implémentée avec une fonctionnalité effectivement testée.

---

## 28. Livrables finaux

À l'issue du développement, fournir :

1. Le code source complet du plugin Flutter.
2. Le moteur OCR Rust.
3. Les bindings Dart/Rust.
4. Les intégrations natives par plateforme.
5. Le système de gestion des modèles.
6. Les manifestes des modèles.
7. Les scripts de préparation et de conversion des modèles.
8. L'application Flutter de démonstration.
9. Les tests unitaires.
10. Les tests d'intégration.
11. Le corpus de validation autorisé.
12. Les scripts de benchmarks.
13. Les résultats réellement obtenus.
14. La documentation technique.
15. La documentation développeur.
16. Les diagrammes d'architecture.
17. Les workflows CI/CD.
18. Les informations de licence.
19. La matrice de compatibilité.
20. Le rapport final de développement.
21. Un package préparé pour publication sur pub.dev.

---

## 29. Instructions de démarrage

Commence immédiatement par analyser l'environnement de développement et le contenu du repository.

Si le repository est vide, initialise le projet.

Si le repository contient déjà du code, analyse son architecture avant toute modification et préserve les fonctionnalités existantes.

Effectue les opérations suivantes :

1. Vérifie les versions de Flutter, Dart, Rust et des outils natifs.
2. Recherche les versions compatibles de flutter_rust_bridge et des moteurs d'inférence.
3. Identifie les modèles OCR réellement disponibles et redistribuables.
4. Sélectionne les modèles de détection et de reconnaissance adaptés au français et à l'anglais.
5. Définis l'architecture définitive.
6. Crée les fichiers de documentation et de suivi.
7. Initialise le package Flutter et le moteur Rust.
8. Implémente le bridge.
9. Valide la communication Dart/Rust.
10. Implémente un premier pipeline OCR complet sur une image réelle.
11. Exécute les tests.
12. Corrige les erreurs.
13. Poursuis progressivement les autres phases.

Ne t'arrête pas après la présentation du plan.

Travaille directement dans le repository, utilise le terminal, crée et modifie les fichiers nécessaires, compile le projet et vérifie chaque fonctionnalité.

Privilégie systématiquement une implémentation fonctionnelle, robuste et vérifiable plutôt qu'une architecture ambitieuse mais incomplète.

Lorsque plusieurs solutions techniques sont possibles, sélectionne celle qui offre le meilleur compromis entre performances, précision, portabilité, maintenabilité et facilité d'intégration.

En cas de blocage, recherche une alternative compatible, documente la décision et poursuis les tâches indépendantes.

Ne sollicite l'utilisateur que lorsqu'une décision indispensable ne peut pas être prise raisonnablement sans son intervention.

à chaque fonctionnalité, teste et commit

**Commence maintenant le développement.**
