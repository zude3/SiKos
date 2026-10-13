import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const SikosApp());
}

class SikosApp extends StatelessWidget {
  const SikosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sikos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488)),
        scaffoldBackgroundColor: const Color(0xFFF7FBFB),
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
