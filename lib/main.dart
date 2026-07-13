import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/cache_service.dart';
import 'services/preferences_service.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for optimal reading experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Firebase ────────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAyRwlP7F0EPo3Z-1BK5vJ5Z0V5XWgqPCg",
      appId: "1:121773571719:android:1009432416af4ddc3f0222",
      messagingSenderId: "121773571719",
      projectId: "bhagvat-puran",
      storageBucket: "bhagvat-puran.firebasestorage.app",
    ),
  );

  // ── Local Services (must init before runApp) ────────────────────
  await CacheService.instance.init();
  await PreferencesService.instance.init();

  runApp(const BhagavatamApp());
}

class BhagavatamApp extends StatefulWidget {
  const BhagavatamApp({super.key});

  @override
  State<BhagavatamApp> createState() => _BhagavatamAppState();
}

class _BhagavatamAppState extends State<BhagavatamApp> {
  bool get _isDark => PreferencesService.instance.isDarkMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrimad Bhagavatam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      builder: (context, child) {
        // Global text scaling cap so very large system fonts don't break layout
        final scale = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.85, 1.2);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
          ),
          child: child!,
        );
      },
    );
  }
}
