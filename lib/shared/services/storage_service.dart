import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/constants/storage_keys.dart';
import '../models/login_models.dart';

class StorageService {
  // Almacenamiento seguro para tokens y datos sensibles
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    wOptions: WindowsOptions(),
    lOptions: LinuxOptions(),
    webOptions: WebOptions(),
  );

  // Almacenamiento simple para preferencias no sensibles
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ============ MÉTODOS DE ALMACENAMIENTO MULTIPLATAFORMA ============

  /// Guardar datos de forma segura
  static Future<void> _secureWrite(String key, String value) async {
    if (kIsWeb) {
      // En web, usar SharedPreferences como alternativa segura
      await _prefs?.setString('secure_$key', value);
    } else {
      // En mobile/desktop, usar secure storage
      await _secureStorage.write(key: key, value: value);
    }
  }

  /// Leer datos de forma segura
  static Future<String?> _secureRead(String key) async {
    if (kIsWeb) {
      // En web, leer de SharedPreferences
      return _prefs?.getString('secure_$key');
    } else {
      // En mobile/desktop, leer de secure storage
      return await _secureStorage.read(key: key);
    }
  }

  /// Eliminar datos de forma segura
  static Future<void> _secureDelete(String key) async {
    if (kIsWeb) {
      // En web, remover de SharedPreferences
      await _prefs?.remove('secure_$key');
    } else {
      // En mobile/desktop, eliminar de secure storage
      await _secureStorage.delete(key: key);
    }
  }

  // ============ TOKENS SEGUROS ============

  /// Guardar token de acceso de forma segura
  static Future<void> saveAccessToken(String token) async {
    await _secureWrite(StorageKeys.accessToken, token);
  }

  /// Obtener token de acceso
  static Future<String?> getAccessToken() async {
    // Primero intentar leer desde la clave individual
    String? accessToken = await _secureRead(StorageKeys.accessToken);

    // Si no existe, intentar obtener desde los datos completos
    if (accessToken == null || accessToken.isEmpty) {
      final completeData = await loadCompleteLoginData();
      if (completeData != null && completeData.token.isNotEmpty) {
        accessToken = completeData.token;
      }
    }

    return accessToken;
  }

  /// Guardar token de refresh de forma segura
  static Future<void> saveRefreshToken(String token) async {
    await _secureWrite(StorageKeys.refreshToken, token);
  }

  /// Obtener token de refresh
  static Future<String?> getRefreshToken() async {
    // Primero intentar leer desde la clave individual
    String? refreshToken = await _secureRead(StorageKeys.refreshToken);

    // Si no existe, intentar obtener desde los datos completos
    if (refreshToken == null || refreshToken.isEmpty) {
      final completeData = await loadCompleteLoginData();
      if (completeData != null && completeData.refreshToken.isNotEmpty) {
        refreshToken = completeData.refreshToken;
      }
    }

    return refreshToken;
  }

  /// Guardar información completa del token
  static Future<void> saveTokenInfo({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required DateTime expiry,
  }) async {
    await Future.wait([
      _secureWrite(StorageKeys.accessToken, accessToken),
      _secureWrite(StorageKeys.refreshToken, refreshToken),
      _secureWrite(StorageKeys.tokenType, tokenType),
      _secureWrite(StorageKeys.tokenExpiry, expiry.toIso8601String()),
    ]);
  }

  /// Verificar si el token ha expirado
  static Future<bool> isTokenExpired() async {
    final expiryString = await _secureRead(StorageKeys.tokenExpiry);
    if (expiryString == null) return true;

    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isAfter(expiry);
  }

  // ============ DATOS DE USUARIO ============

  /// Guardar datos del usuario
  static Future<void> saveUserData({
    required String userId,
    required String username,
    required String role,
    List<String>? permissions,
  }) async {
    await Future.wait([
      _secureWrite(StorageKeys.userId, userId),
      _secureWrite(StorageKeys.username, username),
      _secureWrite(StorageKeys.userRole, role),
      if (permissions != null)
        _secureWrite(StorageKeys.userPermissions, permissions.join(',')),
    ]);
  }

  /// Obtener ID del usuario
  static Future<String?> getUserId() async {
    // Primero intentar leer desde la clave individual
    String? userId = await _secureRead(StorageKeys.userId);

    // Si no existe, intentar obtener desde los datos completos
    if (userId == null || userId.isEmpty) {
      final completeData = await loadCompleteLoginData();
      if (completeData != null && completeData.coUser > 0) {
        userId = completeData.coUser.toString();
      }
    }

    return userId;
  }

  /// Obtener nombre de usuario
  static Future<String?> getUsername() async {
    // Primero intentar leer desde la clave individual
    String? username = await _secureRead(StorageKeys.username);

    // Si no existe, intentar obtener desde los datos completos
    if (username == null || username.isEmpty) {
      final completeData = await loadCompleteLoginData();
      if (completeData != null && completeData.usrTrab.isNotEmpty) {
        username = completeData.usrTrab;
      }
    }

    return username;
  }

  /// Obtener rol del usuario
  static Future<String?> getUserRole() async {
    // Primero intentar leer desde la clave individual
    String? userRole = await _secureRead(StorageKeys.userRole);

    // Si no existe, intentar obtener desde los datos completos
    if (userRole == null || userRole.isEmpty) {
      final completeData = await loadCompleteLoginData();
      if (completeData != null && completeData.noRol.isNotEmpty) {
        userRole = completeData.noRol;
      }
    }

    return userRole;
  }

  // ============ CONFIGURACIÓN NO SENSIBLE ============

  /// Guardar URL del servidor
  static Future<void> saveServerUrl(String url) async {
    await _prefs?.setString(StorageKeys.serverUrl, url);
  }

  /// Obtener URL del servidor
  static String? getServerUrl() {
    return _prefs?.getString(StorageKeys.serverUrl);
  }

  /// Guardar ID de la planta
  static Future<void> savePlantId(String plantId) async {
    await _prefs?.setString(StorageKeys.plantId, plantId);
  }

  /// Obtener ID de la planta
  static String? getPlantId() {
    return _prefs?.getString(StorageKeys.plantId);
  }

  /// Configurar modo offline
  static Future<void> setOfflineMode(bool isOffline) async {
    await _prefs?.setBool(StorageKeys.offlineMode, isOffline);
  }

  /// Verificar si está en modo offline
  static bool isOfflineMode() {
    return _prefs?.getBool(StorageKeys.offlineMode) ?? false;
  }

  /// Marcar como sesión temporal
  static Future<void> setSessionOnly(bool isSessionOnly) async {
    await _prefs?.setBool(StorageKeys.sessionOnly, isSessionOnly);
  }

  /// Verificar si es solo sesión temporal
  static bool isSessionOnly() {
    return _prefs?.getBool(StorageKeys.sessionOnly) ?? false;
  }

  // ============ LIMPIEZA ============

  /// Limpiar todos los datos de autenticación
  static Future<void> clearAuthData() async {
    await Future.wait([
      _secureDelete(StorageKeys.accessToken),
      _secureDelete(StorageKeys.refreshToken),
      _secureDelete(StorageKeys.tokenType),
      _secureDelete(StorageKeys.tokenExpiry),
      _secureDelete(StorageKeys.userId),
      _secureDelete(StorageKeys.username),
      _secureDelete(StorageKeys.userRole),
      _secureDelete(StorageKeys.userPermissions),
    ]);
  }

  /// Limpiar solo los datos del usuario (mantener tokens)
  static Future<void> clearUserData() async {
    await Future.wait([
      _secureDelete(StorageKeys.userId),
      _secureDelete(StorageKeys.username),
      _secureDelete(StorageKeys.userRole),
      _secureDelete(StorageKeys.userPermissions),
    ]);
  }

  /// Limpiar todos los datos
  static Future<void> clearAll() async {
    if (kIsWeb) {
      // En web, limpiar SharedPreferences
      final keys =
          _prefs
              ?.getKeys()
              .where((key) => key.startsWith('secure_'))
              .toList() ??
          [];
      for (final key in keys) {
        await _prefs?.remove(key);
      }
    } else {
      // En mobile/desktop
      await _secureStorage.deleteAll();
    }
    await _prefs?.clear();
  }

  /// Limpiar ID de la planta
  static Future<void> clearPlantId() async {
    await _prefs?.remove(StorageKeys.plantId);
  }

  // ============ MÉTODOS GENÉRICOS PARA VALORES ARBITRARIOS ============

  /// Guardar un valor genérico de forma segura
  static Future<void> saveValue(String key, String value) async {
    await _secureWrite(key, value);
  }

  /// Obtener un valor genérico
  static Future<String?> getValue(String key) async {
    return await _secureRead(key);
  }

  /// Eliminar un valor genérico
  static Future<void> deleteValue(String key) async {
    await _secureDelete(key);
  }

  // ============ MÉTODOS PARA LOGINDATA COMPLETO ============

  /// Guardar datos de login completos (incluyendo permisos)
  static Future<void> saveCompleteLoginData(LoginData loginData) async {
    try {
      // Convertir LoginData a Map para serialización
      final Map<String, dynamic> loginMap = {
        'coUser': loginData.coUser,
        'usrTrab': loginData.usrTrab,
        'coRol': loginData.coRol,
        'noRol': loginData.noRol,
        'coArea': loginData.coArea,
        'noArea': loginData.noArea,
        'token': loginData.token,
        'refreshToken': loginData.refreshToken,
        'fechaExpiraToken': loginData.fechaExpiraToken,
        'fechaExpiraRefresh': loginData.fechaExpiraRefresh,
        'grupos': loginData.grupos,
        'permisos': loginData.permisos
            .map(
              (permiso) => {
                'coRol': permiso.coRol,
                'coMenu': permiso.coMenu,
                'icMenu': permiso.icMenu,
                'noMenu': permiso.noMenu,
                'coSubmenu': permiso.coSubmenu,
                'noSubmenu': permiso.noSubmenu,
                'coAccion': permiso.coAccion,
                'noAccion': permiso.noAccion,
                'permitido': permiso.permitido,
                'icSubmenu': permiso.icSubmenu,
                'ruSubmenu': permiso.ruSubmenu,
              },
            )
            .toList(),
        'estado_version': loginData.estadoVersion,
      };

      // Convertir a JSON string
      final jsonString = jsonEncode(loginMap);

      // Guardar según plataforma
      await _secureWrite(StorageKeys.completeLoginData, jsonString);

      // También guardar flag de que hay datos guardados
      await _secureWrite(StorageKeys.hasLoginData, 'true');
    } catch (e) {
      // Error silencioso
    }
  }

  /// Cargar datos de login completos
  static Future<LoginData?> loadCompleteLoginData() async {
    try {
      // Verificar si hay datos guardados
      final hasData = await _secureRead(StorageKeys.hasLoginData);
      if (hasData != 'true') return null;

      // Leer JSON
      final jsonString = await _secureRead(StorageKeys.completeLoginData);
      if (jsonString == null) return null;

      // Deserializar
      final Map<String, dynamic> loginMap = jsonDecode(jsonString);

      // Reconstruir LoginData
      return LoginData(
        coUser: loginMap['coUser'] ?? 0,
        usrTrab: loginMap['usrTrab'] ?? '',
        coRol: loginMap['coRol'] ?? 0,
        noRol: loginMap['noRol'] ?? '',
        coArea: loginMap['coArea'] ?? 0,
        noArea: loginMap['noArea'] ?? '',
        token: loginMap['token'] ?? '',
        refreshToken: loginMap['refreshToken'] ?? '',
        fechaExpiraToken: loginMap['fechaExpiraToken'] ?? '',
        fechaExpiraRefresh: loginMap['fechaExpiraRefresh'] ?? '',
        grupos: loginMap['grupos'] ?? [],
        permisos: (loginMap['permisos'] as List<dynamic>)
            .map(
              (p) => PermisoMenu(
                coRol: p['coRol'] ?? 0,
                coMenu: p['coMenu'] ?? 0,
                icMenu: p['icMenu'] ?? '',
                noMenu: p['noMenu'] ?? '',
                coSubmenu: p['coSubmenu'] ?? 0,
                noSubmenu: p['noSubmenu'] ?? '',
                coAccion: p['coAccion'] ?? 0,
                noAccion: p['noAccion'] ?? '',
                permitido: p['permitido'] ?? false,
                icSubmenu: p['icSubmenu'] ?? '',
                ruSubmenu: p['ruSubmenu'] ?? '',
              ),
            )
            .toList(),
        estadoVersion: loginMap['estado_version'],
      );
    } catch (e) {
      // Error en la deserialización
      return null;
    }
  }

  /// Eliminar datos de login completos y TODOS los datos relacionados
  static Future<void> clearCompleteLoginData() async {
    try {
      // Usar limpieza forzada que es más robusta
      await forceCompleteLogout();
    } catch (e) {
      // Respaldo: intentar limpieza tradicional
      try {
        await Future.wait([
          // Limpiar LoginData completo
          _secureDelete(StorageKeys.completeLoginData),
          _secureDelete(StorageKeys.hasLoginData),

          // Limpiar tokens
          _secureDelete(StorageKeys.accessToken),
          _secureDelete(StorageKeys.refreshToken),
          _secureDelete(StorageKeys.tokenType),
          _secureDelete(StorageKeys.tokenExpiry),

          // Limpiar datos del usuario
          _secureDelete(StorageKeys.userId),
          _secureDelete(StorageKeys.username),
          _secureDelete(StorageKeys.userRole),
          _secureDelete(StorageKeys.userPermissions),

          // Limpiar configuración específica
          clearPlantId(),

          // Limpiar preferencias de sesión
          _secureDelete(StorageKeys.rememberMe),
          _secureDelete(StorageKeys.lastLoginTime),

          // Limpiar marcador de sesión temporal
          clearSessionOnly(),
        ]);
      } catch (backupError) {
        // Error silencioso en limpieza de respaldo
      }
    }
  }

  /// Limpiar marcador de sesión temporal
  static Future<void> clearSessionOnly() async {
    await _prefs?.remove(StorageKeys.sessionOnly);
  }

  // ============ MÉTODOS DE LIMPIEZA INTERNA ============

  /// Método para forzar limpieza completa
  static Future<void> forceCompleteLogout() async {
    try {
      // Limpiar todos los datos de storage seguro
      final keysToDelete = [
        StorageKeys.completeLoginData,
        StorageKeys.hasLoginData,
        StorageKeys.accessToken,
        StorageKeys.refreshToken,
        StorageKeys.tokenType,
        StorageKeys.tokenExpiry,
        StorageKeys.userId,
        StorageKeys.username,
        StorageKeys.userRole,
        StorageKeys.userPermissions,
        StorageKeys.rememberMe,
        StorageKeys.lastLoginTime,
      ];

      for (final key in keysToDelete) {
        try {
          await _secureDelete(key);
        } catch (e) {
          // Error silencioso para evitar fallos en producción
        }
      }

      // Limpiar SharedPreferences
      await clearPlantId();
      await clearSessionOnly();
    } catch (e) {
      // Error silencioso
    }
  }
}
