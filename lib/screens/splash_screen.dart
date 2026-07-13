import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/preferences_service.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _textFadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _textFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2800), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final onboardingDone = PreferencesService.instance.onboardingDone;
    Widget next =
        onboardingDone ? const HomeScreen() : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.maroonDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.maroonDark,
              Color(0xFF3D0E0E),
              AppColors.maroonDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Logo / Symbol ──────────────────────────
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.gold.withOpacity(0.25),
                                AppColors.gold.withOpacity(0.05),
                                Colors.transparent,
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.gold.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '🪷',
                              style: TextStyle(fontSize: 54),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Sanskrit Title ─────────────────────────
                    FadeTransition(
                      opacity: _textFadeAnim,
                      child: Text(
                        'श्रीमद्भागवतम्',
                        style: GoogleFonts.notoSerifDevanagari(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldLight,
                          letterSpacing: 0.5,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── English Title ──────────────────────────
                    FadeTransition(
                      opacity: _textFadeAnim,
                      child: Text(
                        'Shrimad Bhagavatam',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: AppColors.gold.withOpacity(0.8),
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ── Mantra ─────────────────────────────────
                    FadeTransition(
                      opacity: _textFadeAnim,
                      child: Text(
                        '॥ सत्यं परम् धीमहि ॥',
                        style: GoogleFonts.notoSerifDevanagari(
                          fontSize: 14,
                          color: AppColors.gold.withOpacity(0.5),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
