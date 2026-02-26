import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'word_model.dart';
import 'dart:math';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final TextEditingController _countController = TextEditingController(text: "5");
  String _selectedDomain = "AI";
  bool _quizStarted = false;

  List<DictionaryWord> _quizWords = [];
  int _currentIndex = 0;
  int _score = 0;
  List<String> _options = [];
  String? _selectedOption;
  bool _isAnswered = false;

  final List<String> _domains = ["AI", "ML", "DL", "CN", "CV", "DBMS", "OS", "Python", "Java", "NLP", "DS"];

  void _startQuiz() {
    final box = Hive.box<DictionaryWord>('dictionaryBox');
    int requestedCount = int.tryParse(_countController.text) ?? 5;

    List<DictionaryWord> domainWords = box.values
        .where((w) => w.domainName == _selectedDomain)
        .toList();

    if (domainWords.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Add more words to this domain first!")));
      return;
    }

    domainWords.shuffle();
    _quizWords = domainWords.take(requestedCount).toList();

    setState(() {
      _quizStarted = true;
      _currentIndex = 0;
      _score = 0;
      _isAnswered = false;
      _generateOptions();
    });
  }

  void _generateOptions() {
    final box = Hive.box<DictionaryWord>('dictionaryBox');
    String correct = _quizWords[_currentIndex].englishWord;

    List<String> others = box.values
        .where((w) => w.domainName == _selectedDomain && w.englishWord != correct)
        .map((w) => w.englishWord).toList();

    others.shuffle();
    _options = others.take(3).toList();
    _options.add(correct);
    _options.shuffle();
  }

  void _handleAnswer(String option) {
    if (_isAnswered) return;
    setState(() {
      _selectedOption = option;
      _isAnswered = true;
      if (option == _quizWords[_currentIndex].englishWord) _score++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Technical Quiz")),
      body: !_quizStarted ? _buildSetup() : _buildQuizBody(),
    );
  }

  Widget _buildSetup() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("Select Domain and Number of Questions"),
          DropdownButton<String>(
            value: _selectedDomain,
            isExpanded: true,
            items: _domains.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (v) => setState(() => _selectedDomain = v!),
          ),
          TextField(
            controller: _countController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter number of questions"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _startQuiz, child: const Text("START")),
        ],
      ),
    );
  }

  Widget _buildQuizBody() {
    final current = _quizWords[_currentIndex];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text("Question ${_currentIndex + 1}/${_quizWords.length} | Score: $_score"),
          const SizedBox(height: 20),
          Text(current.englishDef, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ..._options.map((opt) {
            Color btnColor = Colors.blueGrey;
            Widget? icon;

            if (_isAnswered) {
              if (opt == current.englishWord) {
                btnColor = Colors.green;
                icon = const Icon(Icons.check_circle, color: Colors.white); // Right Tick
              } else if (opt == _selectedOption) {
                btnColor = Colors.red;
                icon = const Icon(Icons.cancel, color: Colors.white); // Wrong X
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: btnColor, minimumSize: const Size(double.infinity, 50)),
                onPressed: () => _handleAnswer(opt),
                icon: icon ?? const SizedBox(),
                label: Text(opt, style: const TextStyle(color: Colors.white)),
              ),
            );
          }),
          if (_isAnswered)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentIndex < _quizWords.length - 1) {
                    setState(() { _currentIndex++; _isAnswered = false; _selectedOption = null; _generateOptions(); });
                  } else {
                    _showFinalResult();
                  }
                },
                child: Text(_currentIndex < _quizWords.length - 1 ? "Next Question" : "View Result"),
              ),
            ),
        ],
      ),
    );
  }

  void _showFinalResult() {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("Quiz Complete!"),
      content: Text("Final Score: $_score out of ${_quizWords.length}"),
      actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text("Return Home"))],
    ));
  }
}