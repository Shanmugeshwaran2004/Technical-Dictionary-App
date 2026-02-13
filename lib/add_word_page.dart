import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'word_model.dart';

class AddWordPage extends StatefulWidget {
  const AddWordPage({super.key});

  @override
  State<AddWordPage> createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to grab text from fields
  final TextEditingController _engController = TextEditingController();
  final TextEditingController _tamController = TextEditingController();
  final TextEditingController _engDefController = TextEditingController();
  final TextEditingController _tamDefController = TextEditingController();
  final TextEditingController _engExController = TextEditingController();
  final TextEditingController _tamExController = TextEditingController();
  final TextEditingController _imgController = TextEditingController();

  String _selectedDomain = "AI";
  final List<String> _domains = ["AI", "ML", "DL", "CN", "CV", "DBMS", "OS", "Python", "Java", "NLP", "DS"];

  void _saveWord() {
    final box = Hive.box<DictionaryWord>('dictionaryBox');

    final newWord = DictionaryWord(
      englishWord: _engController.text,
      tamilWord: _tamController.text,
      englishDef: _engDefController.text,
      tamilDef: _tamDefController.text,
      englishExample: _engExController.text,
      tamilExample: _tamExController.text,
      imageUrl: _imgController.text,
      domainName: _selectedDomain,
    );

    box.add(newWord); // Saves to local storage
    Navigator.pop(context); // Go back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Technical Word")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButton<String>(
              value: _selectedDomain,
              items: _domains.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) => setState(() => _selectedDomain = val!),
            ),
            TextField(controller: _engController, decoration: const InputDecoration(labelText: "English Word")),
            TextField(controller: _tamController, decoration: const InputDecoration(labelText: "Tamil Word")),
            TextField(controller: _engDefController, decoration: const InputDecoration(labelText: "English Definition")),
            TextField(controller: _tamDefController, decoration: const InputDecoration(labelText: "Tamil Definition")),
            TextField(controller: _imgController, decoration: const InputDecoration(labelText: "Image URL")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveWord, child: const Text("Save to Dictionary")),
          ],
        ),
      ),
    );
  }
}