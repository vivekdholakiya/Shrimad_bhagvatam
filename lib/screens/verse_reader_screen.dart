import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/verse_model.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class VerseReaderScreen extends StatefulWidget {
  final List<VerseModel> verses;
  final int initialIndex;
  final int cantoNumber;
  final int chapterNumber;

  const VerseReaderScreen({
    super.key,
    required this.verses,
    required this.initialIndex,
    required this.cantoNumber,
    required this.chapterNumber,
  });

  @override
  State<VerseReaderScreen> createState() => _VerseReaderScreenState();
}

class _VerseReaderScreenState extends State<VerseReaderScreen> {
  late PageController _pageController;
  late int _currentIndex;

  final _prefs = PreferencesService.instance;
  late String _language;
  late double _fontSize;
  late ReadingTheme _readingTheme;
  bool _showControls = true;
  bool _showPurport = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _language = _prefs.language;
    _fontSize = _prefs.fontSize;
    _readingTheme = _prefs.readingTheme;

    _pageController = PageController(initialPage: _currentIndex);
    _saveLastRead();
  }

  VerseModel get _currentVerse => widget.verses[_currentIndex];

  Future<void> _saveLastRead() async {
    final v = _currentVerse;
    await _prefs.saveLastRead(v.cantoNumber, v.chapterNumber, v.verseNumber);
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _saveLastRead();
  }

  void _toggleBookmark() async {
    final v = _currentVerse;
    await _prefs.toggleBookmark(v.cantoNumber, v.chapterNumber, v.verseNumber);
    setState(() {});
  }

  bool get _isBookmarked {
    final v = _currentVerse;
    return _prefs.isBookmarked(v.cantoNumber, v.chapterNumber, v.verseNumber);
  }

  Future<void> _share() async {
    final v = _currentVerse;
    final translation = v.translation(_language);
    final text = '''
Shrimad Bhagavatam ${v.fullRef}

${v.devanagari ?? ''}

${v.transliteration ?? ''}

Translation: $translation

— Śrīmad-Bhāgavatam, Canto ${v.cantoNumber}, Chapter ${v.chapterNumber}, Verse ${v.verseNumber}
    '''.trim();

    // sharePositionOrigin is required on iPad — without it share_plus can
    // silently fail or crash there. We derive it from this screen's own
    // RenderBox rather than adding a GlobalKey just for the share button.
    final box = context.findRenderObject() as RenderBox?;

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: 'Shrimad Bhagavatam ${v.fullRef}',
          sharePositionOrigin:
          box != null ? (box.localToGlobal(Offset.zero) & box.size) : null,
        ),
      );
    } catch (e) {
      // Sharing is a non-critical, user-initiated action — fail silently
      // in release rather than crashing the reading experience, but keep
      // the signal in debug builds.
      if (kDebugMode) debugPrint('Share failed: $e');
    }
  }

  void _cycleFontSize() {
    final sizes = [14.0, 16.0, 18.0, 20.0, 22.0];
    final nextIndex = (sizes.indexOf(_fontSize) + 1) % sizes.length;
    setState(() => _fontSize = sizes[nextIndex]);
    _prefs.setFontSize(_fontSize);
  }

  void _cycleTheme() {
    final themes = ReadingTheme.values;
    final next = themes[(themes.indexOf(_readingTheme) + 1) % themes.length];
    setState(() => _readingTheme = next);
    _prefs.setReadingTheme(next);
  }

  void _cycleLanguage() {
    final langs = ['en', 'hi', 'gu'];
    final next = langs[(langs.indexOf(_language) + 1) % langs.length];
    setState(() => _language = next);
    _prefs.setLanguage(next);
  }

  // ─── Reading Theme Colours ────────────────────
  Color get _bgColor {
    switch (_readingTheme) {
      case ReadingTheme.dark:
        return AppColors.darkBase;
      case ReadingTheme.sepia:
        return AppColors.sepiaBg;
      case ReadingTheme.light:
        return AppColors.warmWhite;
    }
  }

  Color get _cardColor {
    switch (_readingTheme) {
      case ReadingTheme.dark:
        return AppColors.darkCard;
      case ReadingTheme.sepia:
        return AppColors.sepiaCard;
      case ReadingTheme.light:
        return AppColors.cardLight;
    }
  }

  Color get _textColor {
    switch (_readingTheme) {
      case ReadingTheme.dark:
        return const Color(0xFFF5E8C8);
      case ReadingTheme.sepia:
        return AppColors.sepiaText;
      case ReadingTheme.light:
        return AppColors.textDark;
    }
  }

  Color get _secondaryTextColor {
    switch (_readingTheme) {
      case ReadingTheme.dark:
        return const Color(0xFFD4A96A);
      case ReadingTheme.sepia:
        return const Color(0xFF6B4E25);
      case ReadingTheme.light:
        return AppColors.textMedium;
    }
  }

  Color get _devanagariColor {
    switch (_readingTheme) {
      case ReadingTheme.dark:
        return AppColors.goldLight;
      case ReadingTheme.sepia:
        return AppColors.maroon;
      case ReadingTheme.light:
        return AppColors.maroon;
    }
  }

  Color get _accentColor {
    switch (_readingTheme) {
      case ReadingTheme.dark:
        return AppColors.gold;
      case ReadingTheme.sepia:
        return AppColors.maroon;
      case ReadingTheme.light:
        return AppColors.maroon;
    }
  }

  String get _languageLabel {
    switch (_language) {
      case 'hi':
        return 'हिन्दी';
      case 'gu':
        return 'ગુજ.';
      default:
        return 'EN';
    }
  }

  String get _themeLabel {
    switch (_readingTheme) {
      case ReadingTheme.dark:
        return '🌙';
      case ReadingTheme.sepia:
        return '☕';
      case ReadingTheme.light:
        return '☀️';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          children: [
            // ── Page View ─────────────────────────────────────────
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.verses.length,
              itemBuilder: (_, i) => _VersePage(
                verse: widget.verses[i],
                language: _language,
                fontSize: _fontSize,
                bgColor: _bgColor,
                cardColor: _cardColor,
                textColor: _textColor,
                secondaryTextColor: _secondaryTextColor,
                devanagariColor: _devanagariColor,
                accentColor: _accentColor,
                showPurport: _showPurport,
              ),
            ),

            // ── App Bar ────────────────────────────────────────────
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: _buildAppBar(),
            ),

            // ── Bottom Controls ────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: _buildBottomBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _bgColor.withOpacity(0.98),
            _bgColor.withOpacity(0.6),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: _accentColor),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Canto ${widget.cantoNumber} · Ch. ${widget.chapterNumber}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: _accentColor,
                      ),
                    ),
                    Text(
                      'Verse ${_currentVerse.verseNumber} of ${widget.verses.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Bookmark
              IconButton(
                icon: Icon(
                  _isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: _isBookmarked ? AppColors.gold : _accentColor,
                ),
                onPressed: _toggleBookmark,
              ),
              // Share
              IconButton(
                icon: Icon(Icons.share_rounded, color: _accentColor),
                onPressed: _share,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            _bgColor.withOpacity(0.98),
            _bgColor.withOpacity(0.7),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: widget.verses.isEmpty
                      ? 0
                      : (_currentIndex + 1) / widget.verses.length,
                  backgroundColor: _cardColor,
                  valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                  minHeight: 3,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Language toggle
                  _ControlButton(
                    label: _languageLabel,
                    icon: Icons.translate_rounded,
                    color: _accentColor,
                    onTap: _cycleLanguage,
                  ),

                  // Prev / Next
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left_rounded,
                            color: _currentIndex > 0
                                ? _accentColor
                                : _accentColor.withOpacity(0.3),
                            size: 32),
                        onPressed: _currentIndex > 0
                            ? () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        )
                            : null,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_currentIndex + 1}/${widget.verses.length}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _secondaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(Icons.chevron_right_rounded,
                            color: _currentIndex < widget.verses.length - 1
                                ? _accentColor
                                : _accentColor.withOpacity(0.3),
                            size: 32),
                        onPressed:
                        _currentIndex < widget.verses.length - 1
                            ? () => _pageController.nextPage(
                          duration:
                          const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        )
                            : null,
                      ),
                    ],
                  ),

                  // Theme + Font size
                  Row(
                    children: [
                      _ControlButton(
                        label: _themeLabel,
                        color: _accentColor,
                        onTap: _cycleTheme,
                      ),
                      const SizedBox(width: 4),
                      _ControlButton(
                        label: 'Aa',
                        color: _accentColor,
                        onTap: _cycleFontSize,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Single Verse Page ────────────────────────────────────────────
class _VersePage extends StatelessWidget {
  final VerseModel verse;
  final String language;
  final double fontSize;
  final Color bgColor;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color devanagariColor;
  final Color accentColor;
  final bool showPurport;

  const _VersePage({
    required this.verse,
    required this.language,
    required this.fontSize,
    required this.bgColor,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.devanagariColor,
    required this.accentColor,
    required this.showPurport,
  });

  @override
  Widget build(BuildContext context) {
    final translation = verse.translation(language);
    final purport = verse.purport(language);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 80,
        16,
        120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Verse Ref badge ──────────────────────────────────
          Center(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                    color: accentColor.withOpacity(0.3), width: 1),
                borderRadius: BorderRadius.circular(20),
                color: accentColor.withOpacity(0.07),
              ),
              child: Text(
                '${verse.fullRef}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Devanagari ───────────────────────────────────────
          if (verse.devanagari != null && verse.devanagari!.isNotEmpty) ...[
            _SectionCard(
              cardColor: cardColor,
              accentColor: accentColor,
              label: 'DEVANAGARI',
              child: Text(
                verse.devanagari!,
                style: GoogleFonts.notoSerifDevanagari(
                  fontSize: fontSize + 2,
                  color: devanagariColor,
                  height: 1.8,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Transliteration ──────────────────────────────────
          if (verse.transliteration != null &&
              verse.transliteration!.isNotEmpty) ...[
            _SectionCard(
              cardColor: cardColor,
              accentColor: accentColor,
              label: 'TRANSLITERATION',
              child: Text(
                verse.transliteration!,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: fontSize - 0.5,
                  fontStyle: FontStyle.italic,
                  color: secondaryTextColor,
                  height: 1.75,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Verse Synonyms ───────────────────────────────────
          if (verse.verseSyn != null && verse.verseSyn!.isNotEmpty) ...[
            _SectionCard(
              cardColor: cardColor,
              accentColor: accentColor,
              label: 'WORD SYNONYMS',
              child: Text(
                verse.verseSyn!,
                style: TextStyle(
                  fontSize: fontSize - 1.5,
                  color: secondaryTextColor,
                  height: 1.7,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Translation ───────────────────────────────────────
          if (translation.isNotEmpty) ...[
            _SectionCard(
              cardColor: cardColor,
              accentColor: accentColor,
              label: 'TRANSLATION',
              labelColor: accentColor,
              child: Text(
                translation,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: fontSize,
                  color: textColor,
                  height: 1.8,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Purport ───────────────────────────────────────────
          if (showPurport && purport.isNotEmpty) ...[
            _SectionCard(
              cardColor: cardColor,
              accentColor: accentColor,
              label: 'PURPORT',
              child: Text(
                purport,
                style: TextStyle(
                  fontSize: fontSize - 0.5,
                  color: textColor,
                  height: 1.85,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Reusable Section Card ─────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final Color cardColor;
  final Color accentColor;
  final String label;
  final Widget child;
  final Color? labelColor;

  const _SectionCard({
    required this.cardColor,
    required this.accentColor,
    required this.label,
    required this.child,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final lc = labelColor ?? accentColor.withOpacity(0.6);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 2.5,
                height: 14,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  color: lc,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Control Button ─────────────────────────────────────────────────
class _ControlButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;

  const _ControlButton({
    required this.label,
    this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(10),
          color: color.withOpacity(0.08),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}