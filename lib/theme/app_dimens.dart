import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppDimens — single source of truth for spacing, radius, shadows and
/// motion timing. Replaces hardcoded numbers (EdgeInsets.all(16),
/// BorderRadius.circular(20), etc.) scattered across screens/widgets.
///
/// Why this matters:
///   - Consistency: every card, button, and gap uses the same scale
///     instead of ad-hoc values that drift over time (16 vs 18 vs 20).
///   - Maintainability: one place to tune the "premium/spacious" feel
///     instead of hunting through 8+ screen files.
///   - Cheaper builds: shadow/border objects below are `static const`
///     where possible, so widgets that reuse them don't reallocate.
class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  AppRadius._();
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const pill = 999.0;

  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
}

class AppMotion {
  AppMotion._();
  static const fast = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 500);
  static const pageTransition = Duration(milliseconds: 380);

  static const easeOut = Curves.easeOutCubic;
  static const easeInOut = Curves.easeInOutCubic;
}

class AppShadows {
  AppShadows._();

  /// Soft, low-elevation shadow for cards on light/cream backgrounds.
  static List<BoxShadow> soft({bool isDark = false}) => [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.35) : AppColors.shadow,
          blurRadius: 18,
          offset: const Offset(0, 6),
          spreadRadius: -4,
        ),
      ];

  /// Gold-tinted glow used sparingly for highlighted / featured elements
  /// (e.g. "Continue Reading" card, active nav item).
  static List<BoxShadow> goldGlow() => [
        BoxShadow(
          color: AppColors.shadowGold,
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -6,
        ),
      ];
}
