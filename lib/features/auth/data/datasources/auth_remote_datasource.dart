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
  Future<void> logout(String token);
  Future<UserModel> getProfile(String token);
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
  Future<void> logout(String token) async {
    try {
      final response = await _dioClient.post(
        AppConstants.authLogout,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Error al cerrar sesión',
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
