import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FaceRecognitionPage extends StatefulWidget {
  @override
  _FaceRecognitionPageState createState() => _FaceRecognitionPageState();
}

class _FaceRecognitionPageState extends State<FaceRecognitionPage> {
  File? _image;
  List<Face>? _faces;
  FlutterTts _flutterTts = FlutterTts();
  final ImagePicker _picker = ImagePicker();
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
  Map<String, List<File>> _savedFaces = {}; // Per memorizzare volti e nomi

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getImageAndDetectFaces() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final faces = await _faceDetector.processImage(inputImage);

      setState(() {
        _faces = faces;
      });

      if (_faces!.isNotEmpty) {
        // Se c'è almeno un volto
        for (Face face in _faces!) {
          String? name = await _recognizeOrSaveFace(face);
          if (name != null) {
            await _flutterTts.speak('Ciao, $name');
          } else {
            await _flutterTts.speak('Volto non riconosciuto. Vuoi salvarlo?');
          }
        }
      }
    }
  }

  Future<String?> _recognizeOrSaveFace(Face face) async {
    // Compara il volto con quelli già salvati
    for (var name in _savedFaces.keys) {
      // Qui si può usare una logica di confronto di volti più avanzata, come il confronto di caratteristiche facciali
      // Ad esempio, usare il face landmarks per fare un matching
      // Se il volto è riconosciuto, restituisce il nome
      if (_isFaceRecognized(face, _savedFaces[name]!)) {
        return name;
      }
    }
    // Se il volto non è riconosciuto, chiedi se vuoi salvarlo
    return await _askToSaveFace(face);
  }

  Future<String?> _askToSaveFace(Face face) async {
    String? name = await showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text('Nuovo volto rilevato'),
          content: Column(
            children: [
              Text('Vuoi salvare questo volto?'),
              TextField(
                controller: controller,
                decoration: InputDecoration(hintText: "Inserisci nome"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // Non salvare
              },
              child: Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text); // Salva con il nome
              },
              child: Text('Salva'),
            ),
          ],
        );
      },
    );
    if (name != null && name.isNotEmpty) {
      // Salva il volto con il nome
      _saveFace(face, name);
      return name;
    }
    return null;
  }

  void _saveFace(Face face, String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$name.jpg';
    // Salva il volto come immagine (questa logica dipende da come desideri memorizzare il volto)
    await _image!.copy(filePath);
    setState(() {
      _savedFaces[name] = [...?_savedFaces[name], File(filePath)];
    });
  }

  bool _isFaceRecognized(Face face, List<File> savedFaces) {
    // Logica per verificare se il volto corrisponde (questa è una semplificazione, in un'app reale dovresti usare una libreria di confronto facciale)
    return false;
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riconoscimento Volti'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null) Image.file(_image!),
            if (_faces != null)
              Text(
                'Volti riconosciuti: ${_faces!.length}',
                style: TextStyle(fontSize: 18),
              ),
            ElevatedButton(
              onPressed: _getImageAndDetectFaces,
              child: Text("Rileva Volti"),
            ),
          ],
        ),
      ),
    );
  }
}
