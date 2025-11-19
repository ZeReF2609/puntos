import 'package:flutter/material.dart';

/// Extensiones útiles para Context
extension ContextExtensions on BuildContext {
  /// Obtener el tamaño de la pantalla
  Size get screenSize => MediaQuery.of(this).size;

  /// Obtener el ancho de la pantalla
  double get screenWidth => screenSize.width;

  /// Obtener el alto de la pantalla
  double get screenHeight => screenSize.height;

  /// Obtener el tema actual
  ThemeData get theme => Theme.of(this);

  /// Obtener el esquema de colores
  ColorScheme get colorScheme => theme.colorScheme;

  /// Obtener el tema de texto
  TextTheme get textTheme => theme.textTheme;

  /// Navegación
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  /// Mostrar SnackBar
  void showSnackBar(
    String message, {
    Duration? duration,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Mostrar SnackBar de error
  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: colorScheme.error);
  }

  /// Mostrar SnackBar de éxito
  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }

  /// Ocultar el teclado
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}

/// Extensiones para String
extension StringExtensions on String {
  /// Capitalizar primera letra
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Validar si es un email válido
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Validar si es un número
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Truncar texto con ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Ocultar email parcialmente (ej: wil*****@gmail.com)
  String get maskEmail {
    if (!contains('@')) return this;

    final parts = split('@');
    if (parts.length != 2) return this;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 3) {
      return '${username[0]}***@$domain';
    }

    final visibleChars = username.substring(0, 3);
    return '$visibleChars*****@$domain';
  }
}

/// Extensiones para DateTime
extension DateTimeExtensions on DateTime {
  /// Formatear fecha como "dd/MM/yyyy"
  String get formattedDate {
    return '$day/${month.toString().padLeft(2, '0')}/$year';
  }

  /// Formatear fecha y hora como "dd/MM/yyyy HH:mm"
  String get formattedDateTime {
    return '$formattedDate ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Verificar si es hoy
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Verificar si fue ayer
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}
