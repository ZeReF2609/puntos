import 'package:flutter/foundation.dart';

/// Configuración de entorno
/// Maneja diferentes URLs según la plataforma y el entorno
class Environment {
  Environment._();

  /// Obtener la URL base según la plataforma
  static String get baseUrl {
    // Usar la IP de la red local para todas las plataformas en desarrollo
    if (kDebugMode) {
      return 'http://191.98.147.53:8383';
    }

    // En producción, usa tu URL de producción
    return 'http://191.98.147.53:8383';
  }

  /// URL base alternativa para dispositivos físicos
  /// Reemplaza con tu IP local cuando pruebes en un dispositivo físico
  static const String localIpUrl = 'http://191.98.147.53:8383';

  /// Usar IP local en lugar de localhost/10.0.2.2
  static bool useLocalIp = false;

  /// Obtener la URL completa con versión de API
  static String get apiUrl {
    final base = useLocalIp ? localIpUrl : baseUrl;
    return '$base/api/v1';
  }

  /// Verificar si estamos en modo desarrollo
  static bool get isDevelopment => kDebugMode;

  /// Verificar si estamos en modo producción
  static bool get isProduction => !kDebugMode;

  /// Timeout de conexión en milisegundos
  static const int connectionTimeout = 30000;

  /// Timeout de recepción en milisegundos
  static const int receiveTimeout = 30000;
}
