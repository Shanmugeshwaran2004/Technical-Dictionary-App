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
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0A84FF),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const DomainListPage(),
    );
  }
}

// ─── Domain tile model ────────────────────────────────────────────────────────
class _DomainMeta {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const _DomainMeta(this.key, this.label, this.icon, this.color);
}

// ─── Domain List Page ─────────────────────────────────────────────────────────
class DomainListPage extends StatefulWidget {
  const DomainListPage({super.key});

  @override
  State<DomainListPage> createState() => _DomainListPageState();
}

class _DomainListPageState extends State<DomainListPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animCtrl;

  final List<_DomainMeta> _domains = const [
    _DomainMeta('AI',     'Artificial Intelligence', Icons.psychology_outlined,      Color(0xFF5E5CE6)),
    _DomainMeta('ML',     'Machine Learning',         Icons.auto_graph,               Color(0xFF30B0C7)),
    _DomainMeta('DL',     'Deep Learning',            Icons.hub_outlined,             Color(0xFF0A84FF)),
    _DomainMeta('CN',     'Computer Networks',        Icons.lan_outlined,             Color(0xFF32D74B)),
    _DomainMeta('CV',     'Computer Vision',          Icons.remove_red_eye_outlined,  Color(0xFFFF9F0A)),
    _DomainMeta('DBMS',   'Database Management',      Icons.storage_outlined,         Color(0xFFFF453A)),
    _DomainMeta('OS',     'Operating Systems',        Icons.developer_board_outlined, Color(0xFFFF6961)),
    _DomainMeta('Python', 'Python',                   Icons.code,                     Color(0xFF30D158)),
    _DomainMeta('java',   'Java',                     Icons.coffee_outlined,          Color(0xFFFF9F0A)),
    _DomainMeta('NLP',    'Natural Language Proc.',   Icons.translate_outlined,       Color(0xFF64D2FF)),
    _DomainMeta('DS',     'Data Structures',          Icons.account_tree_outlined,    Color(0xFFBF5AF2)),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _clearAndReimport() async {
    final box = Hive.box<DictionaryWord>('dictionaryBox');
    setState(() => _isLoading = true);
    await box.clear();
    try {
      final rawData = await rootBundle.loadString('assets/data.csv');
      List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);
      for (var i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        if (row.length >= 8) {
          await box.add(DictionaryWord(
            englishWord:    row[0].toString().trim(),
            tamilWord:      row[1].toString().trim(),
            englishDef:     row[2].toString().trim(),
            englishExample: row[3].toString().trim(),
            tamilDef:       row[4].toString().trim(),
            tamilExample:   row[5].toString().trim(),
            imageUrl:       row[6].toString().trim(),
            domainName:     row[7].toString().trim(),
          ));
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓  Imported ${box.length} words successfully!'),
            backgroundColor: const Color(0xFF32D74B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFFF453A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<DictionaryWord>('dictionaryBox');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0C0C0E) : const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: bg,
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF0A84FF)),
      )
          : CustomScrollView(
        slivers: [
          // ── Large title app bar ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: bg,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TechLex',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        '${box.length} terms · ${_domains.length} domains',
                        style: TextStyle(
                          fontSize: 13,
                          color: (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  _buildRefreshButton(isDark),
                ],
              ),
            ),
          ),

          // ── Grid of domain cards ─────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final delay = index * 0.05;
                  return AnimatedBuilder(
                    animation: _animCtrl,
                    builder: (ctx, child) {
                      final t = Curves.easeOutCubic.transform(
                        ((_animCtrl.value - delay).clamp(0.0, 1.0) /
                            (1.0 - delay.clamp(0.0, 0.9))).clamp(0.0, 1.0),
                      );
                      return Opacity(
                        opacity: t,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - t)),
                          child: child,
                        ),
                      );
                    },
                    child: _DomainCard(
                      meta: _domains[index],
                      isDark: isDark,
                      wordCount: box.values
                          .where((w) => w.domainName.toLowerCase() ==
                          _domains[index].key.toLowerCase())
                          .length,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WordListPage(domain: _domains[index].key),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _domains.length,
              ),
            ),
          ),
        ],
      ),

      // ── Floating Quiz Button ─────────────────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuizPage()),
        ),
        backgroundColor: const Color(0xFF0A84FF),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.quiz_rounded),
        label: const Text(
          'Take Quiz',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildRefreshButton(bool isDark) {
    return GestureDetector(
      onTap: _isLoading ? null : _clearAndReimport,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.refresh_rounded,
          size: 20,
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
        ),
      ),
    );
  }
}

// ─── Domain Card Widget ───────────────────────────────────────────────────────
class _DomainCard extends StatelessWidget {
  final _DomainMeta meta;
  final bool isDark;
  final int wordCount;
  final VoidCallback onTap;

  const _DomainCard({
    required this.meta,
    required this.isDark,
    required this.wordCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: meta.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(meta.icon, color: meta.color, size: 22),
            ),
            const Spacer(),
            Text(
              meta.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$wordCount terms',
              style: TextStyle(
                fontSize: 12,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}