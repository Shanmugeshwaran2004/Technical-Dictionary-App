import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'word_model.dart';
import 'word_list_page.dart';
import 'quiz_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(DictionaryWordAdapter());
  }
  await Hive.openBox<DictionaryWord>('dictionaryBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const DomainListPage(),
    );
  }
}

class DomainListPage extends StatefulWidget {
  const DomainListPage({super.key});

  @override
  State<DomainListPage> createState() => _DomainListPageState();
}

class _DomainListPageState extends State<DomainListPage> {
  bool _isLoading = false;
  // Note: "java" is lowercase here to match your CSV perfectly
  final List<String> domains = ["AI", "ML", "DL", "CN", "CV", "DBMS", "OS", "Python", "java", "NLP", "DS"];

  Future<void> _clearAndReimport() async {
    final box = Hive.box<DictionaryWord>('dictionaryBox');
    setState(() => _isLoading = true);
    await box.clear();

    try {
      final rawData = await rootBundle.loadString("assets/data.csv");
      List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);

      for (var i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        if (row.length >= 8) {
          final newWord = DictionaryWord(
            englishWord: row[0].toString().trim(),
            tamilWord: row[1].toString().trim(),
            englishDef: row[2].toString().trim(),
            englishExample: row[3].toString().trim(), // Index 3 is English Example
            tamilDef: row[4].toString().trim(),     // Index 4 is Tamil Definition
            tamilExample: row[5].toString().trim(),
            imageUrl: row[6].toString().trim(),
            domainName: row[7].toString().trim(),
          );
          await box.add(newWord);
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Imported ${box.length} words successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<DictionaryWord>('dictionaryBox');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Technical Dictionary'),
        actions: [
          Center(child: Text("Total: ${box.length} ", style: const TextStyle(fontWeight: FontWeight.bold))),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _clearAndReimport,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: domains.length,
        itemBuilder: (context, index) {
          // Displaying "Java" nicely while matching "java" internally
          String displayName = domains[index] == "java" ? "Java" : domains[index];
          return ListTile(
            leading: const Icon(Icons.folder_open, color: Colors.blue),
            title: Text(displayName),
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => WordListPage(domain: domains[index])
            )),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuizPage())),
        label: const Text("Take Quiz"),
        icon: const Icon(Icons.quiz),
      ),
    );
  }
}