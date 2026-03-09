import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'word_model.dart';
import 'dart:math';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  // ── Setup state ──────────────────────────────────────────────────────────
  final TextEditingController _countController =
  TextEditingController(text: '10');
  String _selectedDomain = 'AI';
  bool _quizStarted = false;

  // ── Quiz state ───────────────────────────────────────────────────────────
  List<DictionaryWord> _quizWords = [];
  int _currentIndex = 0;
  int _score = 0;
  List<String> _options = [];
  String? _selectedOption;
  bool _isAnswered = false;

  late AnimationController _slideCtrl;
  late Animation<double> _slideAnim;

  final List<String> _domains = [
    'AI', 'ML', 'DL', 'CN', 'CV', 'DBMS', 'OS', 'Python', 'Java', 'NLP', 'DS'
  ];

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic);
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _startQuiz() {
    final box = Hive.box<DictionaryWord>('dictionaryBox');
    final count = int.tryParse(_countController.text) ?? 5;
    final domainWords = box.values
        .where((w) => w.domainName == _selectedDomain)
        .toList()
      ..shuffle();

    if (domainWords.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add at least 4 words to this domain first.'),
          backgroundColor: const Color(0xFFFF453A),
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    _quizWords = domainWords.take(count).toList();
    setState(() {
      _quizStarted = true;
      _currentIndex = 0;
      _score = 0;
      _isAnswered = false;
      _generateOptions();
    });
    _slideCtrl
      ..reset()
      ..forward();
  }

  void _generateOptions() {
    final box = Hive.box<DictionaryWord>('dictionaryBox');
    final correct = _quizWords[_currentIndex].englishWord;
    final others = box.values
        .where((w) =>
    w.domainName == _selectedDomain && w.englishWord != correct)
        .map((w) => w.englishWord)
        .toList()
      ..shuffle();
    _options = [...others.take(3), correct]..shuffle();
  }

  void _handleAnswer(String opt) {
    if (_isAnswered) return;
    setState(() {
      _selectedOption = opt;
      _isAnswered = true;
      if (opt == _quizWords[_currentIndex].englishWord) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _quizWords.length - 1) {
      _slideCtrl.reset();
      setState(() {
        _currentIndex++;
        _isAnswered = false;
        _selectedOption = null;
        _generateOptions();
      });
      _slideCtrl.forward();
    } else {
      _showResult();
    }
  }

  void _showResult() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = (_score / _quizWords.length * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pct >= 70 ? '🏆' : pct >= 40 ? '👍' : '📚',
                style: const TextStyle(fontSize: 52),
              ),
              const SizedBox(height: 16),
              Text(
                'Quiz Complete!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_score / ${_quizWords.length} correct  •  $pct%',
                style: TextStyle(
                  fontSize: 15,
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              // Score bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _score / _quizWords.length,
                  minHeight: 10,
                  backgroundColor:
                  (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    pct >= 70
                        ? const Color(0xFF30D158)
                        : pct >= 40
                        ? const Color(0xFFFF9F0A)
                        : const Color(0xFFFF453A),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A84FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Return Home',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0C0C0E) : const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color:
                (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.7),
              ),
            ),
          ),
        ),
        title: Text(
          'Quiz',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _quizStarted ? _buildQuiz(isDark) : _buildSetup(isDark),
      ),
    );
  }

  // ── Setup Screen ─────────────────────────────────────────────────────────
  Widget _buildSetup(bool isDark) {
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Set up your\nquiz',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
              height: 1.1,
              color: textColor,
            ),
          ),
          const SizedBox(height: 32),

          // Domain selector
          Text('Domain',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor.withOpacity(0.45),
                  letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDomain,
                isExpanded: true,
                dropdownColor: cardBg,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textColor),
                icon: Icon(Icons.expand_more_rounded,
                    color: textColor.withOpacity(0.4)),
                items: _domains
                    .map((d) =>
                    DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDomain = v!),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Question count
          Text('Number of Questions',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor.withOpacity(0.45),
                  letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 15, color: textColor),
              decoration: InputDecoration(
                hintText: '5',
                hintStyle:
                TextStyle(color: textColor.withOpacity(0.3)),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A84FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: _startQuiz,
              child: const Text(
                'Start Quiz',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quiz Screen ──────────────────────────────────────────────────────────
  Widget _buildQuiz(bool isDark) {
    final current = _quizWords[_currentIndex];
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final progress = (_currentIndex + 1) / _quizWords.length;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(_slideAnim),
      child: FadeTransition(
        opacity: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar + score
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor:
                        textColor.withOpacity(0.08),
                        valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF0A84FF)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '${_currentIndex + 1}/${_quizWords.length}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor.withOpacity(0.45),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Score chip
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF30D158).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: Color(0xFF30D158)),
                        const SizedBox(width: 4),
                        Text(
                          '$_score pts',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF30D158),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Question card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A84FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Which term is described below?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      current.englishDef,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Choose the correct answer',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: textColor.withOpacity(0.35),
                ),
              ),

              const SizedBox(height: 12),

              // Options
              Expanded(
                child: ListView.separated(
                  itemCount: _options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final opt = _options[i];
                    final isCorrect = opt == current.englishWord;
                    final isSelected = opt == _selectedOption;

                    Color bg = cardBg;
                    Color border = Colors.transparent;
                    Widget? trailingIcon;

                    if (_isAnswered) {
                      if (isCorrect) {
                        bg = const Color(0xFF30D158).withOpacity(0.12);
                        border = const Color(0xFF30D158);
                        trailingIcon = const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF30D158), size: 20);
                      } else if (isSelected) {
                        bg = const Color(0xFFFF453A).withOpacity(0.10);
                        border = const Color(0xFFFF453A);
                        trailingIcon = const Icon(Icons.cancel_rounded,
                            color: Color(0xFFFF453A), size: 20);
                      }
                    }

                    return GestureDetector(
                      onTap: () => _handleAnswer(opt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: border, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                opt,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ),
                            if (trailingIcon != null) trailingIcon,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Next button
              if (_isAnswered) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A84FF),
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: _nextQuestion,
                    child: Text(
                      _currentIndex < _quizWords.length - 1
                          ? 'Next Question'
                          : 'View Results',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}