import 'package:flutter/material.dart';

/// Paleta e identidad visual del sistema (rojo carnicería Don Chacho).
class AppColors {
  const AppColors._();

  static const Color rojo = Color(0xFF8B1E1E); // rojo carnicería
  static const Color rojoOscuro = Color(0xFF6E1717);
  static const Color crema = Color(0xFFF7F3EE);
  static const Color grisTexto = Color(0xFF2B2B2B);
  static const Color verde = Color(0xFF2E7D32); // ganancias / positivos
  static const Color rojoNegativo = Color(0xFFC62828); // pérdidas / negativos
}

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.rojo,
      primary: AppColors.rojo,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.crema,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.rojo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.white,
        selectedIconTheme: const IconThemeData(color: AppColors.rojo),
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.rojo,
          fontWeight: FontWeight.w600,
        ),
        indicatorColor: AppColors.rojo.withValues(alpha: 0.12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.rojo,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
