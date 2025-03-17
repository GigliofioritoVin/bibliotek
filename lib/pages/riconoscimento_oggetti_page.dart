import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:flutter_tts/flutter_tts.dart';

class RiconoscimentoOggettiPage extends StatefulWidget {
  final bool isTTSActive;
  const RiconoscimentoOggettiPage({super.key, required this.isTTSActive});

  @override
  State<RiconoscimentoOggettiPage> createState() =>
      _RiconoscimentoOggettiPageState();
}

class _RiconoscimentoOggettiPageState extends State<RiconoscimentoOggettiPage> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  late ImageLabeler _imageLabeler;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _captureAndRecognizeObjects() async {
    if (!_isCameraInitialized || _cameraController == null) return;
    try {
      final XFile image = await _cameraController!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(image.path);
      final List<ImageLabel> labels =
          await _imageLabeler.processImage(inputImage);

      if (labels.isNotEmpty) {
        String recognizedObjects = labels
            .where((label) => label.confidence > 0.6) // Filtra per confidenza
            .map((label) => label.label)
            .join(", ");
        _speakText("Oggetti riconosciuti: $recognizedObjects");
      } else {
        _speakText("Nessun oggetto riconosciuto.");
      }
    } catch (e) {
      _speakText("Errore nel riconoscimento degli oggetti: $e");
    }
  }

  Future<void> _speakText(String text) async {
    if (widget.isTTSActive) {
      await flutterTts.setLanguage("it-IT");
      await flutterTts.speak(text);
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    _cameraController?.dispose();
    _imageLabeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riconoscimento Oggetti")),
      body: Column(
        children: [
          if (_isCameraInitialized)
            Expanded(child: CameraPreview(_cameraController!))
          else
            const Center(child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (widget.isTTSActive) {
                  await _speakText("Scatta e riconosci");
                }
                await _captureAndRecognizeObjects(); // Ora viene eseguito dopo il TTS
              },
              child: const Text("Scatta e riconosci"),
            ),
          ),
        ],
      ),
    );
  }
}
