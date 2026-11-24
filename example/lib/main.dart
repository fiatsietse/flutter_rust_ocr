import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_rust_ocr/flutter_rust_ocr.dart';

void main() {
  runApp(const OcrDemoApp());
}

class OcrDemoApp extends StatelessWidget {
  const OcrDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Rust OCR Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RustOcrEngine _engine = RustOcrEngine();
  bool _isInitialized = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  Future<void> _initEngine() async {
    try {
      await _engine.initialize(
        config: const OcrConfig(
          languages: ['fr', 'en'],
          modelProfile: OcrModelProfile.balanced,
        ),
      );
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Rust OCR Demo'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Chip(
              avatar: Icon(
                _isInitialized ? Icons.check_circle : Icons.hourglass_top,
                color: _isInitialized ? Colors.green : Colors.orange,
                size: 16,
              ),
              label: Text(_isInitialized ? 'Moteur prêt' : 'Initialisation...'),
            ),
          )
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.image),
                label: Text('Image OCR'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.dynamic_feed),
                label: Text('Lots'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment),
                label: Text('Documents'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.videocam),
                label: Text('Temps réel'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.speed),
                label: Text('Benchmarks'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildSelectedTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTab() {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_selectedIndex) {
      case 0:
        return ImageOcrView(engine: _engine);
      case 1:
        return BatchOcrView(engine: _engine);
      case 2:
        return DocumentExtractionView(engine: _engine);
      case 3:
        return RealtimeOcrView(engine: _engine);
      case 4:
        return BenchmarkView(engine: _engine);
      default:
        return const SizedBox.shrink();
    }
  }
}

// 1. Image OCR View
class ImageOcrView extends StatefulWidget {
  final RustOcrEngine engine;
  const ImageOcrView({super.key, required this.engine});

  @override
  State<ImageOcrView> createState() => _ImageOcrViewState();
}

class _ImageOcrViewState extends State<ImageOcrView> {
  final TextEditingController _pathController = TextEditingController();
  OcrResult? _result;
  OcrImageQuality? _quality;
  MrzResult? _mrz;
  Uint8List? _loadedImageBytes;
  String? _selectedFileName;
  bool _loading = false;
  String? _errorMessage;

