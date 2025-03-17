import 'package:flutter/material.dart';
import '../utils/csv_manager.dart';

class NuovaCatalogazionePage extends StatefulWidget {
  const NuovaCatalogazionePage({super.key});

  @override
  _NuovaCatalogazionePageState createState() => _NuovaCatalogazionePageState();
}

class _NuovaCatalogazionePageState extends State<NuovaCatalogazionePage> {
  final TextEditingController _titoloController = TextEditingController();
  final TextEditingController _autoreController = TextEditingController();
  final TextEditingController _dataPubblicazioneController =
      TextEditingController();
  final TextEditingController _genereController = TextEditingController();
  final TextEditingController _collocazioneController = TextEditingController();

  void _salvaLibro() async {
    String titolo = _titoloController.text;
    String autore = _autoreController.text;
    String dataPubblicazione = _dataPubblicazioneController.text;
    String genere = _genereController.text;
    String collocazione = _collocazioneController.text;
    String dataInserimento = DateTime.now().toIso8601String();

    if (titolo.isEmpty ||
        autore.isEmpty ||
        dataPubblicazione.isEmpty ||
        genere.isEmpty ||
        collocazione.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tutti i campi sono obbligatori!')),
      );
      return;
    }

    List<String> nuovaRiga = [
      titolo,
      autore,
      dataPubblicazione,
      genere,
      collocazione,
      dataInserimento
    ];
    await aggiungiAlCSV(nuovaRiga);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Libro aggiunto con successo!')),
    );

    _titoloController.clear();
    _autoreController.clear();
    _dataPubblicazioneController.clear();
    _genereController.clear();
    _collocazioneController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuova Catalogazione')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _titoloController,
                decoration: const InputDecoration(labelText: 'Titolo')),
            TextField(
                controller: _autoreController,
                decoration: const InputDecoration(labelText: 'Autore')),
            TextField(
                controller: _dataPubblicazioneController,
                decoration:
                    const InputDecoration(labelText: 'Data di pubblicazione')),
            TextField(
                controller: _genereController,
                decoration: const InputDecoration(labelText: 'Genere')),
            TextField(
                controller: _collocazioneController,
                decoration: const InputDecoration(labelText: 'Collocazione')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvaLibro,
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }
}
