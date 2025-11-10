import 'package:dio/dio.dart';
import 'storage_service.dart';
import 'auth_service.dart';

/// Interceptor que agrega automáticamente el token de autorización a las peticiones
/// y maneja la renovación automática del token cuando expira
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // No agregar token a endpoints de autenticación
    if (_isAuthEndpoint(options.path)) {
      return handler.next(options);
    }

    // Obtener token de acceso
    final accessToken = await StorageService.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si el error es 401 (no autorizado) y no es un endpoint de auth
    if (err.response?.statusCode == 401 && !_isAuthEndpoint(err.requestOptions.path)) {
      try {
        // Intentar renovar el token
        final authService = AuthService();
        final success = await authService.refreshToken();
        
        if (success) {
          // Retry la petición original con el nuevo token
          final response = await _retry(err.requestOptions);
          return handler.resolve(response);
        } else {
          // Si no se puede renovar, redirigir al login
          await authService.logout();
          // Aquí podrías agregar navegación al login si tienes acceso al contexto
        }
      } catch (e) {
        // Si falla la renovación, limpiar datos COMPLETAMENTE y continuar con el error
        await StorageService.clearCompleteLoginData();
      }
    }

    handler.next(err);
  }

  /// Verificar si es un endpoint de autenticación
  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/') || 
           path.contains('/login') || 
           path.contains('/refresh');
  }

  /// Reintentar la petición original con el nuevo token
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    // Obtener el nuevo token
    final accessToken = await StorageService.getAccessToken();
    if (accessToken != null) {
      requestOptions.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Crear un nuevo cliente Dio para evitar recursión
    final dio = Dio();
    return await dio.fetch(requestOptions);
  }
}
