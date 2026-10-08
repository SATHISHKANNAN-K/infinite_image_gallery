import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: Colors.indigo,
      scaffoldBackgroundColor: const Color(0xfff7f8fc),
      cardTheme: const CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.indigo,
      cardTheme: const CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
