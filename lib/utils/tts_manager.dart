/*
import 'package:flutter_tts/flutter_tts.dart';

class TtsManager {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTTSActive = true;

  // Imposta lo stato del TTS (attivo/disattivo)
  void setTTSActive(bool isActive) {
    _isTTSActive = isActive;
  }

  // Pronuncia un testo
  Future<void> speak(String text) async {
    if (_isTTSActive && text.isNotEmpty) {
      await _flutterTts.setLanguage("it-IT");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(text);
    }
  }

  // Ferma la riproduzione
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
*/