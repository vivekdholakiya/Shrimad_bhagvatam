import 'dart:convert';

class VerseModel {
  final String id;
  final int verseNumber;
  final int chapterNumber;
  final int cantoNumber;

  // Sanskrit content
  final String? devanagari;
  final String? transliteration; // english_devnagari field
  final String? verse;
  final String? verseSyn; // verse_syn

  // Translations
  final String? translationEn;
  final String? translationGu;
  final String? translationHi;

  // Purports
  final String? purportEn;
  final String? purportGu;
  final String? purportHi;

  const VerseModel({
    required this.id,
    required this.verseNumber,
    required this.chapterNumber,
    required this.cantoNumber,
    this.devanagari,
    this.transliteration,
    this.verse,
    this.verseSyn,
    this.translationEn,
    this.translationGu,
    this.translationHi,
    this.purportEn,
    this.purportGu,
    this.purportHi,
  });

  /// Safely coerces a Firestore field into a String, regardless of whether
  /// it was stored as a plain String or as a List (e.g. purport paragraphs
  /// stored as an array of strings). Prevents:
  ///   "type 'List<dynamic>' is not a subtype of type 'String?'"
  static String? _asString(dynamic value, {String separator = '\n\n'}) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List) {
      return value
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .join(separator);
    }
    // Fallback for any other unexpected type (num, bool, map, etc.)
    return value.toString();
  }

  factory VerseModel.fromFirestore(
      Map<String, dynamic> data, String docId, int chapterNumber, int cantoNumber) {
    return VerseModel(
      id: docId,
      verseNumber: (data['verse_number'] as num?)?.toInt() ?? 0,
      chapterNumber: chapterNumber,
      cantoNumber: cantoNumber,
      devanagari: _asString(data['devanagari']),
      transliteration: _asString(data['english_devnagari']),
      verse: _asString(data['verse']),
      verseSyn: _asString(data['verse_syn']),
      translationEn: _asString(data['translation_en']),
      translationGu: _asString(data['translation_gu']),
      translationHi: _asString(data['translation_hi']),
      purportEn: _asString(data['purport_en']),
      purportGu: _asString(data['purport_gu']),
      purportHi: _asString(data['purport_hi']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'verseNumber': verseNumber,
    'chapterNumber': chapterNumber,
    'cantoNumber': cantoNumber,
    'devanagari': devanagari,
    'transliteration': transliteration,
    'verse': verse,
    'verseSyn': verseSyn,
    'translationEn': translationEn,
    'translationGu': translationGu,
    'translationHi': translationHi,
    'purportEn': purportEn,
    'purportGu': purportGu,
    'purportHi': purportHi,
  };

  factory VerseModel.fromJson(Map<String, dynamic> json) => VerseModel(
    id: json['id'] as String,
    verseNumber: (json['verseNumber'] as num).toInt(),
    chapterNumber: (json['chapterNumber'] as num).toInt(),
    cantoNumber: (json['cantoNumber'] as num).toInt(),
    devanagari: _asString(json['devanagari']),
    transliteration: _asString(json['transliteration']),
    verse: _asString(json['verse']),
    verseSyn: _asString(json['verseSyn']),
    translationEn: _asString(json['translationEn']),
    translationGu: _asString(json['translationGu']),
    translationHi: _asString(json['translationHi']),
    purportEn: _asString(json['purportEn']),
    purportGu: _asString(json['purportGu']),
    purportHi: _asString(json['purportHi']),
  );

  static String encodeList(List<VerseModel> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<VerseModel> decodeList(String raw) {
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => VerseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String get displayName => 'Verse $verseNumber';

  /// Returns the verse number as a string, e.g. "1.2.3"
  String get fullRef => '$cantoNumber.$chapterNumber.$verseNumber';

  String translation(String lang) {
    switch (lang) {
      case 'gu':
        return translationGu ?? translationEn ?? '';
      case 'hi':
        return translationHi ?? translationEn ?? '';
      default:
        return translationEn ?? '';
    }
  }

  String purport(String lang) {
    switch (lang) {
      case 'gu':
        return purportGu ?? purportEn ?? '';
      case 'hi':
        return purportHi ?? purportEn ?? '';
      default:
        return purportEn ?? '';
    }
  }

  /// Short preview for lists — first 120 chars of English translation
  String get previewText {
    final t = translationEn ?? devanagari ?? '';
    if (t.length > 120) return '${t.substring(0, 120)}…';
    return t;
  }
}