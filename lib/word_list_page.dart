import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'word_model.dart';

class WordListPage extends StatefulWidget {
  final String domain;
  const WordListPage({super.key, required this.domain});

  @override
  State<WordListPage> createState() => _WordListPageState();
}

class _WordListPageState extends State<WordListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.domain.toUpperCase()} Dictionary"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<DictionaryWord>('dictionaryBox').listenable(),
        builder: (context, Box<DictionaryWord> box, _) {
          // FILTER: Case-insensitive matching for Domain and Search
          List<DictionaryWord> filteredWords = box.values
              .where((word) => word.domainName.toLowerCase() == widget.domain.toLowerCase())
              .where((word) => word.englishWord.toLowerCase().contains(_searchQuery))
              .toList();

          filteredWords.sort((a, b) => a.englishWord.compareTo(b.englishWord));

          if (filteredWords.isEmpty) {
            return Center(child: Text("No words found for ${widget.domain}. Click Refresh on Home."));
          }

          return ListView.builder(
            itemCount: filteredWords.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(filteredWords[index].englishWord, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(filteredWords[index].tamilWord),
                onTap: () => _showWordDetail(context, filteredWords[index]),
              );
            },
          );
        },
      ),
    );
  }

  // Detail Modal remains the same as previous step
  void _showWordDetail(BuildContext context, DictionaryWord word) {
    final FlutterTts tts = FlutterTts();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(word.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(height: 200, color: Colors.grey[300], child: const Icon(Icons.image, size: 100))),
              const SizedBox(height: 20),
              _buildLanguageRow(word.englishWord, "en-US", tts, Colors.blue),
              Text("Definition: ${word.englishDef}"),
              Text("Example: ${word.englishExample}"),
              const Divider(height: 40),
              _buildLanguageRow(word.tamilWord, "ta-IN", tts, Colors.green),
              Text("விளக்கம்: ${word.tamilDef}"),
              Text("உதாரணம்: ${word.tamilExample}"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageRow(String text, String langCode, FlutterTts tts, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(text, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color))),
        IconButton(icon: Icon(Icons.volume_up, color: color), onPressed: () async {
          await tts.setLanguage(langCode);
          await tts.speak(text);
        }),
      ],
    );
  }
}