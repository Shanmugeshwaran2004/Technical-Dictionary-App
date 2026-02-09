import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'word_model.dart'; // This imports your DictionaryWord class

void main() async {
  // 1. Ensure Flutter is ready for async code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Hive and Register the Adapter
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(DictionaryWordAdapter());
  }

  // 3. Open the storage box
  await Hive.openBox<DictionaryWord>('dictionaryBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Technical Dictionary',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DomainListPage(),
    );
  }
}

class DomainListPage extends StatelessWidget {
  const DomainListPage({super.key});

  // Your requested domains
  final List<String> domains = const [
    "AI", "ML", "DL", "CN", "CV", "DBMS", "OS", "Python", "Java", "NLP", "DS"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Technical Dictionary'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: domains.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.book),
              title: Text(
                domains[index],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Next step: Navigate to a word list filtered by this domain
                print("Selected domain: ${domains[index]}");
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Next step: Navigate to Quiz page
        },
        label: const Text('Take Quiz'),
        icon: const Icon(Icons.quiz),
      ),
    );
  }
}