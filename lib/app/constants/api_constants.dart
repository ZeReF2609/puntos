import 'package:flutter/foundation.dart';

class ApiConstants {
  // ============ CONFIGURACIÓN DE RED ============

  // Debug (ambiente pruebas)
  static const String debugIP = '10.80.41.179';
  static const String debugPort = '8383';

  // Release (ambiente producción)
  //static const String releaseIP = '10.80.100.51/';

  /// URL base del servidor API
  static String get baseUrl {
    // if (kDebugMode) {
    //   // 👉 Cuando corres en debug
    //   return 'http://$debugIP:$debugPort/api';
    // } else {
    //   // 👉 Cuando corres en release
    //   return 'http://$releaseIP/api';
    // }
    return 'http://$debugIP:$debugPort/api';
  }

  // ============ ENDPOINTS DE LA API ============

  // Endpoints de autenticación
  static const String loginEndpoint = '/auth/login';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';
  static const String versionEndpoint = '/auth/version';
  static const String getPermissionsEndpoint = '/auth/getpermiss';

  // ============ CONFIGURACIÓN DE TIMEOUTS ============

  static const int connectTimeout = 15000; // 15 segundos
  static const int receiveTimeout = 30000; // 30 segundos
  static const int sendTimeout = 15000; // 15 segundos

  // ============ HEADERS COMUNES ============

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ============ CONFIGURACIÓN DE RED AVANZADA ============

  /// Información de configuración
  static Map<String, dynamic> get networkConfig => {
    'baseUrl': baseUrl,
    'connectTimeout': connectTimeout,
    'receiveTimeout': receiveTimeout,
    'sendTimeout': sendTimeout,
  };
}
