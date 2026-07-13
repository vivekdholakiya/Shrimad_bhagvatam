import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

/// PreferencesService — manages user preferences: language, font size,
/// reading theme, bookmarks, and last-read position.
class PreferencesService {
  static PreferencesService? _instance;
  SharedPreferences? _prefs;

  PreferencesService._();

  static PreferencesService get instance {
    _instance ??= PreferencesService._();
    return _instance!;
  }

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    if (_prefs == null) throw StateError('PreferencesService not initialized');
    return _prefs!;
  }

  // ── Keys ────────────────────────────────────
  static const _keyLanguage = 'pref_language';
  static const _keyFontSize = 'pref_font_size';
  static const _keyReadingTheme = 'pref_reading_theme';
  static const _keyBookmarks = 'pref_bookmarks';
  static const _keyLastCanto = 'pref_last_canto';
  static const _keyLastChapter = 'pref_last_chapter';
  static const _keyLastVerse = 'pref_last_verse';
  static const _keyOnboardingDone = 'pref_onboarding_done';
  static const _keyDarkMode = 'pref_dark_mode';

  // ── Language ────────────────────────────────
  /// 'en' | 'hi' | 'gu'
  String get language => _p.getString(_keyLanguage) ?? 'en';
  Future<void> setLanguage(String lang) => _p.setString(_keyLanguage, lang);

  // ── Font Size ────────────────────────────────
  double get fontSize => _p.getDouble(_keyFontSize) ?? 16.0;
  Future<void> setFontSize(double size) => _p.setDouble(_keyFontSize, size);

  // ── Reading Theme ────────────────────────────
  ReadingTheme get readingTheme {
    final s = _p.getString(_keyReadingTheme) ?? 'light';
    return ReadingTheme.values.firstWhere(
      (e) => e.name == s,
      orElse: () => ReadingTheme.light,
    );
  }

  Future<void> setReadingTheme(ReadingTheme theme) =>
      _p.setString(_keyReadingTheme, theme.name);

  // ── Dark Mode (app-level) ────────────────────
  bool get isDarkMode => _p.getBool(_keyDarkMode) ?? false;
  Future<void> setDarkMode(bool v) => _p.setBool(_keyDarkMode, v);

  // ── Bookmarks ────────────────────────────────
  /// Each bookmark is stored as "canto_chapter_verse"
  List<String> get bookmarks => _p.getStringList(_keyBookmarks) ?? [];

  bool isBookmarked(int canto, int chapter, int verse) =>
      bookmarks.contains('${canto}_${chapter}_$verse');

  Future<void> addBookmark(int canto, int chapter, int verse) async {
    final current = bookmarks;
    final key = '${canto}_${chapter}_$verse';
    if (!current.contains(key)) {
      current.add(key);
      await _p.setStringList(_keyBookmarks, current);
    }
  }

  Future<void> removeBookmark(int canto, int chapter, int verse) async {
    final current = bookmarks;
    current.remove('${canto}_${chapter}_$verse');
    await _p.setStringList(_keyBookmarks, current);
  }

  Future<void> toggleBookmark(int canto, int chapter, int verse) async {
    if (isBookmarked(canto, chapter, verse)) {
      await removeBookmark(canto, chapter, verse);
    } else {
      await addBookmark(canto, chapter, verse);
    }
  }

  // ── Last Read ────────────────────────────────
  int? get lastCanto => _p.getInt(_keyLastCanto);
  int? get lastChapter => _p.getInt(_keyLastChapter);
  int? get lastVerse => _p.getInt(_keyLastVerse);

  bool get hasLastRead => lastCanto != null;

  Future<void> saveLastRead(int canto, int chapter, int verse) async {
    await _p.setInt(_keyLastCanto, canto);
    await _p.setInt(_keyLastChapter, chapter);
    await _p.setInt(_keyLastVerse, verse);
  }

  // ── Onboarding ───────────────────────────────
  bool get onboardingDone => _p.getBool(_keyOnboardingDone) ?? false;
  Future<void> setOnboardingDone() => _p.setBool(_keyOnboardingDone, true);
}
