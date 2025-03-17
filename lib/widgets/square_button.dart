import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

bool isTTSActive = true;

class SquareButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;
  final bool isTTSActive;
  final FlutterTts flutterTts = FlutterTts(); // Istanza di FlutterTts

  SquareButton({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
    required this.isTTSActive,
  });

  Future<void> _speak() async {
    if(!isTTSActive) return;
    await flutterTts.speak(text); // Fa leggere il testo del pulsante
    await flutterTts.setLanguage("it-IT");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _speak(), // Quando l'utente tocca il pulsante, viene letto il testo
      onTap: onPressed, // Esegue l'azione associata al pulsante
      onLongPress: _speak, // Anche una pressione lunga fa partire l'audio
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          padding: const EdgeInsets.all(16.0),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