  // 1x1 dummy PNG image for testing
  final Uint8List _sampleImageBytes = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
  ]);

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  Future<void> _pickAndProcessFile() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final pickerResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'webp', 'pdf'],
        withData: true,
      );

      if (pickerResult != null && pickerResult.files.isNotEmpty) {
        final picked = pickerResult.files.first;
        Uint8List? bytes = picked.bytes;
        if (bytes == null && picked.path != null) {
          bytes = await File(picked.path!).readAsBytes();
        }

        if (bytes != null) {
          final isImage = picked.extension?.toLowerCase() != 'pdf';
          setState(() {
            _selectedFileName = picked.name;
            _pathController.text = picked.path ?? picked.name;
            _loadedImageBytes = isImage ? bytes : null;
          });
          await _processBytes(bytes, isPdf: picked.extension?.toLowerCase() == 'pdf', filePath: picked.path);
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'Erreur lors de la sélection du fichier : $e');
    }
  }

  Future<void> _processBytes(Uint8List bytes, {bool isPdf = false, String? filePath}) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _mrz = null;
    });

    try {
      OcrResult r;
      OcrImageQuality? q;

      if (isPdf && filePath != null) {
        final pdfResults = await widget.engine.recognizePdf(
          filePath: filePath,
          strategy: PdfOcrStrategy.automatic,
        );
        r = pdfResults.isNotEmpty
            ? pdfResults.first
            : const OcrResult(
                text: 'Document PDF traité.',
                confidence: 1.0,
                processingTimeMs: 10,
                imageWidth: 0,
                imageHeight: 0,
              );
      } else {
        q = await widget.engine.analyzeImageQuality(bytes);
        r = await widget.engine.recognizeBytes(bytes);
      }

      MrzResult? mrzRes;
      if (r.text.contains('<')) {
        mrzRes = MrzParser.parse(r.text);
      }

      setState(() {
        _quality = q;
        _result = r;
        _mrz = mrzRes;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Erreur OCR : $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _processCustomFile() async {
    final path = _pathController.text.trim();
    if (path.isEmpty) return;

    final file = File(path);
    if (!file.existsSync()) {
      setState(() => _errorMessage = 'Fichier introuvable : $path');
      return;
    }

    final bytes = await file.readAsBytes();
    final isPdf = path.toLowerCase().endsWith('.pdf');
    setState(() {
      _selectedFileName = file.uri.pathSegments.last;
      _loadedImageBytes = isPdf ? null : bytes;
    });
    await _processBytes(bytes, isPdf: isPdf, filePath: path);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reconnaissance OCR sur Document Réel',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez une image (JPG, PNG, WebP) ou un document PDF pour en extraire le texte et les informations.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _loading ? null : _pickAndProcessFile,
                icon: const Icon(Icons.file_upload),
                label: const Text('Charger un fichier (Parcourir)...'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _loading ? null : () {
                  setState(() {
                    _selectedFileName = 'Échantillon 1x1 test';
                    _loadedImageBytes = _sampleImageBytes;
                  });
                  _processBytes(_sampleImageBytes);
                },
                icon: const Icon(Icons.image),
                label: const Text('Tester avec échantillon'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pathController,
                  decoration: InputDecoration(
                    labelText: 'Ou collez un chemin de fichier local',
                    hintText: 'C:\\Users\\...\\document.jpg',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.link),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      tooltip: 'Analyser le chemin saisi',
                      onPressed: _loading ? null : _processCustomFile,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (_loading) const Center(child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          )),
          if (_selectedFileName != null) ...[
            Row(
              children: [
                Chip(
                  avatar: const Icon(Icons.description, size: 16),
                  label: Text('Fichier : $_selectedFileName'),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (_loadedImageBytes != null) ...[
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(_loadedImageBytes!, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_quality != null) ...[
            Card(
              child: ListTile(
                leading: Icon(
                  _quality!.isAcceptable ? Icons.thumb_up : Icons.warning,
                  color: _quality!.isAcceptable ? Colors.green : Colors.orange,
                ),
                title: const Text('Évaluation de la qualité d\'image'),
                subtitle: Text(
                  'Netteté: ${(_quality!.blurScore * 100).toStringAsFixed(1)}% | '
                  'Luminosité: ${(_quality!.brightnessScore * 100).toStringAsFixed(1)}% | '
                  'Contraste: ${(_quality!.contrastScore * 100).toStringAsFixed(1)}%',
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_mrz != null) ...[
            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(Icons.badge, color: Colors.green),
                title: Text('Zone MRZ Détectée (${_mrz!.documentType})'),
                subtitle: Text(
                  'Titulaire: ${_mrz!.surname} ${_mrz!.givenNames} | N°: ${_mrz!.documentNumber} | Exp: ${_mrz!.expiryDate} | Valide: ${_mrz!.isValid}',
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_result != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Texte extrait (${_result!.processingTimeMs} ms) :',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _result!.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Texte copié dans le presse-papier !')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copier'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _result!.text.isEmpty
                        ? 'Image traitée avec succès (aucun texte détecté).'
                        : _result!.text,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 2. Batch OCR View
class BatchOcrView extends StatefulWidget {
  final RustOcrEngine engine;
  const BatchOcrView({super.key, required this.engine});

  @override
  State<BatchOcrView> createState() => _BatchOcrViewState();
}

class _BatchOcrViewState extends State<BatchOcrView> {
  OcrProgress? _progress;
  bool _running = false;

  Future<void> _runBatch() async {
    setState(() => _running = true);
    final task = widget.engine.recognizeBatch(imagePaths: []);
    task.progress.listen((p) {
      setState(() => _progress = p);
    });

    await task.result;
    setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton.icon(
            onPressed: _running ? null : _runBatch,
            icon: const Icon(Icons.playlist_play),
            label: const Text('Lancer traitement par lots'),
          ),
          const SizedBox(height: 24),
          if (_progress != null) ...[
            Text('Progression: ${_progress.toString()}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: _progress!.percentage),
          ],
        ],
      ),
    );
  }
}

// 3. Document Extraction View
class DocumentExtractionView extends StatefulWidget {
  final RustOcrEngine engine;
  const DocumentExtractionView({super.key, required this.engine});

  @override
  State<DocumentExtractionView> createState() => _DocumentExtractionViewState();
}

class _DocumentExtractionViewState extends State<DocumentExtractionView> {
  OcrDocumentResult? _extracted;

  final DocumentTemplate _cniTemplate = const DocumentTemplate(
    id: 'id_card_fr',
    version: '1.0',
    name: 'Carte Nationale d\'Identité',
    fields: [
      DocumentFieldDefinition(
        name: 'documentNumber',
        type: 'string',
        required: true,
        labels: ['Numéro', 'N°', 'Document No'],
      ),
      DocumentFieldDefinition(
        name: 'birthDate',
        type: 'date',
        required: true,
        labels: ['Né le', 'Date de naissance', 'Birth date'],
      ),
    ],
  );

  Future<void> _extract() async {
    final dummyBytes = Uint8List.fromList([1, 2, 3]);
    final res = await widget.engine.extractDocument(
      imageBytes: dummyBytes,
      template: _cniTemplate,
    );
    setState(() => _extracted = res);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton.icon(
            onPressed: _extract,
            icon: const Icon(Icons.document_scanner),
            label: const Text('Extraire gabarit CNI'),
          ),
          const SizedBox(height: 24),
          if (_extracted != null) ...[
            Text('Gabarit: ${_extracted!.templateId} (Complet: ${_extracted!.isComplete})'),
            const SizedBox(height: 8),
            Text('Champs extraits: ${jsonEncode(_extracted!.toJson())}'),
          ]
        ],
      ),
    );
  }
}

// 4. Realtime OCR View
class RealtimeOcrView extends StatefulWidget {
  final RustOcrEngine engine;
  const RealtimeOcrView({super.key, required this.engine});

  @override
  State<RealtimeOcrView> createState() => _RealtimeOcrViewState();
}

class _RealtimeOcrViewState extends State<RealtimeOcrView> {
  RealtimeOcrSession? _session;
  String _lastText = '';

  @override
  void initState() {
    super.initState();
    _session = widget.engine.createRealtimeSession(
      config: const RealtimeOcrConfig(maxFramesPerSecond: 10),
    );
    _session?.results.listen((r) {
      if (mounted) {
        setState(() => _lastText = r.text);
      }
    });
  }

  @override
  void dispose() {
    _session?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Session temps réel active (simulation flux caméra)'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              _session?.submitFrame(Uint8List.fromList([1, 2, 3, 4]));
            },
            child: const Text('Soumettre une trame (frame)'),
          ),
          const SizedBox(height: 24),
          Text('Dernier texte stabilisé : $_lastText'),
        ],
      ),
    );
  }
}

// 5. Benchmark View
class BenchmarkView extends StatefulWidget {
  final RustOcrEngine engine;
  const BenchmarkView({super.key, required this.engine});

  @override
  State<BenchmarkView> createState() => _BenchmarkViewState();
}

class _BenchmarkViewState extends State<BenchmarkView> {
  String _benchmarkResults = 'Prêt pour l\'exécution des benchmarks.';

  Future<void> _runBenchmark() async {
    setState(() => _benchmarkResults = 'Exécution en cours...');
    final stopwatch = Stopwatch()..start();
    final dummyBytes = Uint8List.fromList([1, 2, 3]);

    const iterations = 50;
    for (int i = 0; i < iterations; i++) {
      await widget.engine.recognizeBytes(dummyBytes);
    }
    stopwatch.stop();

    final avgMs = stopwatch.elapsedMilliseconds / iterations;
    setState(() {
      _benchmarkResults =
          'Itérations: $iterations\nTemps total: ${stopwatch.elapsedMilliseconds} ms\n'
          'Latence moyenne par appel: ${avgMs.toStringAsFixed(2)} ms\n'
          'Débit estimé: ${(1000 / avgMs).toStringAsFixed(1)} FPS';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton.icon(
            onPressed: _runBenchmark,
            icon: const Icon(Icons.flash_on),
            label: const Text('Lancer Benchmark de performance'),
          ),
          const SizedBox(height: 24),
          Text(_benchmarkResults, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
