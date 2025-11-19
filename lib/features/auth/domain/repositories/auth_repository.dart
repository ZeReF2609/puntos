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

  Future<void> changePassword({
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
