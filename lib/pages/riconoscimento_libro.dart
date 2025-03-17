import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'biblioteca_page.dart';

class RiconoscimentoLibroPage extends StatefulWidget {
  final String titleLibro;

  const RiconoscimentoLibroPage({Key? key, required this.titleLibro})
      : super(key: key);

  @override
  _RiconoscimentoLibroPageState createState() =>
      _RiconoscimentoLibroPageState();
}

class _RiconoscimentoLibroPageState extends State<RiconoscimentoLibroPage> {
  CameraController? _controller;
  bool _isProcessing = false;
  late List<CameraDescription> _cameras;
  List<Rect> _rectangleCoords = [];
  XFile? _scattoFoto;
  bool _libroTrovato = false;
  double _scaleX = 1;
  double _scaleY = 1;

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  void _resetCamera() {
    setState(() {
      _scattoFoto = null;
      _rectangleCoords.clear();
      _libroTrovato = false;
    });
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _scattaFoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _libroTrovato = false;
    });

    final XFile foto = await _controller!.takePicture();
    final File imageFile = File(foto.path);
    final image = await decodeImageFromList(imageFile.readAsBytesSync());

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    setState(() {
      _scaleX = screenWidth / image.width;
      _scaleY = screenHeight / image.height;
      _scattoFoto = foto;
    });

    await _analizzaTesto(foto.path);
  }

  Future<void> _analizzaTesto(String imagePath) async {
    final InputImage image = InputImage.fromFilePath(imagePath);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();  //perchè viene deprecata?
    final RecognizedText recognizedText =
        await textRecognizer.processImage(image);

    String titoloLibroNormalizzato = _normalizzaTesto(widget.titleLibro);
    _rectangleCoords.clear();
    _libroTrovato = false;

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        if (_normalizzaTesto(line.text).contains(titoloLibroNormalizzato)) {
          _libroTrovato = true;
          _rectangleCoords.add(block.boundingBox);
          break;
        }
      }
    }

    await textRecognizer.close();

    setState(() {
      _isProcessing = false;
    });

    if (!_libroTrovato) {
      _mostraAvviso("Libro non trovato", "Prova a scattare di nuovo la foto.");
    } else {
      _mostraAvviso("Libro trovato!",
          "Il libro \"${widget.titleLibro}\" è stato individuato.");
    }
  }

  String _normalizzaTesto(String testo) {
    return testo
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  void _mostraAvviso(String titolo, String messaggio) {
    flutterTts.speak(messaggio);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titolo),
          content: Text(messaggio),
          actions: [
            TextButton(
              onPressed: () {
                flutterTts.speak("OK");
                Navigator.of(context).pop();
                if (!_libroTrovato) {
                  _resetCamera();
                }
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _scattoFoto == null
              ? CameraPreview(_controller!)
              : Image.file(File(_scattoFoto!.path), fit: BoxFit.cover),
          if (_scattoFoto != null)
            CustomPaint(
              painter:
                  TextRecognitionPainter(_rectangleCoords, _scaleX, _scaleY),
              child: Container(),
            ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.home, size: 30, color: Colors.white),
              onPressed: () {
                flutterTts.speak("Torna alla Home");
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => BibliotecaPage()),
                );
              },
            ),
          ),
          if (_scattoFoto == null)
            Positioned(
              bottom: 50,
              left: MediaQuery.of(context).size.width * 0.35,
              child: ElevatedButton(
                onPressed: _scattaFoto,
                child: Text("Scatta Foto"),
              ),
            ),
          if (_scattoFoto != null)
            Positioned(
              bottom: 50,
              left: MediaQuery.of(context).size.width * 0.5 - 50,
              child: ElevatedButton(
                onPressed: _resetCamera,
                child: Text("Riprova"),
              ),
            ),
        ],
      ),
    );
  }
}

class TextRecognitionPainter extends CustomPainter {
  final List<Rect> rectangles;
  final double scaleX;
  final double scaleY;

  TextRecognitionPainter(this.rectangles, this.scaleX, this.scaleY);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    for (var rect in rectangles) {
      final adjustedRect = Rect.fromLTRB(
        rect.left * scaleX,
        rect.top * scaleY,
        rect.right * scaleX,
        rect.bottom * scaleY,
      );
      canvas.drawRect(adjustedRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
