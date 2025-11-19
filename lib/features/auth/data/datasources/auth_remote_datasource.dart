import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';
import '../models/auth_response_model.dart';

/// Interfaz del datasource remoto de autenticación
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String numDocumento,
    required String password,
  });

  Future<void> register({
    required String tipoDocumento,
    required String numDocumento,
    required String nombre,
    required String apePaterno,
    required String apeMaterno,
    required String correo,
    required String telefono,
    required String password,
  });

  Future<String> refreshToken(String refreshToken);
  Future<UserModel> getProfile(String token);

  Future<void> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  });

  Future<void> requestPasswordRecovery({required String numDocumento});
  Future<void> resetPassword({
    required String numDocumento,
    required String code,
    required String newPassword,
  });

  Future<Map<String, dynamic>> activateAccount(String token);

  Future<Map<String, dynamic>?> loginWithInactiveCheck({
    required String numDocumento,
    required String password,
  });

  Future<void> resendActivationEmail({
    required int codUser,
    required String numDocumento,
    required String correo,
    required String nombre,
  });

  Future<Map<String, dynamic>> checkInactiveAccount({
    required String identifier,
  });
}

/// Implementación del datasource remoto de autenticación
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<AuthResponseModel> login({
    required String numDocumento,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        AppConstants.authLogin,
        data: {
          'numDocumento': numDocumento,
          'password': password,
          'deviceInfo': {'platform': 'Flutter', 'deviceName': 'Mobile App'},
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => AuthResponseModel.fromJson(data),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ServerException(
            message: apiResponse.message ?? 'Error en el login',
          );
        }
      } else {
        throw ServerException(
          message: 'Error en el servidor',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> register({
    required String tipoDocumento,
    required String numDocumento,
    required String nombre,
    required String apePaterno,
    required String apeMaterno,
    required String correo,
    required String telefono,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        AppConstants.authRegister,
        data: {
          'tipoDocumento': tipoDocumento,
          'numDocumento': numDocumento,
          'nombre': nombre,
          'apePaterno': apePaterno,
          'apeMaterno': apeMaterno,
          'correo': correo,
          'telefono': telefono,
          'password': password,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, null);

        if (!apiResponse.success) {
          throw ServerException(
            message: apiResponse.message ?? 'Error en el registro',
          );
        }
      } else {
        throw ServerException(
          message: 'Error en el servidor',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dioClient.post(
        AppConstants.authRefresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, null);

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data['token'];
        } else {
          throw ServerException(
            message: apiResponse.message ?? 'Error al refrescar token',
          );
        }
      } else {
        throw ServerException(
          message: 'Error en el servidor',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> getProfile(String token) async {
    try {
      final response = await _dioClient.get(
        AppConstants.authProfile,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data,
          (data) => UserModel.fromJson(data),
        );

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!;
        } else {
          throw ServerException(
            message: apiResponse.message ?? 'Error al obtener perfil',
          );
        }
      } else {
        throw ServerException(
          message: 'Error en el servidor',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dioClient.post(
        AppConstants.authChangePassword,
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, null);

        if (!apiResponse.success) {
          throw ServerException(
            message: apiResponse.message ?? 'Error al cambiar contraseña',
          );
        }
      } else {
        throw ServerException(
          message: 'Error en el servidor',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> requestPasswordRecovery({required String numDocumento}) async {
    try {
      final response = await _dioClient.post(
        AppConstants.authForgotPassword,
        data: {'numDocumento': numDocumento},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, null);

        if (!apiResponse.success) {
          throw ServerException(
            message: apiResponse.message ?? 'Error al solicitar recuperación',
          );
        }
      } else {
        throw ServerException(
          message: 'Error en el servidor',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> resetPassword({
    required String numDocumento,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await _dioClient.post(
        AppConstants.authResetPassword,
        data: {
          'numDocumento': numDocumento,
          'code': code,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, null);

        if (!apiResponse.success) {
          throw ServerException(
            message: apiResponse.message ?? 'Error al restablecer contraseña',
          );
        }
      } else {
        throw ServerException(
          message: 'Error en el servidor',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> activateAccount(String token) async {
    try {
      final response = await _dioClient.get('/auth/activate/$token');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, null);

        return {
          'success': apiResponse.success,
          'message': apiResponse.message ?? 'Cuenta activada correctamente',
        };
      } else {
        return {'success': false, 'message': 'Error al activar la cuenta'};
      }
    } on DioException catch (e) {
      final error = _handleDioError(e);
      return {'success': false, 'message': error.message};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>?> loginWithInactiveCheck({
    required String numDocumento,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        AppConstants.authLogin,
        data: {
          'numDocumento': numDocumento,
          'password': password,
          'deviceInfo': {'platform': 'Flutter', 'deviceName': 'Mobile App'},
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, (data) => data);

        // Verificar si es cuenta inactiva
        if (apiResponse.data != null &&
            apiResponse.data is Map<String, dynamic>) {
          final responseData = apiResponse.data as Map<String, dynamic>;

          if (responseData['accountInactive'] == true) {
            return {
              'accountInactive': true,
              'message': apiResponse.message ?? 'Cuenta no activada',
              'data': responseData['data'],
            };
          }

          // Login exitoso
          final authData = AuthResponseModel.fromJson(responseData);
          return {'accountInactive': false, 'user': authData.user};
        }

        throw ServerException(
          message: apiResponse.message ?? 'Error en el login',
        );
      } else {
        throw ServerException(
          message: 'Error en el servidor',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // CASO ESPECIAL: Error 403 = cuenta inactiva
      if (e.response?.statusCode == 403) {
        final responseData = e.response?.data;

        if (responseData is Map<String, dynamic> &&
            responseData['accountInactive'] == true) {
          return {
            'accountInactive': true,
            'message':
                responseData['message'] ?? 'Tu cuenta aún no ha sido activada',
            'data': responseData['data'],
          };
        }
      }

      // Otros errores de Dio
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> resendActivationEmail({
    required int codUser,
    required String numDocumento,
    required String correo,
    required String nombre,
  }) async {
    try {
      final response = await _dioClient.post(
        '/auth/resend-activation',
        data: {
          'codUser': codUser,
          'numDocumento': numDocumento,
          'correo': correo,
          'nombre': nombre,
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, null);

        if (!apiResponse.success) {
          throw ServerException(
            message: apiResponse.message ?? 'Error al reenviar email',
          );
        }
      } else {
        throw ServerException(
          message: 'Error en el servidor',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> checkInactiveAccount({
    required String identifier,
  }) async {
    try {
      final response = await _dioClient.post(
        '/auth/check-inactive-account',
        data: {'identifier': identifier},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, null);

        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data as Map<String, dynamic>;
        } else {
          throw ServerException(
            message: apiResponse.message ?? 'Error al verificar cuenta',
          );
        }
      } else {
        throw ServerException(
          message: 'Error en el servidor',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  /// Manejo de errores de Dio
  ServerException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerException(
          message: 'Tiempo de conexión agotado',
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        final responseData = error.response?.data;
        String message = 'Error en el servidor';

        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] ?? message;
        }

        return ServerException(message: message, statusCode: statusCode);
      case DioExceptionType.cancel:
        return ServerException(message: 'Petición cancelada');
      default:
        return ServerException(message: 'Error de conexión: ${error.message}');
    }
  }
}
