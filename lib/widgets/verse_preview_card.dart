import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/verse_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'ui_kit.dart';

class VersePreviewCard extends StatelessWidget {
  final VerseModel verse;
  final String language;
  final bool isBookmarked;
  final VoidCallback onTap;

  const VersePreviewCard({
    super.key,
    required this.verse,
    required this.language,
    this.isBookmarked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preview = verse.translation(language);
    final previewText =
    preview.length > 120 ? '${preview.substring(0, 120)}…' : preview;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5),
      child: AppCard(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verse number badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.maroonDark, AppColors.maroon]
                      : [
                    AppColors.maroon.withOpacity(0.12),
                    AppColors.maroon.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.smRadius,
                border: Border.all(
                  color: AppColors.maroon.withOpacity(isDark ? 0.5 : 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '${verse.verseNumber}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.goldLight : AppColors.maroon,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (verse.devanagari != null && verse.devanagari!.isNotEmpty)
                    Text(
                      verse.devanagari!.split('\n').first,
                      // Bug fix: this previously used
                      // `fontFamily: 'NotoSerifDevanagari'` as a raw string.
                      // That font was never registered in pubspec.yaml's
                      // `fonts:` section, so Flutter silently fell back to
                      // the default font — Devanagari glyphs likely still
                      // rendered (via system fallback) but without the
                      // intended serif styling used everywhere else in the
                      // app via GoogleFonts.notoSerifDevanagari(...).
                      style: GoogleFonts.notoSerifDevanagari(
                        fontSize: 13,
                        color: isDark ? AppColors.goldLight : AppColors.maroon,
                        height: 1.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (previewText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      previewText,
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
            const SizedBox(width: AppSpacing.sm),
            if (isBookmarked)
              const Icon(Icons.bookmark_rounded, size: 16, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}