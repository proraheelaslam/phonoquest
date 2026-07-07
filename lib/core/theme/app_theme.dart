import 'package:flutter/material.dart';

class AppTheme {
  static const ink = Color(0xFF111111);
  static const body = Color(0xFF5B5B5B);
  static const softGrey = Color(0xFFF2F2F2);
  static const mint = Color(0xFF62D2CF);
  static const pink = Color(0xFFF47495);
  static const yellow = Color(0xFFF1C574);
  static const blue = Color(0xFF0A63D8);
  static const pageBg = Color(0xFFF7F5F0);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: pageBg,
      colorScheme: ColorScheme.fromSeed(seedColor: mint, surface: pageBg),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink, height: 1.2),
        bodyMedium: TextStyle(fontSize: 13, color: body, height: 1.4),
      ),
    );
  }
}
