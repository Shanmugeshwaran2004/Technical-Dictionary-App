import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'word_model.dart';

class WordListPage extends StatelessWidget {
  final String domain;
  const WordListPage({super.key, required this.domain});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$domain Words")),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<DictionaryWord>('dictionaryBox').listenable(),
        builder: (context, Box<DictionaryWord> box, _) {
          // Filter by domain and Sort A-Z
          List<DictionaryWord> words = box.values
              .where((word) => word.domainName == domain)
              .toList();
          words.sort((a, b) => a.englishWord.compareTo(b.englishWord));

          if (words.isEmpty) return const Center(child: Text("No words yet."));

          return ListView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(words[index].englishWord),
                onTap: () => _showWordDetail(context, words[index]),
              );
            },
          );
        },
      ),
    );
  }

  // This is the "Small Page" (Modal Bottom Sheet) you requested
  void _showWordDetail(BuildContext context, DictionaryWord word) {
    final FlutterTts tts = FlutterTts();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Need a internet connection for Display the image"))
                  );
                },
                child: Image.network(word.imageUrl, height: 200, width: double.infinity,
                    errorBuilder: (c, e, s) => const Icon(Icons.image, size: 100)),
              ),

              const SizedBox(height: 20),

              // English Section
              Row(
                children: [
                  Text(word.englishWord, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.volume_up), onPressed: () async {
                    await tts.setLanguage("en-US");
                    await tts.speak(word.englishWord);
                  }),
                ],
              ),
              Text("Definition: ${word.englishDef}"),
              Text("Example: ${word.englishExample}"),

              const Divider(),

              // Tamil Section
              Row(
                children: [
                  Text(word.tamilWord, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.volume_up), onPressed: () async {
                    await tts.setLanguage("ta-IN");
                    await tts.speak(word.tamilWord);
                  }),
                ],
              ),
              Text("விளக்கம்: ${word.tamilDef}"),
              Text("உதாரணம்: ${word.tamilExample}"),
            ],
          ),
        ),
      ),
    );
  }
}