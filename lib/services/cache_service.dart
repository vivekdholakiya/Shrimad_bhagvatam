import 'package:shared_preferences/shared_preferences.dart';

/// CacheService — wraps SharedPreferences for storing JSON strings.
/// Every key maps to a string (JSON-encoded list or map).
class CacheService {
  static CacheService? _instance;
  SharedPreferences? _prefs;

  CacheService._();

  static CacheService get instance {
    _instance ??= CacheService._();
    return _instance!;
  }

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    if (_prefs == null) throw StateError('CacheService not initialized');
    return _prefs!;
  }

  // ──────────────────────────────────────
  //  Read
  // ──────────────────────────────────────

  String? getString(String key) => _p.getString(key);

  bool containsKey(String key) => _p.containsKey(key);

  // ──────────────────────────────────────
  //  Write
  // ──────────────────────────────────────

  Future<void> setString(String key, String value) =>
      _p.setString(key, value);

  Future<void> remove(String key) => _p.remove(key);

  // ──────────────────────────────────────
  //  Convenience Keys
  // ──────────────────────────────────────

  static String cantosKey = 'cantos_list';
  static String chaptersKey(int cantoNum) => 'chapters_canto_$cantoNum';
  static String versesKey(int cantoNum, int chapterNum) =>
      'verses_canto_${cantoNum}_chapter_$chapterNum';
  static String verseKey(int cantoNum, int chapterNum, int verseNum) =>
      'verse_${cantoNum}_${chapterNum}_$verseNum';
}
