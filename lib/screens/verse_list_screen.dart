import 'package:flutter/material.dart';
import '../models/chapter_model.dart';
import '../models/verse_model.dart';
import '../services/firestore_service.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../utils/canto_meta.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/verse_preview_card.dart';
import 'verse_reader_screen.dart';

class VerseListScreen extends StatefulWidget {
  final ChapterModel chapter;
  final int cantoNumber;

  const VerseListScreen({
    super.key,
    required this.chapter,
    required this.cantoNumber,
  });

  @override
  State<VerseListScreen> createState() => _VerseListScreenState();
}

class _VerseListScreenState extends State<VerseListScreen> {
  List<VerseModel> _verses = [];
  bool _loading = true;
  bool _error = false;

  final _prefs = PreferencesService.instance;
  final _fs = FirestoreService.instance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final verses = await _fs.getVerses(
        widget.cantoNumber,
        widget.chapter.chapterNumber,
        forceRefresh: refresh,
      );
      if (!mounted) return;
      setState(() {
        _verses = verses;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  String get _language => _prefs.language;

  void _openVerse(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerseReaderScreen(
          verses: _verses,
          initialIndex: index,
          cantoNumber: widget.cantoNumber,
          chapterNumber: widget.chapter.chapterNumber,
        ),
      ),
    ).then((_) => setState(() {})); // refresh bookmark indicators on return
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chNum = widget.chapter.chapterNumber;
    final cantoNum = widget.cantoNumber;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBase : AppColors.cream,
      body: RefreshIndicator(
        color: AppColors.maroon,
        onRefresh: () => _load(refresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 130,
              backgroundColor:
                  isDark ? AppColors.darkBase : AppColors.maroon,
              surfaceTintColor: Colors.transparent,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.maroonDark, AppColors.darkBase]
                          : [AppColors.maroon, const Color(0xFF7A1C1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'CANTO $cantoNum · CHAPTER $chNum',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                              color: AppColors.gold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cantoName(cantoNum),
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'Chapter $chNum',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                collapseMode: CollapseMode.parallax,
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                      _loading
                          ? 'Loading verses…'
                          : '${_verses.length} Verses',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFFF5E8C8)
                            : AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    if (!_loading && _verses.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _openVerse(0),
                        icon: Icon(Icons.play_arrow_rounded,
                            size: 16, color: AppColors.maroon),
                        label: Text(
                          'Read All',
                          style: TextStyle(
                            color: AppColors.maroon,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (_loading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const VersePreviewSkeleton(),
                  childCount: 10,
                ),
              )
            else if (_error)
              SliverToBoxAdapter(child: _buildError())
            else if (_verses.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    'No verses found for this chapter.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMedium),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final verse = _verses[i];
                    final isBookmarked = _prefs.isBookmarked(
                      verse.cantoNumber,
                      verse.chapterNumber,
                      verse.verseNumber,
                    );
                    return VersePreviewCard(
                      verse: verse,
                      language: _language,
                      isBookmarked: isBookmarked,
                      onTap: () => _openVerse(i),
                    );
                  },
                  childCount: _verses.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textLight),
          const SizedBox(height: 12),
          Text('Could not load verses',
              style: TextStyle(fontFamily: 'Georgia', fontSize: 17)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
