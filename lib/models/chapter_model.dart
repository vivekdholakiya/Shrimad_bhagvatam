import 'dart:convert';

class ChapterModel {
  final String id;
  final int chapterNumber;
  final int cantoNumber;
  final String? title;
  final int verseCount;

  const ChapterModel({
    required this.id,
    required this.chapterNumber,
    required this.cantoNumber,
    this.title,
    required this.verseCount,
  });

  factory ChapterModel.fromFirestore(
      Map<String, dynamic> data,
      String docId,
      int cantoNumber, {
        required int verseCount,
      }) {
    return ChapterModel(
      id: docId,
      chapterNumber: (data['chapter'] as num).toInt(),
      cantoNumber: cantoNumber,
      title: data['title'] as String?,
      verseCount: verseCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'chapterNumber': chapterNumber,
    'cantoNumber': cantoNumber,
    'title': title,
    'verseCount': verseCount,
  };

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'],
      chapterNumber: json['chapterNumber'],
      cantoNumber: json['cantoNumber'],
      title: json['title'],
      verseCount: json['verseCount'],
    );
  }

  static String encodeList(List<ChapterModel> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<ChapterModel> decodeList(String raw) {
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => ChapterModel.fromJson(e))
        .toList();
  }

  String get displayName => "Chapter $chapterNumber";
}