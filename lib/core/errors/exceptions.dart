class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'Error al acceder al almacenamiento local'});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException({this.message = 'Sin conexión a internet'});

  @override
  String toString() => 'NetworkException: $message';
}

class AuthenticationException implements Exception {
  final String message;

  AuthenticationException({this.message = 'Error de autenticación'});

  @override
  String toString() => 'AuthenticationException: $message';
}

class ValidationException implements Exception {
  final String message;

  ValidationException({required this.message});

  @override
  String toString() => 'ValidationException: $message';
}

class UnknownException implements Exception {
  final String message;

  UnknownException({this.message = 'Error desconocido'});

  @override
  String toString() => 'UnknownException: $message';
}

/// Excepción para cuenta inactiva (no verificada)
class InactiveAccountException implements Exception {
  final String message;
  final Map<String, dynamic>? userData;

  InactiveAccountException({required this.message, this.userData});

  @override
  String toString() => 'InactiveAccountException: $message';
}
