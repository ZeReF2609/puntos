import 'dart:io';
import 'package:flutter/foundation.dart';

class LoginRequest {
  final String usuario;
  final String password;
  final String dispositivo;
  final String version;

  LoginRequest({
    required this.usuario,
    required this.password,
    required this.dispositivo,
    required this.version,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario,
      'password': password,
      'dispositivo': dispositivo,
      'version': version,
    };
  }

  /// Detectar automáticamente el tipo de dispositivo
  static String detectDeviceType() {
    if (kIsWeb) {
      return 'Web Browser';
    } else if (Platform.isWindows) {
      return 'Windows Desktop';
    } else if (Platform.isAndroid) {
      return 'Android Mobile';
    } else if (Platform.isIOS) {
      return 'iOS Mobile';
    } else if (Platform.isMacOS) {
      return 'macOS Desktop';
    } else if (Platform.isLinux) {
      return 'Linux Desktop';
    } else {
      return 'Unknown Device';
    }
  }
}

class LogoutRequest {
  final String refreshToken;

  LogoutRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'RefreshToken': refreshToken};
  }
}

class LogoutResponse {
  final bool success;
  final String message;

  LogoutResponse({required this.success, required this.message});

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      success: json['Success'] ?? json['success'] ?? false,
      message: json['Message'] ?? json['message'] ?? '',
    );
  }
}
