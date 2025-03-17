import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import '../utils/csv_manager.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  _InventarioPageState createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String _risultatiLettura = "";
  String _esitoVerifica = "";
  bool _isProcessing = false;

  Future<void> _scattaFoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _isProcessing = true;
      });
      await _estraiTestoDallImmagine();
    }
  }

  Future<void> _estraiTestoDallImmagine() async {
    if (_image == null) return;
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(InputImage.fromFile(_image!));
    textRecognizer.close();

    setState(() {
      _risultatiLettura = recognizedText.text;
      _isProcessing = false;
    });

    await _verificaInventario();
  }

  Future<void> _verificaInventario() async {
    List<List<dynamic>> csvData = await getCSVData();
    if (csvData.isEmpty) {
      setState(() {
        _esitoVerifica = 'Errore: Nessun file CSV caricato o CSV vuoto!';
      });
      return;
    }

    List<String> libriRiconosciuti = _risultatiLettura.split('\n');
    Map<String, int> conteggioLibriFoto = {};

    for (var libro in libriRiconosciuti) {
      conteggioLibriFoto[libro] = (conteggioLibriFoto[libro] ?? 0) + 1;
    }

    Map<String, int> conteggioLibriInventario = {};
    for (var riga in csvData) {
      if (riga.isNotEmpty && riga.length > 1) {
        String titolo = riga[0].toString().toLowerCase();
        for (var libro in libriRiconosciuti) {
          if (libro.toLowerCase().contains(titolo)) {
            conteggioLibriInventario[titolo] =
                (conteggioLibriInventario[titolo] ?? 0) + 1;
          }
        }
      }
    }

    setState(() {
      _esitoVerifica = "Verifica completata.\n";
      conteggioLibriFoto.forEach((titolo, count) {
        _esitoVerifica += "$titolo: $count trovati in foto\n";
      });

      conteggioLibriInventario.forEach((titolo, count) {
        _esitoVerifica += "$titolo: $count trovati nell'inventario CSV\n";
      });

      if (conteggioLibriInventario.isEmpty) {
        _esitoVerifica += "Nessun libro trovato nell'inventario CSV.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventario Biblioteca")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                onPressed: _scattaFoto,
                icon:
                    const Icon(Icons.camera_alt, size: 24, color: Colors.white),
                label: const Text(
                  "Scatta Foto Scaffale",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16),
                  minimumSize: const Size(220, 50),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Visualizzazione dell'immagine con bordo
            _image != null
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                    child: Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Center(
                    child: Text(
                      "Nessuna immagine scattata",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),

            const SizedBox(height: 20),

            // Indicatore di caricamento
            if (_isProcessing) const CircularProgressIndicator(),

            const SizedBox(height: 20),

            // Area con scorrimento per i risultati
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Risultati Lettura:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SelectableText(
                      _risultatiLettura.isEmpty
                          ? "Nessun testo riconosciuto."
                          : _risultatiLettura,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Text("Esito Verifica:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SelectableText(
                      _esitoVerifica.isEmpty
                          ? "Nessun esito di verifica disponibile."
                          : _esitoVerifica,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
