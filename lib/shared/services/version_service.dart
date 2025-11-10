import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'device_info_service.dart';
import 'api_service.dart';
import '../models/version_request.dart';
import '../../app/constants/api_constants.dart';

class VersionService {
  static final VersionService _instance = VersionService._internal();
  factory VersionService() => _instance;
  VersionService._internal();

  final _secureStorage = const FlutterSecureStorage();
  final _apiService = ApiService();

  /// Verificar si la plataforma actual soporta actualizaciones
  bool _shouldCheckForUpdates() {
    if (kIsWeb) {
      // Web no necesita verificación de actualizaciones
      return false;
    }

    // Solo verificar en Android y Windows
    try {
      final isSupported = Platform.isAndroid || Platform.isWindows;
      return isSupported;
    } catch (e) {
      debugPrint('❌ Error determinando plataforma: $e');
      // Si no se puede determinar la plataforma, no verificar
      return false;
    }
  }

  /// Verificar versión llamando a la API
  Future<int> checkVersionFromApi() async {
    try {
      debugPrint('🔍 Iniciando verificación de versión desde API...');

      // Obtener información del dispositivo y versión
      final deviceInfo = await DeviceInfoService.getDeviceInfo();
      final packageInfo = await PackageInfo.fromPlatform();

      // Crear el objeto de request
      final versionRequest = VersionRequest(
        dispositivo: deviceInfo['deviceType'] ?? 'Unknown',
        version: packageInfo.version,
      );

      // Hacer la llamada a la API
      final response = await _apiService.post(
        ApiConstants.versionEndpoint,
        data: versionRequest.toJson(),
      );

      debugPrint(
        '📡 Respuesta de API versión - Status: ${response.statusCode}',
      );
      debugPrint('📡 Respuesta de API versión - Data: ${response.data}');

      // La API devuelve:
      // - Status 200: No necesita actualización
      // - Status 400: Necesita actualización con {"estadO_VERSION": 1}
      if (response.statusCode == 200) {
        debugPrint('✅ Versión OK - No necesita actualización');
        return 0;
      } else if (response.statusCode == 400) {
        // Status 400 significa que necesita actualización
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('estadO_VERSION')) {
          final versionStatus = responseData['estadO_VERSION'] as int;
          debugPrint('⚠️ Versión desactualizada - Status: $versionStatus');
          return versionStatus;
        }
        // Si no tiene el campo esperado, asumir que necesita actualización
        debugPrint(
          '⚠️ Respuesta inesperada de versión - asumiendo actualización necesaria',
        );
        return 1;
      } else {
        debugPrint(
          '❌ Status code inesperado: ${response.statusCode} - permitiendo continuar',
        );
        return 0; // En caso de error inesperado, permitir continuar
      }
    } catch (e) {
      debugPrint('❌ Error verificando versión desde API: $e');
      return 0; // En caso de error, permitir continuar
    }
  }

  /// Cargar estado de versión desde storage local (método existente)
  Future<int> checkVersionFromStorage() async {
    String? jsonString;

    if (kIsWeb) {
      // WEB: usar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      jsonString = prefs.getString('secure_complete_login_data');
    } else {
      // ANDROID/WINDOWS/Linux/iOS: usar FlutterSecureStorage
      jsonString = await _secureStorage.read(key: 'complete_login_data');
    }

    if (jsonString != null) {
      try {
        final data = jsonDecode(jsonString);
        return data['estado_version'] as int? ?? 0;
      } catch (e) {
        return 0; // En caso de error, retornar 0 (no necesita actualización)
      }
    }

    return 0;
  }

  /// Verificar versión - Solo usa la API para validar si necesita actualización
  Future<int> checkVersion() async {
    try {

      // Verificar si la plataforma soporta actualizaciones
      if (!_shouldCheckForUpdates()) {
        return 0;
      }


      // Solo verificar desde la API para Android y Windows
      final result = await checkVersionFromApi();
      return result;
    } catch (e) {
      debugPrint('❌ Error en checkVersion: $e');
      // En caso de error, no bloquear al usuario
      return 0;
    }
  }

  /// Verificar si se debe mostrar el diálogo de actualización
  Future<bool> shouldShowUpdateDialog() async {
    try {
      // Solo mostrar en plataformas soportadas
      if (!_shouldCheckForUpdates()) {
        return false;
      }


      // Verificar si necesita actualización
      final versionStatus = await checkVersion();
      final shouldShow = versionStatus == 1;

      debugPrint(
        '📋 Status de versión: $versionStatus, Mostrar diálogo: $shouldShow',
      );

      return shouldShow;
    } catch (e) {
      debugPrint('❌ Error en shouldShowUpdateDialog: $e');
      return false;
    }
  }

  /// Método para obtener información de versión de la app
  Future<Map<String, String>> getAppVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = await DeviceInfoService.getDeviceInfo();

      return {
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'deviceType': deviceInfo['deviceType'] ?? 'Unknown',
        'platform': deviceInfo['platform'] ?? 'Unknown',
      };
    } catch (e) {
      return {
        'appName': 'PionierFactory',
        'packageName': 'com.example.pionierfactory',
        'version': '1.0.0',
        'buildNumber': '1',
        'deviceType': 'Unknown',
        'platform': 'Unknown',
      };
    }
  }
}
