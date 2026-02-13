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
  String _selectedDomain = "AI";
  int _questionCount = 5;
  bool _quizStarted = false;

  List<DictionaryWord> _quizWords = [];
  int _currentIndex = 0;
  int _score = 0;
  List<String> _currentOptions = [];

  final List<String> _domains = ["AI", "ML", "DL", "CN", "CV", "DBMS", "OS", "Python", "Java", "NLP", "DS"];

  void _startQuiz() {
    final box = Hive.box<DictionaryWord>('dictionaryBox');
    List<DictionaryWord> allDomainWords = box.values
        .where((w) => w.domainName == _selectedDomain)
        .toList();

    if (allDomainWords.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least 4 words to this domain to start a quiz!")),
      );
      return;
    }

    allDomainWords.shuffle();
    _quizWords = allDomainWords.take(_questionCount).toList();

    setState(() {
      _quizStarted = true;
      _currentIndex = 0;
      _score = 0;
      _generateOptions();
    });
  }

  void _generateOptions() {
    final box = Hive.box<DictionaryWord>('dictionaryBox');
    String correctAnswer = _quizWords[_currentIndex].englishWord;

    List<String> otherWords = box.values
        .where((w) => w.domainName == _selectedDomain && w.englishWord != correctAnswer)
        .map((w) => w.englishWord)
        .toList();

    otherWords.shuffle();

    _currentOptions = otherWords.take(3).toList();
    _currentOptions.add(correctAnswer);
    _currentOptions.shuffle();
  }

  void _checkAnswer(String selected) {
    if (selected == _quizWords[_currentIndex].englishWord) {
      _score++;
    }

    if (_currentIndex < _quizWords.length - 1) {
      setState(() {
        _currentIndex++;
        _generateOptions();
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Completed!"),
        content: Text("Your Score: $_score / ${_quizWords.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _quizStarted = false);
            },
            child: const Text("Finish"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Technical Quiz")),
      body: !_quizStarted ? _buildSetup() : _buildQuiz(),
    );
  }

  Widget _buildSetup() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Select Domain:", style: TextStyle(fontSize: 18)),
          DropdownButton<String>(
            value: _selectedDomain,
            isExpanded: true,
            items: _domains.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (val) => setState(() => _selectedDomain = val!),
          ),
          const SizedBox(height: 20),
          const Text("Number of Questions:", style: TextStyle(fontSize: 18)),
          Slider(
            value: _questionCount.toDouble(),
            min: 1, max: 10, divisions: 9,
            label: _questionCount.toString(),
            onChanged: (val) => setState(() => _questionCount = val.toInt()),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _startQuiz,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: const Text("START QUIZ"),
          )
        ],
      ),
    );
  }

  Widget _buildQuiz() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Question ${_currentIndex + 1} of ${_quizWords.length}", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Text(
            "What is the definition of: \n'${_quizWords[_currentIndex].englishDef}'?",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          ..._currentOptions.map((option) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: () => _checkAnswer(option),
              child: Text(option),
            ),
          )),
        ],
      ),
    );
  }
}