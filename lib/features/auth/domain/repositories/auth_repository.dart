import '../../domain/entities/user_entity.dart';

/// Repositorio abstracto de autenticación (capa de dominio)
abstract class AuthRepository {
  Future<UserEntity> login({
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

  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<String> refreshToken();
}
