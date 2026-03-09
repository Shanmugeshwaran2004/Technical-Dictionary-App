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
  final _engController    = TextEditingController();
  final _tamController    = TextEditingController();
  final _engDefController = TextEditingController();
  final _tamDefController = TextEditingController();
  final _engExController  = TextEditingController();
  final _tamExController  = TextEditingController();
  final _imgController    = TextEditingController();

  String _selectedDomain = 'AI';
  bool _isSaving = false;

  final List<String> _domains = [
    'AI', 'ML', 'DL', 'CN', 'CV', 'DBMS', 'OS', 'Python', 'Java', 'NLP', 'DS'
  ];

  @override
  void dispose() {
    for (final c in [
      _engController, _tamController, _engDefController, _tamDefController,
      _engExController, _tamExController, _imgController
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveWord() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final box = Hive.box<DictionaryWord>('dictionaryBox');
    await box.add(DictionaryWord(
      englishWord:    _engController.text.trim(),
      tamilWord:      _tamController.text.trim(),
      englishDef:     _engDefController.text.trim(),
      tamilDef:       _tamDefController.text.trim(),
      englishExample: _engExController.text.trim(),
      tamilExample:   _tamExController.text.trim(),
      imageUrl:       _imgController.text.trim(),
      domainName:     _selectedDomain,
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✓  Word added to dictionary'),
          backgroundColor: const Color(0xFF30D158),
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0C0C0E) : const Color(0xFFF2F2F7);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

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
                color: textColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: textColor.withOpacity(0.7)),
            ),
          ),
        ),
        title: Text(
          'Add Word',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _isSaving ? null : _saveWord,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0A84FF),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: _isSaving
                  ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF0A84FF)))
                  : const Text('Save',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Domain ──────────────────────────────────────────────────
            _SectionLabel(label: 'Domain', isDark: isDark),
            const SizedBox(height: 10),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

            const SizedBox(height: 28),

            // ── English ──────────────────────────────────────────────────
            _SectionLabel(label: '🇬🇧  English', isDark: isDark),
            const SizedBox(height: 10),
            _FormCard(
              isDark: isDark,
              cardBg: cardBg,
              children: [
                _FieldRow(
                  controller: _engController,
                  label: 'Word',
                  isDark: isDark,
                  validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                _Divider(isDark: isDark),
                _FieldRow(
                  controller: _engDefController,
                  label: 'Definition',
                  isDark: isDark,
                  maxLines: 3,
                  validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                _Divider(isDark: isDark),
                _FieldRow(
                  controller: _engExController,
                  label: 'Example',
                  isDark: isDark,
                  maxLines: 2,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Tamil ───────────────────────────────────────────────────
            _SectionLabel(label: '🇮🇳  தமிழ்', isDark: isDark),
            const SizedBox(height: 10),
            _FormCard(
              isDark: isDark,
              cardBg: cardBg,
              children: [
                _FieldRow(
                  controller: _tamController,
                  label: 'வார்த்தை',
                  isDark: isDark,
                  validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? 'Required'
                      : null,
                ),
                _Divider(isDark: isDark),
                _FieldRow(
                  controller: _tamDefController,
                  label: 'விளக்கம்',
                  isDark: isDark,
                  maxLines: 3,
                ),
                _Divider(isDark: isDark),
                _FieldRow(
                  controller: _tamExController,
                  label: 'உதாரணம்',
                  isDark: isDark,
                  maxLines: 2,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Image ───────────────────────────────────────────────────
            _SectionLabel(label: 'Image', isDark: isDark),
            const SizedBox(height: 10),
            _FormCard(
              isDark: isDark,
              cardBg: cardBg,
              children: [
                _FieldRow(
                  controller: _imgController,
                  label: 'Image URL',
                  isDark: isDark,
                  keyboardType: TextInputType.url,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Save Button ─────────────────────────────────────────────
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
                onPressed: _isSaving ? null : _saveWord,
                child: _isSaving
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                    : const Text(
                  'Save to Dictionary',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.45),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final List<Widget> children;
  const _FormCard(
      {required this.isDark,
        required this.cardBg,
        required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isDark;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FieldRow({
    required this.controller,
    required this.label,
    required this.isDark,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(fontSize: 15, color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 13,
            color: textColor.withOpacity(0.4),
          ),
          border: InputBorder.none,
          errorStyle: const TextStyle(
              fontSize: 11, color: Color(0xFFFF453A)),
        ),
      ),
    );
  }
}