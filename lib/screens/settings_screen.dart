import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefs = PreferencesService.instance;

  late String _language;
  late double _fontSize;
  late ReadingTheme _readingTheme;
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _language = _prefs.language;
    _fontSize = _prefs.fontSize;
    _readingTheme = _prefs.readingTheme;
    _isDarkMode = _prefs.isDarkMode;
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
              'Settings',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Reading Language',
                isDark,
                children: [
                  _buildLanguageOption('English', 'en', isDark),
                  _buildLanguageOption('हिन्दी (Hindi)', 'hi', isDark),
                  _buildLanguageOption('ગુજરાતી (Gujarati)', 'gu', isDark),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Font Size',
                isDark,
                children: [
                  _buildFontSizeSlider(isDark),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Reading Theme',
                isDark,
                children: [
                  _buildThemeOption('Light', ReadingTheme.light, '☀️', isDark),
                  _buildThemeOption('Dark', ReadingTheme.dark, '🌙', isDark),
                  _buildThemeOption('Sepia', ReadingTheme.sepia, '☕', isDark),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                'App Theme',
                isDark,
                children: [
                  _buildSwitchTile(
                    'Dark Mode',
                    'Use the dark color scheme across the app',
                    Icons.dark_mode_rounded,
                    _isDarkMode,
                    isDark,
                    (val) async {
                      await _prefs.setDarkMode(val);
                      setState(() => _isDarkMode = val);
                      // Notify parent to rebuild
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Restart the app to apply theme changes.'),
                            backgroundColor: AppColors.maroon,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                'About',
                isDark,
                children: [
                  _buildInfoTile('App Version', '1.0.0', Icons.info_outline_rounded, isDark),
                  _buildInfoTile(
                    'Data Source',
                    'Cloud Firestore (Read-only)',
                    Icons.cloud_rounded,
                    isDark,
                  ),
                  _buildInfoTile(
                    'Scripture',
                    'Śrīmad-Bhāgavatam by A.C. Bhaktivedanta Swami Prabhupāda',
                    Icons.menu_book_rounded,
                    isDark,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Mantra footer
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '॥ सत्यं परम् धीमहि ॥',
                    style: TextStyle(
                      fontFamily: 'NotoSerifDevanagari',
                      fontSize: 14,
                      color: isDark
                          ? AppColors.gold.withOpacity(0.4)
                          : AppColors.textLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    bool isDark, {
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
              color: AppColors.gold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.cardLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 1,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(String label, String code, bool isDark) {
    final selected = _language == code;
    return GestureDetector(
      onTap: () {
        setState(() => _language = code);
        _prefs.setLanguage(code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected
                      ? (isDark ? AppColors.goldLight : AppColors.maroon)
                      : (isDark
                          ? const Color(0xFFF5E8C8)
                          : AppColors.textDark),
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: isDark ? AppColors.goldLight : AppColors.maroon,
                  size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSlider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Aa',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textLight : AppColors.textMedium,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 12,
                  max: 24,
                  divisions: 6,
                  activeColor: AppColors.maroon,
                  inactiveColor: isDark
                      ? AppColors.darkElevated
                      : AppColors.border,
                  onChanged: (val) {
                    setState(() => _fontSize = val);
                    _prefs.setFontSize(val);
                  },
                ),
              ),
              Text(
                'Aa',
                style: TextStyle(
                  fontSize: 20,
                  color: isDark ? AppColors.textLight : AppColors.textMedium,
                ),
              ),
            ],
          ),
          Center(
            child: Text(
              '${_fontSize.toInt()}pt',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textLight : AppColors.textMedium,
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
      String label, ReadingTheme theme, String emoji, bool isDark) {
    final selected = _readingTheme == theme;
    return GestureDetector(
      onTap: () {
        setState(() => _readingTheme = theme);
        _prefs.setReadingTheme(theme);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected
                      ? (isDark ? AppColors.goldLight : AppColors.maroon)
                      : (isDark
                          ? const Color(0xFFF5E8C8)
                          : AppColors.textDark),
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: isDark ? AppColors.goldLight : AppColors.maroon,
                  size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    bool isDark,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.maroon.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.maroon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFF5E8C8)
                        : AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textLight : AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.maroon,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      String title, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.maroon.withOpacity(isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.maroon, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFF5E8C8)
                        : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textLight : AppColors.textMedium,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
