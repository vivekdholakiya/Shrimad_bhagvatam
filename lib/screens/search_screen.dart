import 'package:flutter/material.dart';
import '../models/verse_model.dart';
import '../services/firestore_service.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import 'verse_reader_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<VerseModel> _results = [];
  bool _searched = false;
  final _fs = FirestoreService.instance;
  final _prefs = PreferencesService.instance;

  void _search(String query) {
    final results = _fs.searchCachedVerses(query);
    setState(() {
      _results = results;
      _searched = true;
    });
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _results = [];
      _searched = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = _prefs.language;

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
              'Search',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.warmWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        onSubmitted: _search,
                        onChanged: (v) {
                          if (v.isEmpty) _clear();
                        },
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFF5E8C8)
                              : AppColors.textDark,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search across cached verses…',
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.textLight : AppColors.textMedium,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: isDark ? AppColors.textLight : AppColors.maroon,
                          ),
                          suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close_rounded,
                                      color: AppColors.textLight, size: 18),
                                  onPressed: _clear,
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _search(_controller.text),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.maroon,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.search_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Hint
          if (!_searched)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.manage_search_rounded,
                      size: 60,
                      color: isDark ? AppColors.textLight : AppColors.border,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Search Cached Verses',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFFF5E8C8)
                            : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Search works across all verses you have already opened. The more you read, the more you can search!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textLight : AppColors.textMedium,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )

          // Results
          else if (_results.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'No results found.\nTry a different keyword.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textLight : AppColors.textMedium,
                    height: 1.5,
                  ),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  '${_results.length} result${_results.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textLight : AppColors.textMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _buildResultTile(_results[i], lang, isDark),
                childCount: _results.length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildResultTile(VerseModel verse, String lang, bool isDark) {
    final translation = verse.translation(lang);
    final preview = translation.length > 100
        ? '${translation.substring(0, 100)}…'
        : translation;

    return GestureDetector(
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
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
        ),
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
            const SizedBox(height: 4),
            if (verse.devanagari != null && verse.devanagari!.isNotEmpty)
              Text(
                verse.devanagari!.split('\n').first,
                style: TextStyle(
                  fontFamily: 'NotoSerifDevanagari',
                  fontSize: 13,
                  color: isDark ? AppColors.goldLight : AppColors.maroon,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                preview,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFFD4B896) : AppColors.textMedium,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
