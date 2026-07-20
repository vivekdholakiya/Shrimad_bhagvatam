import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// AppHeader — the ONE header used on every screen in the app.
///
/// Per the redesign brief this replaces `AppBar` and `SliverAppBar`
/// everywhere. It lives inside the `Scaffold.body` (not `appBar:`), handles
/// its own `SafeArea`, and is flexible enough to cover every case the old
/// screens used AppBar/SliverAppBar for:
///   - simple title bar (Search, Bookmarks, Settings)
///   - title + subtitle + gradient hero (Home)
///   - back button + title (Chapter List, Verse List)
///   - title + action icons (Search icon, Settings gear, etc.)
///   - optional profile avatar / search field slot
///
/// Usage:
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       AppHeader(title: 'Bookmarks', showBackButton: true),
///       Expanded(child: ...),
///     ],
///   ),
/// )
/// ```
/// or, for a taller hero-style header (see redesigned HomeScreen):
/// ```dart
/// AppHeader.hero(
///   title: 'Shrimad Bhagavatam',
///   subtitle: '॥ सत्यं परम् धीमहि ॥',
///   actions: [...],
/// )
/// ```
class AppHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final Widget? leading;
  final Widget? bottom;
  final bool gradient;
  final bool compact;
  final double heroHeight;

  const AppHeader({
    super.key,
    this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.actions = const [],
    this.leading,
    this.bottom,
    this.gradient = false,
    this.compact = false,
  }) : heroHeight = 0;

  /// Taller variant with a gradient background, for a screen's primary
  /// landing header (e.g. Home). Everything else behaves the same.
  const AppHeader.hero({
    super.key,
    this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.actions = const [],
    this.leading,
    this.bottom,
    this.heroHeight = 172,
  })  : gradient = true,
        compact = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fgOnGradient = Colors.white;
    final fgFlat = isDark ? const Color(0xFFF5E8C8) : AppColors.textDark;
    final fg = gradient ? fgOnGradient : fgFlat;
    final subFg = gradient
        ? Colors.white.withOpacity(0.75)
        : (isDark ? AppColors.textLight : AppColors.textMedium);

    final content = Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        compact ? AppSpacing.sm : AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            gradient ? MainAxisAlignment.end : MainAxisAlignment.center,
        children: [
          Row(
            children: [
              if (leading != null)
                leading!
              else if (showBackButton)
                _HeaderIconButton(
                  icon: Icons.arrow_back_rounded,
                  color: fg,
                  onTap: onBack ?? () => Navigator.of(context).maybePop(),
                ),
              if (showBackButton || leading != null)
                const SizedBox(width: AppSpacing.sm),
              if (title != null)
                Expanded(
                  child: Text(
                    title!,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: compact ? 17 : (gradient ? 22 : 20),
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ...actions,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: gradient ? 13 : 12,
                color: subFg,
                letterSpacing: gradient ? 1.2 : 0.2,
              ),
            ),
          ],
          if (bottom != null) ...[
            const SizedBox(height: AppSpacing.sm),
            bottom!,
          ],
        ],
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: gradient
          ? SystemUiOverlayStyle.light
          : (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark),
      child: Container(
        width: double.infinity,
        constraints: gradient ? BoxConstraints(minHeight: heroHeight) : null,
        decoration: gradient
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [AppColors.maroonDark, AppColors.darkBase]
                      : [AppColors.maroon, const Color(0xFF8B2020)],
                ),
              )
            : BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.warmWhite,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    width: 0.8,
                  ),
                ),
              ),
        child: SafeArea(bottom: false, child: content),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
