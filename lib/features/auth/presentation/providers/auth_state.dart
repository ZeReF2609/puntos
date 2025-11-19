import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Estados de autenticación
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado de carga
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado de usuario autenticado
class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Estado de usuario no autenticado
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Estado que indica que el registro se completó correctamente
class Registered extends AuthState {
  final String? message;

  const Registered([this.message]);

  @override
  List<Object?> get props => [message];
}

/// Estado de error
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
