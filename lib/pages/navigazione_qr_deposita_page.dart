import 'package:bibliotek/pages/deposita_libro_page.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_tts/flutter_tts.dart';
//import 'riconoscimento_libro.dart';

class NavigazioneQRDepositaPage extends StatefulWidget {
  final String collocazioneLibro; // Riceve la collocazione del libro
  final String titleLibro;

  const NavigazioneQRDepositaPage(
      {Key? key, required this.collocazioneLibro, required this.titleLibro})
      : super(key: key);

  @override
  _NavigazioneQRDepositaPageState createState() =>
      _NavigazioneQRDepositaPageState();
}

class _NavigazioneQRDepositaPageState extends State<NavigazioneQRDepositaPage> {
  MobileScannerController controller = MobileScannerController();
  FlutterTts flutterTts = FlutterTts();
  bool _isSpeaking = false; // Variabile per controllare se il TTS sta parlando

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isSpeaking) return; // Blocca la lettura se il TTS è attivo

    for (final barcode in capture.barcodes) {
      String qrCode = barcode.rawValue ?? "";
      print("QR Code rilevato: $qrCode");

      String? letteraQR = _estraiLettera(qrCode);
      String? letteraCollocazione = _estraiLettera(widget.collocazioneLibro);
      String? numeroScaffale = _estraiNumero(widget.collocazioneLibro);

      if (letteraQR == null ||
          letteraCollocazione == null ||
          numeroScaffale == null) {
        _parla("Errore nella lettura del codice. Riprova.");
        return;
      }

      if (letteraQR == letteraCollocazione) {
        String messaggio =
            "Scaffale corretto, gira a destra. Vai allo scaffale $numeroScaffale per posare il libro";
        _mostraAvviso(context, "Scaffale corretto!",
            "Vai allo scaffale $numeroScaffale per posare il libro ");
        _parla(messaggio);
        controller.stop(); // Ferma la scansione
      } else if (letteraQR.compareTo(letteraCollocazione) < 0) {
        _parla("Prosegui al prossimo scaffale.");
      } else {
        _parla("Hai superato lo scaffale, torna indietro.");
      }
    }
  }

  // Funzione per gestire il TTS e bloccare la scansione durante la lettura
  void _parla(String messaggio) async {
    _isSpeaking = true; // Blocca la lettura dei QR code
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(messaggio);
    _isSpeaking = false; // Riattiva la lettura dopo aver parlato
  }

  // Funzione per estrarre la lettera dalla collocazione
  String? _estraiLettera(String codice) {
    RegExp regex = RegExp(r'[A-Z]'); // Trova la prima lettera maiuscola
    Match? match = regex.firstMatch(codice);
    return match?.group(0);
  }

  // Funzione per estrarre il numero dello scaffale
  String? _estraiNumero(String codice) {
    RegExp regex = RegExp(r'\d+'); // Trova il numero
    Match? match = regex.firstMatch(codice);
    return match?.group(0);
  }

  // Funzione per mostrare un avviso a schermo
  void _mostraAvviso(BuildContext context, String titolo, String messaggio) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titolo),
          content: Text(messaggio),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DepositaLibroPage(),
                  ),
                );
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
      appBar: AppBar(title: const Text("Navigazione Biblioteca")),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: controller,
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  controller.start(); // Riavvia la scansione
                },
                child: const Text("Riprova Scansione"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
