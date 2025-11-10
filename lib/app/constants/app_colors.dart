import 'package:flutter/material.dart';

class AppColors {
  // Paleta de colores neutros para multi-marca
  static const Color primary = Color(0xFF212121); // Negro principal
  static const Color primaryLight = Color(0xFF484848); // Gris oscuro
  static const Color primaryDark = Color(0xFF000000); // Negro puro

  static const Color secondary = Color(0xFF757575); // Gris medio
  static const Color secondaryLight = Color(0xFFA4A4A4); // Gris claro
  static const Color secondaryDark = Color(0xFF494949); // Gris oscuro

  static const Color accent = Color(0xFF1976D2); // Azul para acentos
  static const Color accentLight = Color(0xFF63A4FF); // Azul claro
  static const Color accentDark = Color(0xFF004BA0); // Azul oscuro

  // Colores de superficie y fondo
  static const Color background = Color(0xFFFAFAFA); // Gris muy claro
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Colores de texto
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF212121);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  static const Color danger = Color(0xFFFF4C4C);

  static const Color themeBgMenu = Color(0xFF383C48);
  static const Color themeBgMenuHover = Color(0xFF53596C);
  // Grises del sistema
  static const Color themeGray = Color(0xFFCACACA);
  static const Color themeGrayDark = Color(0xFF58595C);
  static const Color themeBlack = Color(0xFF212121);

  // Bordes y dividers
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);

  // Gradientes neutros
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, surfaceVariant],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Compatibilidad con nombres anteriores
  static const Color themeColor1 = primary;
  static const Color themeColor2 = textPrimary;
  static const Color themeColor3 = textSecondary;
  static const Color themeGrayLight = background;
  static const Color themeLightBorder = border;
  static const Color themeBgVitrina = surfaceVariant;
  static const Color textColorLight = textSecondary;
}
