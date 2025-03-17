//import 'package:bibliotek/pages/riconoscimento_oggetti_page.dart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
//import 'qr_scanner.dart'; // Importa il file QRScannerPage
import '../utils/csv_manager.dart'; // Assicurati di importare il csv_manager
import 'package:flutter_tts/flutter_tts.dart';
//import 'navigazione_qr_page.dart'; //ho aggiunto questo import
//import 'riconoscimento_libro.dart';
import 'navigazione_qr_deposita_page.dart';

class DepositaLibroPage extends StatefulWidget {
  const DepositaLibroPage({super.key});

  @override
  _DepositaLibroPageState createState() => _DepositaLibroPageState();
}

class _DepositaLibroPageState extends State<DepositaLibroPage> {
  final TextEditingController _searchController = TextEditingController();
  List<List<dynamic>> _libri = [];
  List<List<dynamic>> _risultatiRicerca = [];
  bool _csvCaricato = false;
  bool _ricercaEffettuata = false;
  bool _isCardSelected = false; // Nuovo stato per la selezione della card
  List<dynamic>? _selectedBook; // Libro selezionato
  String? _selectedTitle; // Titolo selezionato
  String? _selectedAuthor; // Autore selezionato
  //String? _selectedCollocazione
  String? _selectedCollocazione; //Collocazione selezionata

  FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  void _caricaDati() async {
    List<List<dynamic>> datiCSV = getCSVData();
    if (datiCSV.isEmpty) {
      setState(() {
        _csvCaricato = false;
      });
      await _flutterTts.speak(
          "Attenzione. Nessun file CSV caricato. Vai su carica CSV e seleziona un file.");

      return;
    }
    setState(() {
      _libri = datiCSV.skip(1).map((riga) {
        if (riga.length < 7) {
          return List.generate(1, (i) => i < riga.length ? riga[i] : '-');
        }
        return riga;
      }).toList();
      _risultatiRicerca = List.from(_libri);
      _csvCaricato = true;
    });
  }

  void _filtraLibri() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _ricercaEffettuata = true;
      _risultatiRicerca = _libri.where((libro) {
        return libro
            .any((campo) => campo.toString().toLowerCase().contains(query));
      }).toList();
    });
  }

  void _selectCard(List<dynamic> libro) {
    setState(() {
      _isCardSelected = true;
      _selectedBook = libro; // Set the selected book
      _selectedTitle = libro[0].toString(); // Primo campo: Titolo
      _selectedAuthor = libro[1].toString(); // Secondo campo: Autore
      //selezionare anche la collocazione
      _selectedCollocazione = libro[4].toString();
    });
  }

  void _deselectCard() {
    setState(() {
      _isCardSelected = false;
      _selectedBook = null;
      _selectedTitle = null;
      _selectedAuthor = null;
      _selectedCollocazione = null;
    });
  }

  void _speak(String message) async {
    await _flutterTts.speak(message);
  }

  void _onQRCodeScanned(String qrCode) async {
    // Estrai il numero del corridoio dalla "Collocazione" del libro selezionato
    String corridoio = _selectedBook![4].toString().split(
        ' ')[0]; // Prendi solo il numero del corridoio (prima della lettera)

    // Verifica se il QR Code corrisponde al numero del corridoio
    if (qrCode == corridoio) {
      await _flutterTts.speak("Corridorio corretto, prosegui più avanti.");
    } else {
      await _flutterTts.speak("QR code non corrispondente. Riprova.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deposita Libro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Deposita un libro',
                      prefixIcon: const Icon(LucideIcons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _filtraLibri,
                  child: const Text('Cerca'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (!_csvCaricato)
              const Text(
                '⚠️ Nessun CSV caricato! Vai su "Carica CSV" e seleziona un file.',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),

            if (_csvCaricato && !_ricercaEffettuata)
              Expanded(child: _buildLibriList(_libri)),

            if (_ricercaEffettuata)
              Expanded(child: _buildLibriList(_risultatiRicerca)),

            // Mostra il titolo e l'autore selezionato insieme ai pulsanti
            if (_isCardSelected)
              Column(
                children: [
                  Text(
                    'Selezionato: $_selectedTitle\nDi: $_selectedAuthor\nCollocazione: $_selectedCollocazione',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                      height: 20), // Distanza tra il testo e i pulsanti
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_selectedBook != null) {
                              String titleLibro = _selectedBook![0].toString();
                              String collocazioneLibro = _selectedBook![4]
                                  .toString(); // Prendi la collocazione dallo CSV
                              _speak("Dirigiti verso gli scaffali");
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NavigazioneQRDepositaPage(
                                            collocazioneLibro:
                                                collocazioneLibro,
                                            titleLibro: titleLibro)),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('VAI ALLO SCAFFALE'),
                        ),
                      ),
                      const SizedBox(width: 10), // Spazio tra i pulsanti
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            _deselectCard();
                            await _flutterTts.speak("Annulla");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .red, // Colore di sfondo rosso per ANNULLA
                          ),
                          child: const Text('ANNULLA'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibriList(List<List<dynamic>> libri) {
    return ListView.builder(  //utilizzando ListView invece del build miglioro le presyazioni
      itemCount: libri.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () =>
              _selectCard(libri[index]), // Cliccando sulla card si seleziona
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(libri[index].length, (i) {
                  return Row(
                    children: [
                      Icon(_getIcon(i), size: 20, color: Colors.blueGrey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_getColumnTitle(i)}: ${libri[index][i]}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return LucideIcons.book;
      case 1:
        return LucideIcons.user;
      case 2:
        return LucideIcons.calendar;
      case 3:
        return LucideIcons.tag;
      case 4:
        return LucideIcons.mapPin;
      case 5:
        return LucideIcons.clock;
      case 6:
        return LucideIcons.scanLine;
      default:
        return LucideIcons.helpCircle;
    }
  }

  String _getColumnTitle(int index) {
    switch (index) {
      case 0:
        return 'Titolo';
      case 1:
        return 'Autore';
      case 2:
        return 'Data Pubblicazione';
      case 3:
        return 'Genere';
      case 4:
        return 'Collocazione';
      case 5:
        return 'Data Inserimento';
      case 6:
        return 'Codice Barre';
      default:
        return '';
    }
  }
}
