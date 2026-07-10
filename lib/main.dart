// ignore_for_file: prefer_const_constructors
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shrimad_bhagavatam/view/home_screen.dart';

import 'theme/app_theme.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAyRwlP7F0EPo3Z-1BK5vJ5Z0V5XWgqPCg",
      appId: "1:121773571719:android:1009432416af4ddc3f0222",
      messagingSenderId: "121773571719",
      projectId: "bhagvat-puran",
      storageBucket: "bhagvat-puran.firebasestorage.app",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: HomeScreen()
    );
  }
}
