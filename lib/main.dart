import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Import your other files
import 'word_model.dart';
import 'word_list_page.dart';
import 'add_word_page.dart';
import 'quiz_page.dart';

void main() async {
  // 1. Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Hive for local storage
  await Hive.initFlutter();

  // 3. Register the generated TypeAdapter for DictionaryWord
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(DictionaryWordAdapter());
  }

  // 4. Open the database "box"
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const DomainListPage(),
    );
  }
}

class DomainListPage extends StatelessWidget {
  const DomainListPage({super.key});

  // Your specified domains for CSE and AIML
  final List<String> domains = const [
    "AI", "ML", "DL", "CN", "CV", "DBMS", "OS", "Python", "Java", "NLP", "DS"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSE & AIML Dictionary'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          // Button to go to the "Add Word" page to enter data
          IconButton(
            tooltip: "Add New Word",
            icon: const Icon(Icons.add_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddWordPage()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: domains.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(domains[index][0]), // Shows first letter
              ),
              title: Text(
                domains[index],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: const Text("Tap to view words"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to Word List page filtered by this domain
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WordListPage(domain: domains[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
      // Floating Action Button to start the Quiz
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuizPage()),
          );
        },
        label: const Text('Start Quiz'),
        icon: const Icon(Icons.psychology),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}