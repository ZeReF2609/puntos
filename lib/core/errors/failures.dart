import 'package:equatable/equatable.dart';

/// Clase base para todos los fallos
/// Estas se retornan en los casos de uso para manejo seguro de errores
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Fallos del servidor
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

/// Fallos de caché/almacenamiento local
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Error al acceder al almacenamiento local',
  });
}

/// Fallos de red/conexión
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Sin conexión a internet. Verifica tu red',
  });
}

/// Fallos de autenticación
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Error de autenticación',
  });
}

/// Fallos de validación
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Fallos desconocidos
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Ocurrió un error inesperado',
  });
}
