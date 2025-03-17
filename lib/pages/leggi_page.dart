import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class LeggiPage extends StatefulWidget {
  final bool isTTSActive;
  const LeggiPage({super.key, required this.isTTSActive});

  @override
  State<LeggiPage> createState() => _LeggiPageState();
}

class _LeggiPageState extends State<LeggiPage> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false; // Variabile per gestire lo stato del pulsante
  final TextRecognizer textRecognizer = TextRecognizer();
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Funzione per inizializzare la fotocamera e verificare i permessi
  Future<void> _initializeCamera() async {
    final cameraPermissionStatus = await Permission.camera.request();
    if (cameraPermissionStatus.isGranted) {
      _cameras = await availableCameras();
      _cameraController =
          CameraController(_cameras[0], ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } else {
      await _speakText('Permesso fotocamera non concesso');
    }
  }

  // Funzione per catturare la foto e leggere il testo
  Future<void> _captureAndReadText() async {
    if (_isProcessing || !_isCameraInitialized || _cameraController == null)
      return;

    setState(() {
      _isProcessing = true; // Disabilita il pulsante durante l'elaborazione
    });

    try {
      final XFile image = await _cameraController!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      String extractedText = recognizedText.text;
      if (extractedText.isNotEmpty) {
        _speakText(extractedText);
      } else {
        _speakText("Nessun testo rilevato.");
      }
    } catch (e) {
      _speakText("Errore nella lettura del testo.");
    } finally {
      setState(() {
        _isProcessing = false; // Riabilita il pulsante dopo l'elaborazione
      });
    }
  }

  // Funzione per far parlare il TTS
  Future<void> _speakText(String text) async {
    if (widget.isTTSActive) {
      await flutterTts.speak(text);
    }
  }

  // Funzione per fermare il TTS
  Future<void> stopText() async {
    await flutterTts.stop();
  }

  @override
  void dispose() {
    flutterTts.pause();
    flutterTts.stop();
    _cameraController?.dispose();
    textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        flutterTts.stop(); // Ferma la lettura vocale quando si torna indietro
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Leggi con la Fotocamera")),
        body: Column(
          children: [
            if (_isCameraInitialized)
              Expanded(
                child: CameraPreview(_cameraController!),
              )
            else
              const Center(child: CircularProgressIndicator()),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _captureAndReadText,
                child: const Text("Scatta e Leggi"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
