// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DictionaryWordAdapter extends TypeAdapter<DictionaryWord> {
  @override
  final int typeId = 0;

  @override
  DictionaryWord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DictionaryWord(
      englishWord: fields[0] as String,
      tamilWord: fields[1] as String,
      englishDef: fields[2] as String,
      tamilDef: fields[3] as String,
      englishExample: fields[4] as String,
      tamilExample: fields[5] as String,
      imageUrl: fields[6] as String,
      domainName: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DictionaryWord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.englishWord)
      ..writeByte(1)
      ..write(obj.tamilWord)
      ..writeByte(2)
      ..write(obj.englishDef)
      ..writeByte(3)
      ..write(obj.tamilDef)
      ..writeByte(4)
      ..write(obj.englishExample)
      ..writeByte(5)
      ..write(obj.tamilExample)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.domainName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DictionaryWordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
