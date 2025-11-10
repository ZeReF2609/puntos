import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Configuración de bordes redondeados
  static const double borderRadiusBtn = 8.0;
  static const double borderRadiusInput = 15.0;
  static const double borderRadiusBox = 8.0;

  // Tema principal de la aplicación
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Esquema de colores personalizado
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.themeColor2,
        onSecondary: AppColors.onSecondary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        error: AppColors.danger,
        onError: Colors.white,
      ),

      // Color de fondo del scaffold
      scaffoldBackgroundColor: AppColors.background,

      // Configuración del AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.themeColor2,
        foregroundColor: AppColors.themeColor1,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.themeColor1,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Configuración de botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusBtn),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Configuración de botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusBtn),
          ),
        ),
      ),

      // Configuración de botones outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusBtn),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Configuración de campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusInput),
          borderSide: const BorderSide(color: AppColors.themeLightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusInput),
          borderSide: const BorderSide(color: AppColors.themeLightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusInput),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusInput),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusInput),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: AppColors.themeColor3),
        labelStyle: const TextStyle(color: AppColors.textColorLight),
      ),

      // Configuración de tarjetas
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusBox),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Configuración del tema de iconos
      iconTheme: const IconThemeData(color: AppColors.themeColor2, size: 24),

      // Configuración de la barra de navegación inferior
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.themeBgMenu,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.themeGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Configuración del drawer
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(borderRadiusBox),
            bottomRight: Radius.circular(borderRadiusBox),
          ),
        ),
      ),

      // Configuración de diálogos
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusBox),
        ),
        elevation: 8,
      ),

      // Configuración de texto
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.themeColor2,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: AppColors.themeColor2,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: AppColors.themeColor2,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: AppColors.themeColor2,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: AppColors.themeColor2,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: AppColors.themeColor2,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.themeColor2,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: AppColors.textColorLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: AppColors.textColorLight,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: AppColors.textColorLight, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.textColorLight, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.themeColor3, fontSize: 12),
        labelLarge: TextStyle(
          color: AppColors.themeColor2,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: AppColors.textColorLight,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: AppColors.themeColor3,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Configuración de divisores
      dividerTheme: const DividerThemeData(
        color: AppColors.themeLightBorder,
        thickness: 1,
        space: 1,
      ),

      // Configuración de chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.themeGrayLight,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.themeGray,
        labelStyle: const TextStyle(color: AppColors.textColorLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusBtn),
        ),
      ),
    );
  }

  // Tema oscuro (opcional)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.themeColor2,
        secondary: AppColors.themeColor1,
        onSecondary: AppColors.themeColor2,
        surface: AppColors.themeBgMenu,
        onSurface: AppColors.themeGrayLight,
        error: AppColors.danger,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.themeColor2,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.themeBgMenu,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
