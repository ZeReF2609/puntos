import 'package:dio/dio.dart';
import '../../app/constants/api_constants.dart';
import 'auth_interceptor.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _initializeDio();
  }

  late final Dio _dio;

  /// Inicializar Dio
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
        sendTimeout: Duration(milliseconds: ApiConstants.sendTimeout),
        headers: ApiConstants.defaultHeaders,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Agregar interceptor para manejo automático de tokens
    _dio.interceptors.add(AuthInterceptor());
  }

  /// Getter para acceder al cliente Dio
  Dio get client => _dio;

  // ============ MÉTODOS HTTP BÁSICOS ============

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============ MANEJO DE ERRORES ============

  /// Manejar errores de Dio y convertirlos en excepciones personalizadas
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException('Tiempo de conexión agotado', 408);
      case DioExceptionType.sendTimeout:
        return ApiException('Tiempo de envío agotado', 408);
      case DioExceptionType.receiveTimeout:
        return ApiException('Tiempo de respuesta agotado', 408);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final message =
            error.response?.data?['message'] ?? 'Error del servidor';
        return ApiException(message, statusCode);
      case DioExceptionType.cancel:
        return ApiException('Petición cancelada', 0);
      case DioExceptionType.connectionError:
        return ApiException('Error de conexión. Verifique su red.', 0);
      case DioExceptionType.badCertificate:
        return ApiException('Certificado SSL inválido', 0);
      case DioExceptionType.unknown:
        return ApiException('Error desconocido: ${error.message}', 0);
    }
  }

  // ============ UTILIDADES ============

  /// Actualizar la URL base (útil para cambiar entre servidores en planta)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// Verificar conectividad antes de hacer peticiones
  Future<bool> checkConnectivity() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Excepción personalizada para errores de API
class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
