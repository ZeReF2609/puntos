import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../app/app.dart';
import '../models/login_models.dart';
import '../models/login_request.dart';
import 'storage_service.dart';
import 'device_info_service.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  /// Realizar login con la API
  Future<LoginResponse> login(String username, String password) async {
    try {
      // Obtener información del dispositivo e IP
      final deviceInfo = await DeviceInfoService.getDeviceInfo();

      // ✅ Obtener versión de la app
      final packageInfo = await PackageInfo.fromPlatform();
      final versionApp = '${packageInfo.version}+${packageInfo.buildNumber}';

      // Crear el request de login
      final loginRequest = LoginRequest(
        usuario: username,
        password: password,
        dispositivo: deviceInfo['deviceType'] ?? 'Unknown Device',
        version: versionApp,
      );

      // Hacer la petición al servidor
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.loginEndpoint,
        data: loginRequest.toJson(),
      );

      // Parsear la respuesta
      final loginResponse = LoginResponse.fromJson(response.data ?? {});

      // Si el login es exitoso, guardar los datos
      if (loginResponse.success && loginResponse.data != null) {
        await _saveLoginData(loginResponse.data!);
      }

      return loginResponse;
    } on DioException catch (e) {
      // Manejar errores específicos de la API
      return _handleApiError(e);
    } catch (e) {
      // Manejar errores generales
      return LoginResponse(
        success: false,
        message: 'Error inesperado: $e',
        data: null,
      );
    }
  }

  /*
  /// Refrescar token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.refreshTokenEndpoint,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;

        // Actualizar tokens
        if (data['token'] != null) {
          await StorageService.saveAccessToken(data['token']);
        }

        if (data['refresH_TOKEN'] != null) {
          await StorageService.saveRefreshToken(data['refresH_TOKEN']);
        }

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Logout
  Future<bool> logout() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();

      if (refreshToken != null) {
        // Intentar hacer logout en el servidor con el refresh token
        try {
          final logoutRequest = LogoutRequest(refreshToken: refreshToken);

          final response = await _apiService.post(
            ApiConstants.logoutEndpoint,
            data: logoutRequest.toJson(),
          );

          // Verificar si el logout fue exitoso
          if (response.statusCode == 200) {
            try {
              final logoutResponse = LogoutResponse.fromJson(response.data);
              if (logoutResponse.success) {
                // Logout exitoso en servidor, limpiar datos locales
                await StorageService.clearCompleteLoginData();
                return true;
              }
            } catch (parseError) {
              // Error parseando respuesta, pero continuar con limpieza
            }
          }
        } catch (e) {
          // Si falla el logout en servidor, continuar con logout local
        }
      }

      // Limpiar datos locales (incluso si falla el logout en servidor)
      await StorageService.clearCompleteLoginData();
      return true;
    } catch (e) {
      // Incluso si hay error, limpiar datos locales
      await StorageService.clearCompleteLoginData();
      return true;
    }
  }

  /// Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) return false;

      final isExpired = await StorageService.isTokenExpired();
      if (isExpired) {
        // Intentar refrescar el token
        final refreshed = await refreshToken();
        return refreshed;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
*/
  /// Guardar datos del login
  Future<void> _saveLoginData(LoginData loginData) async {
    try {
      // Parsear fechas
      final tokenExpiry = _parseDate(loginData.fechaExpiraToken);

      // Guardar tokens
      await StorageService.saveTokenInfo(
        accessToken: loginData.token,
        refreshToken: loginData.refreshToken,
        tokenType: 'Bearer',
        expiry: tokenExpiry,
      );

      // Guardar datos del usuario
      await StorageService.saveUserData(
        userId: loginData.coUser.toString(),
        username: loginData.usrTrab,
        role: loginData.noRol,
        permissions: loginData.permisos
            .where((p) => p.permitido)
            .map((p) => '${p.ruSubmenu}:${p.noAccion}')
            .toList(),
      );

      // Guardar información adicional
      await StorageService.savePlantId(loginData.coArea.toString());
    } catch (e) {
      throw Exception('Error guardando datos del login: $e');
    }
  }

  /// Parsear fecha desde string a DateTime
  DateTime _parseDate(String dateString) {
    try {
      // Formato esperado: "2/08/2025 20:56:53"
      final parts = dateString.split(' ');
      final datePart = parts[0];
      final timePart = parts.length > 1 ? parts[1] : '00:00:00';

      final dateComponents = datePart.split('/');
      final timeComponents = timePart.split(':');

      return DateTime(
        int.parse(dateComponents[2]), // año
        int.parse(dateComponents[1]), // mes
        int.parse(dateComponents[0]), // día
        int.parse(timeComponents[0]), // hora
        int.parse(timeComponents[1]), // minuto
        timeComponents.length > 2 ? int.parse(timeComponents[2]) : 0, // segundo
      );
    } catch (e) {
      // Devolver fecha por defecto (24 horas desde ahora)
      return DateTime.now().add(const Duration(hours: 24));
    }
  }

  /// Manejar errores de la API
  LoginResponse _handleApiError(DioException error) {
    String message = 'Error de conexión';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        message = 'Tiempo de conexión agotado. Verifique su red.';
        break;
      case DioExceptionType.connectionError:
        message =
            'No se puede conectar al servidor.\nVerifique que la API esté ejecutándose en http://10.80.40.156:5214';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        if (statusCode == 401) {
          message = 'Usuario o contraseña incorrectos';
        } else if (statusCode == 403) {
          message = 'Acceso denegado';
        } else if (statusCode == 500) {
          message = 'Error interno del servidor';
        } else if (responseData != null && responseData['message'] != null) {
          message = responseData['message'];
        } else {
          message = 'Error del servidor (Código: $statusCode)';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Operación cancelada';
        break;
      default:
        message = 'Error inesperado: ${error.message}';
    }

    return LoginResponse(success: false, message: message, data: null);
  }
}
