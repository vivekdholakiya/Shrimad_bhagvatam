import 'package:flutter/material.dart';
import '../models/verse_model.dart';
import '../theme/app_colors.dart';

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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.transparent : AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
                      : [AppColors.maroon.withOpacity(0.12), AppColors.maroon.withOpacity(0.06)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (verse.devanagari != null && verse.devanagari!.isNotEmpty)
                    Text(
                      verse.devanagari!.split('\n').first,
                      style: TextStyle(
                        fontFamily: 'NotoSerifDevanagari',
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
            const SizedBox(width: 8),
            if (isBookmarked)
              Icon(
                Icons.bookmark_rounded,
                size: 16,
                color: AppColors.gold,
              ),
          ],
        ),
      ),
    );
  }
}
