import 'package:flutter/material.dart';
import '../models/canto_model.dart';
import '../theme/app_colors.dart';
import '../utils/canto_meta.dart';

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

    final totalChapters =
    (index >= 0 && index < cantoMeta.length)
        ? (cantoMeta[index]['chapters'] as int? ?? 0)
        : 0;


    final progress = (readChapters != null && totalChapters > 0)
        ? (readChapters! / totalChapters).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppColors.borderDark
                : AppColors.border,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // ── Top accent stripe ──────────────────────────
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.maroon.withOpacity(0.7),
                      AppColors.gold,
                      AppColors.saffron.withOpacity(0.7),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Symbol badge
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [AppColors.darkElevated, AppColors.darkSurface]
                                  : [AppColors.cream, AppColors.warmWhite],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.gold.withOpacity(0.4),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              symbol,
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Canto ${canto.cantoNumber}',
                                style: TextStyle(
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
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.textMedium,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    if (progress > 0) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: isDark
                                    ? AppColors.darkElevated
                                    : AppColors.border,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.gold,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
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
      ),
    );
  }
}
