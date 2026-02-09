import 'package:hive/hive.dart';

// This file name must match your filename.g.dart
part 'word_model.g.dart';

@HiveType(typeId: 0)
class DictionaryWord extends HiveObject {
  @HiveField(0)
  final String englishWord;

  @HiveField(1)
  final String tamilWord;

  @HiveField(2)
  final String englishDef;

  @HiveField(3)
  final String tamilDef;

  @HiveField(4)
  final String englishExample;

  @HiveField(5)
  final String tamilExample;

  @HiveField(6)
  final String imageUrl;

  @HiveField(7)
  final String domainName;

  DictionaryWord({
    required this.englishWord,
    required this.tamilWord,
    required this.englishDef,
    required this.tamilDef,
    required this.englishExample,
    required this.tamilExample,
    required this.imageUrl,
    required this.domainName,
  });
}