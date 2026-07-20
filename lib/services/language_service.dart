/// Replaces lib/halper/app_text.dart and lib/halper/util.dart.
///
/// Why this changed:
///   - `halper/util.dart` exposed a top-level mutable `String selectedLanguage`.
///     Any file could reassign it with no notification to widgets that had
///     already built — a classic source of stale-UI bugs. It was also
///     completely unreferenced anywhere else in the app (dead code).
///   - `halper/app_text.dart` used an untyped `Map` for app names, so a typo
///     in a key (e.g. `app_names["hin"]`) fails silently at runtime instead
///     of being caught by the analyzer.
///   - Folder name "halper" (typo of "helper") — cosmetic, but worth fixing
///     before shipping.
///
/// This is replaced by a typed enum plus the existing
/// `PreferencesService.language` getter/setter, which is already the real
/// source of truth for the persisted language and is observed via
/// `setState`/`ValueListenable` where each screen needs it.
enum AppLanguage {
  en('en', 'English'),
  hi('hi', 'हिन्दी'),
  gu('gu', 'ગુજરાતી');

  const AppLanguage(this.code, this.label);
  final String code;
  final String label;

  static AppLanguage fromCode(String code) => AppLanguage.values.firstWhere(
        (l) => l.code == code,
        orElse: () => AppLanguage.en,
      );

  String get appName {
    switch (this) {
      case AppLanguage.en:
        return 'Shrimad Bhagavatam';
      case AppLanguage.hi:
        return 'श्रीमद भागवतम्';
      case AppLanguage.gu:
        return 'શ્રીમદ ભાગવતમ્';
    }
  }
}
