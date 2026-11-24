import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
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
  OcrResult? _result;
  OcrImageQuality? _quality;
  bool _loading = false;

  // 1x1 dummy PNG image for testing
  final Uint8List _sampleImageBytes = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
  ]);

  Future<void> _processSample() async {
    setState(() => _loading = true);
    try {
      final q = await widget.engine.analyzeImageQuality(_sampleImageBytes);
      final r = await widget.engine.recognizeBytes(_sampleImageBytes);
      setState(() {
        _quality = q;
        _result = r;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FilledButton.icon(
                onPressed: _loading ? null : _processSample,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Tester reconnaissance image'),
              ),
              const SizedBox(width: 16),
              if (_loading) const CircularProgressIndicator(),
            ],
          ),
          const SizedBox(height: 24),
          if (_quality != null) ...[
            Card(
              child: ListTile(
                leading: Icon(
                  _quality!.isAcceptable ? Icons.thumb_up : Icons.warning,
                  color: _quality!.isAcceptable ? Colors.green : Colors.orange,
                ),
                title: const Text('Évaluation de la qualité'),
                subtitle: Text(
                  'Netteté: ${(_quality!.blurScore * 100).toStringAsFixed(1)}% | '
                  'Luminosité: ${(_quality!.brightnessScore * 100).toStringAsFixed(1)}% | '
                  'Contraste: ${(_quality!.contrastScore * 100).toStringAsFixed(1)}%',
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_result != null) ...[
            Text('Résultat OCR (${_result!.processingTimeMs} ms):',
                style: Theme.of(context).textTheme.titleMedium),
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
                        ? 'Image échantillon traitée avec succès (aucun texte détecté sur le pixel test).'
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
