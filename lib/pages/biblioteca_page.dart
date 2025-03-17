import 'package:bibliotek/pages/riconoscimento_oggetti_page.dart';
import 'package:bibliotek/pages/call.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/csv_manager.dart';
import '../widgets/square_button.dart';
import 'ricerca_libro_page.dart';
import 'leggi_page.dart';
import 'package:bibliotek/pages/deposita_libro_page.dart';
import 'package:bibliotek/pages/inventario_page.dart';
import 'package:bibliotek/pages/nuova_catalogazione.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart'
    as stt; // Importa correttamente per la versione 7.0.0
//import 'package:speech_to_text/speech_recognition_error.dart';

class BibliotecaPage extends StatefulWidget {
  const BibliotecaPage({super.key});

  @override
  State<BibliotecaPage> createState() => _BibliotecaPageState();
}

class _BibliotecaPageState extends State<BibliotecaPage> {
  bool isTTSActive = true;
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText _speechToText; // Variabile per il riconoscimento vocale
  bool _isListening = false; // Stato per il riconoscimento vocale

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  // Funzione per avviare la registrazione vocale
  Future<void> _startListening() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => print('Riconoscimento stato: $status'),
      onError: (errorNotification) =>
          print('Errore riconoscimento: $errorNotification'),
    );

    if (available) {
      setState(() {
        _isListening = true;
      });
      _speechToText.listen(
        listenFor: Duration(seconds: 60),
        pauseFor: Duration(seconds: 3),
        //partialResults: true, //perchè viene deprecata? non più in uso
        onResult: resultListener,
      );
    } else {
      await _speakText('Errore nel riconoscimento vocale');
    }
  }

  // Funzione per fermare l'ascolto
  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    _speechToText.stop();
  }

  // Funzione che gestisce i risultati del riconoscimento vocale
  void resultListener(SpeechRecognitionResult result) async {
    if (!_isListening) return;
    String command = result.recognizedWords.toLowerCase();

    if (command.isNotEmpty) {
      _stopListening(); // Ferma subito l'ascolto dopo aver rilevato un comando valido
      await _speakText('Hai detto: $command');

      // Mappatura dei comandi vocali alle rispettive azioni
      if (command.contains('ricerca libro')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RicercaLibroPage()),
        );
      } else if (command.contains('deposita libro')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DepositaLibroPage()),
        );
      } else if (command.contains('inventario')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InventarioPage()),
        );
      } else if (command.contains('leggi')) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LeggiPage(isTTSActive: isTTSActive)),
        );
      } else if (command.contains('nuova catalogazione')) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const NuovaCatalogazionePage()),
        );
      } else if (command.contains('call')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CallPage()),
        );
      } else if (command.contains('riconosci oggetti')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RiconoscimentoOggettiPage(isTTSActive: isTTSActive),
          ),
        );
      } else {
        await _speakText('Comando non riconosciuto. Prova di nuovo.');
        _startListening(); // Se il comando non è valido, riavvia l'ascolto
      }
    }
  }

  // Funzione helper per la navigazione
  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  // Funzione per parlare con il TTS
  Future<void> _speakText(String text) async {
    if (isTTSActive) {
      await flutterTts.setLanguage("it-IT");
      await flutterTts.speak(text);
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _speakText("Logout");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BiblioteK',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings,
                color: Colors.white), // Icona delle impostazioni
            onPressed: () {
              // Per ora non fa nulla
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  SquareButton(
                    text: 'Ricerca Libro',
                    color: Colors.blue,
                    isTTSActive: isTTSActive,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RicercaLibroPage()),
                      );
                    },
                  ),
                  SquareButton(
                    text: 'Deposita Libro',
                    color: Colors.green,
                    isTTSActive: isTTSActive,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DepositaLibroPage()),
                      );
                    },
                  ),
                  SquareButton(
                    text: 'Inventario',
                    color: Colors.orange,
                    isTTSActive: isTTSActive,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const InventarioPage()),
                      );
                    },
                  ),
                  SquareButton(
                    text: 'Leggi',
                    color: Colors.red,
                    isTTSActive: isTTSActive,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LeggiPage(isTTSActive: isTTSActive)),
                      );
                    },
                  ),
                  SquareButton(
                    text: 'Nuova Catalogazione',
                    color: Colors.purple,
                    isTTSActive: isTTSActive,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const NuovaCatalogazionePage()),
                      );
                    },
                  ),
                  SquareButton(
                    text: 'Call',
                    color: Colors.teal,
                    isTTSActive: isTTSActive,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CallPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.volume_up,
                    color: isTTSActive ? Colors.white : Colors.yellow,
                    shadows: isTTSActive
                        ? [const Shadow(color: Colors.white, blurRadius: 10)]
                        : [],
                  ),
                  onPressed: _toggleTTS,
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: () {
                    _speakText("Modalità riconosci oggetti");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RiconoscimentoOggettiPage(isTTSActive: isTTSActive),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.mic, color: Colors.white, size: 40),
                  onPressed: () {
                    if (_isListening) {
                      _stopListening();
                    } else {
                      _startListening();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.description, color: Colors.white),
                  onPressed: () {
                    _speakText("Carica il CSV");
                    caricaCSV();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => _logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTTS() async {
    setState(() {
      isTTSActive = !isTTSActive;
    });
    await _speakText(isTTSActive ? "Audio attivo" : "Audio disattivato");
  }
}
