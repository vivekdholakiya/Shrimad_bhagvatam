import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/canto_model.dart';
import '../services/firestore_service.dart';
import '../services/network_service.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../utils/canto_meta.dart';
import '../widgets/app_header.dart';
import '../widgets/canto_card.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/ui_kit.dart';
import 'chapter_list_screen.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';
import 'search_screen.dart';
import 'verse_reader_screen.dart';

/// HomeScreen — redesigned per the premium UI brief.
///
/// Business logic is byte-for-byte unchanged from before: same data loading
/// via FirestoreService, same PreferencesService reads for "continue
/// reading", same navigation targets, same bottom-nav tabs. Only the visual
/// layer changed:
///   - SliverAppBar → AppHeader.hero (no AppBar/SliverAppBar anywhere)
///   - CustomScrollView/slivers → a single ListView (the hero header no
///     longer needs to collapse/parallax, so slivers added complexity
///     without benefit here — this also removes several sliver rebuilds)
///   - Continue-reading card, daily-verse card, and error state now route
///     through the shared AppCard / ErrorStateView from ui_kit.dart instead
///     of one-off Container/BoxDecoration blocks, so they visually match
///     every other card in the redesigned app.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<CantoModel> _cantos = [];
  bool _loading = true;
  bool _error = false;
  bool _offline = false;
  int _navIndex = 0;

  // Continue reading
  int? _lastCanto;
  int? _lastChapter;
  int? _lastVerse;

  final _prefs = PreferencesService.instance;
  final _fs = FirestoreService.instance;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: AppMotion.easeOut);
    _loadData();
    _loadLastRead();
  }

  void _loadLastRead() {
    setState(() {
      _lastCanto = _prefs.lastCanto;
      _lastChapter = _prefs.lastChapter;
      _lastVerse = _prefs.lastVerse;
    });
  }

  Future<void> _loadData({bool refresh = false}) async {
    setState(() {
      _loading = true;
      _error = false;
      _offline = false;
    });

    try {
      final cantos = await _fs.getCantos(forceRefresh: refresh);
      if (!mounted) return;
      setState(() {
        _cantos = cantos;
        _loading = false;
      });
      _fadeController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
        _offline = e is NoConnectionException;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBase : AppColors.cream,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _buildHomeTab(isDark),
          const SearchScreen(),
          const BookmarksScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildNavBar(isDark),
    );
  }

  // ── Bottom navigation ──────────────────────────────────────────────
  Widget _buildNavBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.warmWhite,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor:
        isDark ? AppColors.textLight : AppColors.textMedium,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_rounded), label: 'Bookmarks'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }

  // ── Home tab ───────────────────────────────────────────────────────
  Widget _buildHomeTab(bool isDark) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _loadData(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          _buildHeroHeader(),
          if (_lastCanto != null) _buildContinueReadingCard(isDark),
          _buildDailyVerse(isDark),
          SectionTitle(
            title: 'All 12 Cantos',
            trailing: _loading
                ? null
                : Text(
              '${_cantos.length} available',
              style: TextStyle(fontSize: 12, color: AppColors.textMedium),
            ),
          ),
          if (_loading)
            ...List.generate(6, (_) => const CantoCardSkeleton())
          else if (_error)
            ErrorStateView(
              title: _offline ? "You're offline" : 'Could not load cantos',
              message: _offline
                  ? 'Connect to the internet to load new content. Anything already downloaded is still available.'
                  : 'Something went wrong loading the scripture. Please try again.',
              offline: _offline,
              onRetry: _loadData,
            )
          else
            ...List.generate(
              _cantos.length,
                  (i) => FadeTransition(
                opacity: _fadeAnim,
                child: CantoCard(
                  canto: _cantos[i],
                  onTap: () => _openCanto(_cantos[i]),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  // ── Hero header (replaces the old SliverAppBar) ─────────────────────
  Widget _buildHeroHeader() {
    return AppHeader.hero(
      bottom: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🪷 श्रीमद्भागवतम्',
            style: GoogleFonts.notoSerifDevanagari(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.goldLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Shrimad Bhagavatam',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '॥ सत्यं परम् धीमहि ॥',
            style: GoogleFonts.notoSerifDevanagari(
              fontSize: 12,
              color: AppColors.gold.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ── Continue reading card ────────────────────────────────────────────
  Widget _buildContinueReadingCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
      child: AppCard(
        goldBorder: true,
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkCard, AppColors.darkElevated]
              : [AppColors.maroon.withOpacity(0.06), AppColors.cream],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () async {
          final verse = await FirestoreService.instance.getVerse(
            _lastCanto!,
            _lastChapter!,
            _lastVerse!,
          );
          if (!mounted || verse == null) return;
          final verses = await FirestoreService.instance.getVerses(
            _lastCanto!,
            _lastChapter!,
          );
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VerseReaderScreen(
                verses: verses,
                initialIndex:
                verses.indexWhere((v) => v.verseNumber == _lastVerse)
                    .clamp(0, verses.length - 1),
                cantoNumber: _lastCanto!,
                chapterNumber: _lastChapter!,
              ),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.maroon,
                borderRadius: AppRadius.smRadius,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continue Reading',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.goldLight : AppColors.maroon,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Canto $_lastCanto · Chapter $_lastChapter · Verse $_lastVerse',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textLight : AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.gold.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }

  // ── Daily verse card ─────────────────────────────────────────────────
  Widget _buildDailyVerse(bool isDark) {
    final day = DateTime.now().dayOfYear;
    final cantoNum = (day % 12) + 1;
    final symbol = cantoSymbol(cantoNum);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.xs),
      child: AppCard(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2E1A00), const Color(0xFF1E1000)]
              : [AppColors.gold.withOpacity(0.12), AppColors.saffron.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Row(
          children: [
            Text(symbol, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "✨ Today's Reading",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Canto $cantoNum · ${cantoName(cantoNum)}',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFF5E8C8) : AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            AppButton.text(
              label: 'Read',
              onPressed: () {
                if (_cantos.isNotEmpty) {
                  final match = _cantos.where((c) => c.cantoNumber == cantoNum);
                  if (match.isNotEmpty) _openCanto(match.first);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openCanto(CantoModel canto) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChapterListScreen(canto: canto)),
    );
  }
}

extension on DateTime {
  int get dayOfYear {
    final start = DateTime(year, 1, 1);
    return difference(start).inDays + 1;
  }
}