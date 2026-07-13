import 'dart:convert';

class CantoModel {
  final String id;
  final int cantoNumber;
  final String? title;
  final int chapterCount;

  const CantoModel({
    required this.id,
    required this.cantoNumber,
    this.title,
    required this.chapterCount,
  });

  factory CantoModel.fromFirestore(
      Map<String, dynamic> data,
      String docId, {
        required int chapterCount,
      }) {
    return CantoModel(
      id: docId,
      cantoNumber: (data['canto'] as num).toInt(),
      title: data['title'] as String?,
      chapterCount: chapterCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cantoNumber': cantoNumber,
    'title': title,
    'chapterCount': chapterCount,
  };

  factory CantoModel.fromJson(Map<String, dynamic> json) {
    return CantoModel(
      id: json['id'],
      cantoNumber: json['cantoNumber'],
      title: json['title'],
      chapterCount: json['chapterCount'],
    );
  }

  static String encodeList(List<CantoModel> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<CantoModel> decodeList(String raw) {
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => CantoModel.fromJson(e))
        .toList();
  }

  String get displayName => "Canto $cantoNumber";
}