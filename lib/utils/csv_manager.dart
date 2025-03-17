import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

List<List<dynamic>> _csvData =
    []; // Questa è la lista globale con i dati del CSV

// Funzione per caricare il CSV
Future<void> caricaCSV() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  if (result != null) {
    File file = File(result.files.single.path!);
    String csvString = await file.readAsString();
    List<List<String>> csvTable = const CsvToListConverter(fieldDelimiter: ';')
        .convert(csvString)
        .map((row) => row.map((cell) => cell.toString()).toList())
        .toList();

    _csvData = csvTable;
    print("CSV caricato: $_csvData");
  }
}

// Funzione per ottenere i dati
List<List<dynamic>> getCSVData() {
  return _csvData;
}

// Funzione per aggiungere una riga al CSV
Future<void> aggiungiAlCSV(List<String> nuovaRiga) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final File file = File(
        '${directory.path}/csvBibliotek.csv'); //ho modificato databade.csv in questo

    if (await file.exists()) {
      String fileContent = await file.readAsString();
      List<List<dynamic>> csvData =
          const CsvToListConverter().convert(fileContent);
      csvData.add(nuovaRiga);
      String csvString = const ListToCsvConverter().convert(csvData);
      await file.writeAsString(csvString);
    } else {
      String csvString = const ListToCsvConverter().convert([nuovaRiga]);
      await file.writeAsString(csvString);
    }

    print("Libro aggiunto al CSV: $nuovaRiga");
  } catch (e) {
    print("Errore nell'aggiunta al CSV: $e");
  }
}
