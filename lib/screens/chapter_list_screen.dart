import 'package:flutter/material.dart';
import '../models/canto_model.dart';
import '../models/chapter_model.dart';
import '../services/firestore_service.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../utils/canto_meta.dart';
import '../widgets/loading_skeleton.dart';
import 'verse_list_screen.dart';

class ChapterListScreen extends StatefulWidget {
  final CantoModel canto;

  const ChapterListScreen({super.key, required this.canto});

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen> {
  List<ChapterModel> _chapters = [];
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
      final chapters = await _fs.getChapters(
        widget.canto.cantoNumber,
        forceRefresh: refresh,
      );
      if (!mounted) return;
      setState(() {
        _chapters = chapters;
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cantoNum = widget.canto.cantoNumber;
    final symbol = cantoSymbol(cantoNum);
    final name = cantoName(cantoNum);
    final description = cantoDescription(cantoNum);
    final lastCanto = _prefs.lastCanto;
    final lastChapter = _prefs.lastChapter;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBase : AppColors.cream,
      body: RefreshIndicator(
        color: AppColors.maroon,
        onRefresh: () => _load(refresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── App Bar ─────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
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
                          Row(
                            children: [
                              Text(symbol,
                                  style: const TextStyle(fontSize: 32)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CANTO $cantoNum',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2.0,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.65),
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'Canto $cantoNum',
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

            // ── Section Header ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 20, 16, 8),
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
                          ? 'Loading chapters…'
                          : '${_chapters.length} Chapters',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 17,
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

            // ── Content ───────────────────────────────────────────
            if (_loading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    child: SkeletonLoader(height: 72, borderRadius: 14),
                  ),
                  childCount: 8,
                ),
              )
            else if (_error)
              SliverToBoxAdapter(child: _buildError())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final ch = _chapters[i];
                    final isLastRead = lastCanto == cantoNum &&
                        lastChapter == ch.chapterNumber;
                    return _buildChapterTile(ch, i, isLastRead, isDark);
                  },
                  childCount: _chapters.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterTile(
      ChapterModel chapter, int index, bool isLastRead, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerseListScreen(
            chapter: chapter,
            cantoNumber: widget.canto.cantoNumber,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLastRead
                ? AppColors.gold.withOpacity(0.6)
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isLastRead ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLastRead
                    ? AppColors.maroon
                    : (isDark
                        ? AppColors.darkElevated
                        : AppColors.maroon.withOpacity(0.08)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${chapter.chapterNumber}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isLastRead
                        ? Colors.white
                        : (isDark ? AppColors.goldLight : AppColors.maroon),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapter ${chapter.chapterNumber}',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFFF5E8C8)
                          : AppColors.textDark,
                    ),
                  ),
                  if (chapter.title != null && chapter.title!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      chapter.title!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.textMedium,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (isLastRead)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.bookmark_rounded,
                              size: 11, color: AppColors.gold),
                          const SizedBox(width: 3),
                          Text(
                            'Last read',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.gold),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppColors.textLight : AppColors.textMedium,
              size: 20,
            ),
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
          Text(
            'Could not load chapters',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 17,
              color: AppColors.textDark,
            ),
          ),
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
