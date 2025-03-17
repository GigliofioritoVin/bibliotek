import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CallPage extends StatelessWidget {
  final String teamMeetingLink =
      "https://teams.microsoft.com/l/meetup-join/19%3ameeting_Njc5NDBjMjgtYjRhYi00YjNiLTgyYzgtZTdhYjE1ZDQ1OGUz%40thread.v2/0?context=%7b%22Tid%22%3a%228f547aef-14d7-49ca-a4d4-51a6c5cb92c1%22%2c%22Oid%22%3a%22f6d207a9-baab-444f-9f65-0ef08e528b8e%22%7d";

  const CallPage({super.key}); // Link di prova della riunione Teams

  // Funzione per avviare la videochiamata Teams
  Future<void> _startVideoCall() async {
    if (await canLaunch(teamMeetingLink)) {
      await launch(teamMeetingLink);
    } else {
      throw 'Impossibile aprire il link della videochiamata.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Videochiamata Teams')),
      body: Center(
        child: ElevatedButton(
          onPressed: _startVideoCall, // Avvia la videochiamata
          child: const Text('Avvia Videochiamata'),
        ),
      ),
    );
  }
}
