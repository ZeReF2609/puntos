import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Interfaz del datasource local de autenticación
abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();

  Future<void> clearAuthData();
  Future<bool> isLoggedIn();
}

/// Implementación del datasource local usando SharedPreferences
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _prefs.setString(AppConstants.keyAccessToken, accessToken);
      await _prefs.setString(AppConstants.keyRefreshToken, refreshToken);
      await _prefs.setBool(AppConstants.keyIsLoggedIn, true);
    } catch (e) {
      throw CacheException(message: 'Error al guardar tokens: $e');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return _prefs.getString(AppConstants.keyAccessToken);
    } catch (e) {
      throw CacheException(message: 'Error al obtener access token: $e');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return _prefs.getString(AppConstants.keyRefreshToken);
    } catch (e) {
      throw CacheException(message: 'Error al obtener refresh token: $e');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await _prefs.setString(AppConstants.keyUserData, user.toJsonString());
      await _prefs.setInt(AppConstants.keyUserId, user.codPersona);
    } catch (e) {
      throw CacheException(message: 'Error al guardar usuario: $e');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userJson = _prefs.getString(AppConstants.keyUserData);
      if (userJson != null) {
        return UserModel.fromJsonString(userJson);
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Error al obtener usuario: $e');
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await _prefs.remove(AppConstants.keyAccessToken);
      await _prefs.remove(AppConstants.keyRefreshToken);
      await _prefs.remove(AppConstants.keyUserData);
      await _prefs.remove(AppConstants.keyUserId);
      await _prefs.setBool(AppConstants.keyIsLoggedIn, false);
    } catch (e) {
      throw CacheException(message: 'Error al limpiar datos: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return _prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    } catch (e) {
      return false;
    }
  }
}
