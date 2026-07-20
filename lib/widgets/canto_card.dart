import 'package:flutter/material.dart';
import '../models/canto_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../utils/canto_meta.dart';
import 'ui_kit.dart';

/// CantoCard — unchanged data/behavior, rebuilt on top of [AppCard] so its
/// shadow, radius, and border now match every other card in the app
/// (previously this had its own one-off Container/BoxDecoration, subtly
/// different from the home screen's continue-reading/daily-verse cards).
class CantoCard extends StatelessWidget {
  final CantoModel canto;
  final int? readChapters;
  final VoidCallback onTap;

  const CantoCard({
    super.key,
    required this.canto,
    this.readChapters,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final symbol = cantoSymbol(canto.cantoNumber);
    final name = cantoName(canto.cantoNumber);
    final description = cantoDescription(canto.cantoNumber);
    final index = canto.cantoNumber - 1;

    final totalChapters = (index >= 0 && index < cantoMeta.length)
        ? (cantoMeta[index]['chapters'] as int? ?? 0)
        : 0;

    final progress = (readChapters != null && totalChapters > 0)
        ? (readChapters! / totalChapters).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 7),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Column(
          children: [
            // ── Top accent stripe ──────────────────────────
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xB36B1A1A), // maroon @ 70%
                    AppColors.gold,
                    Color(0xB3E8832A), // saffron @ 70%
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppAvatar(
                        symbol: symbol,
                        size: 52,
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppColors.darkElevated, AppColors.darkSurface]
                              : [AppColors.cream, AppColors.warmWhite],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Canto ${canto.cantoNumber}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontFamily: 'Georgia',
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  size: 12,
                                  color: isDark
                                      ? AppColors.textLight
                                      : AppColors.textMedium,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$totalChapters Chapters',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textLight
                                        : AppColors.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.gold.withOpacity(0.7),
                        size: 20,
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? AppColors.textLight : AppColors.textMedium,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (progress > 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor:
                              isDark ? AppColors.darkElevated : AppColors.border,
                              valueColor:
                              const AlwaysStoppedAnimation<Color>(AppColors.gold),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}