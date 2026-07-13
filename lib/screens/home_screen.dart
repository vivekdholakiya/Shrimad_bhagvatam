import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/canto_model.dart';
import '../services/firestore_service.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../utils/canto_meta.dart';
import '../widgets/canto_card.dart';
import '../widgets/loading_skeleton.dart';
import 'chapter_list_screen.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';
import 'search_screen.dart';
import 'verse_reader_screen.dart';

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
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
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
    });

    try {
      final cantos = await _fs.getCantos(forceRefresh: refresh);
      if (!mounted) return;
      setState(() {
        _cantos = cantos;
        _loading = false;
      });
      _fadeController.forward(from: 0);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  String get _language => _prefs.language;

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
        selectedItemColor: AppColors.maroon,
        unselectedItemColor:
            isDark ? AppColors.textLight : AppColors.textMedium,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_rounded),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(bool isDark) {
    return RefreshIndicator(
      color: AppColors.maroon,
      onRefresh: () => _loadData(refresh: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildSliverAppBar(isDark),
          if (_lastCanto != null)
            SliverToBoxAdapter(child: _buildContinueReadingCard(isDark)),
          _buildDailyVerse(isDark),
          SliverPadding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.maroon,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'All 12 Cantos',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFFF5E8C8)
                            : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_loading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const CantoCardSkeleton(),
                childCount: 6,
              ),
            )
          else if (_error)
            SliverToBoxAdapter(child: _buildErrorState())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => FadeTransition(
                  opacity: _fadeAnim,
                  child: CantoCard(
                    canto: _cantos[i],
                    // onTap: () async {
                    //
                    //   final db = FirebaseFirestore.instance;
                    //
                    //   final root = db.collection('bhagavat');
                    //
                    //   final chapters = await FirebaseFirestore.instance
                    //       .collection('bhagavat').get();
                    //
                    //   print("canto:- 1 chapter:-${chapters}");
                    //
                    // },
                    onTap: () => _openCanto(_cantos[i]),
                  ),
                ),
                childCount: _cantos.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? AppColors.darkBase : AppColors.maroon,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.maroonDark, AppColors.darkBase]
                  : [AppColors.maroon, const Color(0xFF8B2020)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Shrimad Bhagavatam',
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        titlePadding:
            const EdgeInsets.only(left: 16, bottom: 14),
        collapseMode: CollapseMode.parallax,
      ),
      foregroundColor: Colors.white,
    );
  }

  Widget _buildContinueReadingCard(bool isDark) {
    return GestureDetector(
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
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkCard, AppColors.darkElevated]
                : [AppColors.maroon.withOpacity(0.06), AppColors.cream],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.gold.withOpacity(isDark ? 0.3 : 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowGold,
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.maroon,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
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
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.gold.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyVerse(bool isDark) {
    // Show a random cached verse as a daily suggestion
    // We just use the day-of-year to pick a canto pseudo-randomly
    final day = DateTime.now().dayOfYear;
    final cantoNum = (day % 12) + 1;
    final symbol = cantoSymbol(cantoNum);

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2E1A00), const Color(0xFF1E1000)]
                : [
                    AppColors.gold.withOpacity(0.12),
                    AppColors.saffron.withOpacity(0.08),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.gold.withOpacity(0.35),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(symbol, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ Today\'s Reading',
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
                      color: isDark
                          ? const Color(0xFFF5E8C8)
                          : AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                if (_cantos.isNotEmpty) {
                  final match = _cantos.where((c) => c.cantoNumber == cantoNum);
                  if (match.isNotEmpty) _openCanto(match.first);
                }
              },
              child: Text(
                'Read',
                style: TextStyle(
                  color: AppColors.maroon,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(
            'Could not load cantos',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your internet connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textMedium),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _openCanto(CantoModel canto) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChapterListScreen(canto: canto),
      ),
    );
  }
}

extension on DateTime {
  int get dayOfYear {
    final start = DateTime(year, 1, 1);
    return difference(start).inDays + 1;
  }
}
