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
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0C0C0E) : const Color(0xFFF2F2F7);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: bg,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black)
                        .withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: (isDark ? Colors.white : Colors.black)
                        .withOpacity(0.7),
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.domain.toUpperCase(),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    'Dictionary',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Search Bar ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search terms…',
                    hintStyle: TextStyle(
                      color: (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.35),
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.4),
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: (isDark ? Colors.white : Colors.black)
                            .withOpacity(0.4),
                      ),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                ),
              ),
            ),
          ),

          // ── Word List ──────────────────────────────────────────────────
          ValueListenableBuilder(
            valueListenable:
            Hive.box<DictionaryWord>('dictionaryBox').listenable(),
            builder: (context, Box<DictionaryWord> box, _) {
              final words = box.values
                  .where((w) => w.domainName.toLowerCase() ==
                  widget.domain.toLowerCase())
                  .where((w) =>
                  w.englishWord.toLowerCase().contains(_searchQuery))
                  .toList()
                ..sort((a, b) => a.englishWord.compareTo(b.englishWord));

              if (words.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 56,
                            color: (isDark ? Colors.white : Colors.black)
                                .withOpacity(0.2)),
                        const SizedBox(height: 14),
                        Text(
                          'No words found',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: (isDark ? Colors.white : Colors.black)
                                .withOpacity(0.35),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try refreshing from home',
                          style: TextStyle(
                            fontSize: 13,
                            color: (isDark ? Colors.white : Colors.black)
                                .withOpacity(0.25),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _WordTile(
                        word: words[i],
                        isDark: isDark,
                        cardBg: cardBg,
                        onTap: () => _showWordDetail(context, words[i], isDark),
                      ),
                    ),
                    childCount: words.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showWordDetail(BuildContext context, DictionaryWord word, bool isDark) {
    final tts = FlutterTts();
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        word.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : Colors.black)
                                .withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: (isDark ? Colors.white : Colors.black)
                                .withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // English section
                    _SectionHeader(
                        label: 'ENGLISH', color: const Color(0xFF0A84FF)),
                    const SizedBox(height: 12),
                    _WordHeader(
                        text: word.englishWord,
                        lang: 'en-US',
                        tts: tts,
                        color: const Color(0xFF0A84FF),
                        isDark: isDark),
                    const SizedBox(height: 10),
                    _DetailRow(
                        icon: Icons.menu_book_outlined,
                        label: 'Definition',
                        value: word.englishDef,
                        isDark: isDark),
                    const SizedBox(height: 8),
                    _DetailRow(
                        icon: Icons.format_quote_rounded,
                        label: 'Example',
                        value: word.englishExample,
                        isDark: isDark),

                    const SizedBox(height: 24),
                    Divider(
                      color: (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.08),
                    ),
                    const SizedBox(height: 24),

                    // Tamil section
                    _SectionHeader(
                        label: 'தமிழ்', color: const Color(0xFF30D158)),
                    const SizedBox(height: 12),
                    _WordHeader(
                        text: word.tamilWord,
                        lang: 'ta-IN',
                        tts: tts,
                        color: const Color(0xFF30D158),
                        isDark: isDark),
                    const SizedBox(height: 10),
                    _DetailRow(
                        icon: Icons.menu_book_outlined,
                        label: 'விளக்கம்',
                        value: word.tamilDef,
                        isDark: isDark),
                    const SizedBox(height: 8),
                    _DetailRow(
                        icon: Icons.format_quote_rounded,
                        label: 'உதாரணம்',
                        value: word.tamilExample,
                        isDark: isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Word Tile ─────────────────────────────────────────────────────────────────
class _WordTile extends StatelessWidget {
  final DictionaryWord word;
  final bool isDark;
  final Color cardBg;
  final VoidCallback onTap;

  const _WordTile({
    required this.word,
    required this.isDark,
    required this.cardBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0A84FF).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  word.englishWord[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF0A84FF),
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.englishWord,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    word.tamilWord,
                    style: TextStyle(
                      fontSize: 13,
                      color: (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color:
              (isDark ? Colors.white : Colors.black).withOpacity(0.25),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: color,
      ),
    );
  }
}

// ─── Word header with TTS ──────────────────────────────────────────────────────
class _WordHeader extends StatelessWidget {
  final String text;
  final String lang;
  final FlutterTts tts;
  final Color color;
  final bool isDark;
  const _WordHeader(
      {required this.text,
        required this.lang,
        required this.tts,
        required this.color,
        required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            await tts.setLanguage(lang);
            await tts.speak(text);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.volume_up_rounded, color: color, size: 20),
          ),
        ),
      ],
    );
  }
}

// ─── Detail Row ────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  const _DetailRow(
      {required this.icon,
        required this.label,
        required this.value,
        required this.isDark});

  @override
  Widget build(BuildContext context) {
    final subtle =
    (isDark ? Colors.white : Colors.black).withOpacity(0.45);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 15, color: subtle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label  ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: subtle,
                    letterSpacing: 0.2,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}