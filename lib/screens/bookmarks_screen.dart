import 'package:flutter/material.dart';
import '../models/verse_model.dart';
import '../services/firestore_service.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import 'verse_reader_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final _prefs = PreferencesService.instance;
  final _fs = FirestoreService.instance;

  List<VerseModel> _bookmarkedVerses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final bookmarkKeys = _prefs.bookmarks; // ["1_2_3", ...]
    final result = <VerseModel>[];

    for (final key in bookmarkKeys) {
      final parts = key.split('_');
      if (parts.length != 3) continue;
      final canto = int.tryParse(parts[0]);
      final chapter = int.tryParse(parts[1]);
      final verse = int.tryParse(parts[2]);
      if (canto == null || chapter == null || verse == null) continue;

      try {
        final v = await _fs.getVerse(canto, chapter, verse);
        if (v != null) result.add(v);
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _bookmarkedVerses = result;
      _loading = false;
    });
  }

  Future<void> _removeBookmark(VerseModel verse) async {
    await _prefs.removeBookmark(
        verse.cantoNumber, verse.chapterNumber, verse.verseNumber);
    setState(() => _bookmarkedVerses.remove(verse));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBase : AppColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: isDark ? AppColors.darkBase : AppColors.maroon,
            surfaceTintColor: Colors.transparent,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: const Text(
              'Bookmarks',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            actions: [
              if (!_loading && _bookmarkedVerses.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: _load,
                  tooltip: 'Refresh',
                ),
            ],
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.maroon),
              ),
            )
          else if (_bookmarkedVerses.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(isDark),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _buildBookmarkTile(_bookmarkedVerses[i], isDark),
                childCount: _bookmarkedVerses.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookmarkTile(VerseModel verse, bool isDark) {
    final lang = _prefs.language;
    final translation = verse.translation(lang);
    final preview =
        translation.length > 100 ? '${translation.substring(0, 100)}…' : translation;

    return Dismissible(
      key: Key('bookmark_${verse.fullRef}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeBookmark(verse),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTap: () async {
          final verses = await _fs.getVerses(verse.cantoNumber, verse.chapterNumber);
          if (!mounted) return;
          final idx = verses.indexWhere((v) => v.verseNumber == verse.verseNumber);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerseReaderScreen(
                verses: verses,
                initialIndex: idx.clamp(0, verses.length - 1),
                cantoNumber: verse.cantoNumber,
                chapterNumber: verse.chapterNumber,
              ),
            ),
          ).then((_) => _load());
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.cardLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.gold.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.bookmark_rounded,
                  color: AppColors.gold, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      verse.fullRef,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                        color: AppColors.gold,
                      ),
                    ),
                    if (verse.devanagari != null &&
                        verse.devanagari!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        verse.devanagari!.split('\n').first,
                        style: TextStyle(
                          fontFamily: 'NotoSerifDevanagari',
                          fontSize: 13,
                          color: isDark
                              ? AppColors.goldLight
                              : AppColors.maroon,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (preview.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        preview,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFFD4B896)
                              : AppColors.textMedium,
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_outline_rounded,
              size: 64,
              color: isDark ? AppColors.textLight : AppColors.border),
          const SizedBox(height: 16),
          Text(
            'No Bookmarks Yet',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFF5E8C8) : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the bookmark icon while reading\nto save your favourite verses.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textLight : AppColors.textMedium,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
