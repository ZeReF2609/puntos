import '../constants/app_constants.dart';

/// Validadores para formularios
class Validators {
  // Prevenir instanciación
  Validators._();

  /// Validar email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }

    return null;
  }

  /// Validar password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'La contraseña no debe exceder ${AppConstants.maxPasswordLength} caracteres';
    }

    return null;
  }

  /// Validar que las contraseñas coincidan
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (value != password) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  /// Validar nombre
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }

    if (value.length < AppConstants.minNameLength) {
      return 'El nombre debe tener al menos ${AppConstants.minNameLength} caracteres';
    }

    if (value.length > AppConstants.maxNameLength) {
      return 'El nombre no debe exceder ${AppConstants.maxNameLength} caracteres';
    }

    return null;
  }

  /// Validar campo requerido
  static String? required(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  /// Validar longitud mínima
  static String? minLength(String? value, int min, {String fieldName = 'Este campo'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }

    if (value.length < min) {
      return '$fieldName debe tener al menos $min caracteres';
    }

    return null;
  }

  /// Validar longitud máxima
  static String? maxLength(String? value, int max, {String fieldName = 'Este campo'}) {
    if (value != null && value.length > max) {
      return '$fieldName no debe exceder $max caracteres';
    }
    return null;
  }

  /// Validar número de teléfono
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'El número de teléfono es requerido';
    }

    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Ingresa un número de teléfono válido';
    }

    return null;
  }
}
