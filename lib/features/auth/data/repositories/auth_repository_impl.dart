import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementación del repositorio de autenticación
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> login({
    required String numDocumento,
    required String password,
  }) async {
    final authResponse = await remoteDataSource.login(
      numDocumento: numDocumento,
      password: password,
    );

    // Guardar tokens y usuario
    await localDataSource.saveTokens(
      accessToken: authResponse.token,
      refreshToken: authResponse.refreshToken,
    );
    await localDataSource.saveUser(authResponse.user);

    return authResponse.user;
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
    await remoteDataSource.register(
      tipoDocumento: tipoDocumento,
      numDocumento: numDocumento,
      nombre: nombre,
      apePaterno: apePaterno,
      apeMaterno: apeMaterno,
      correo: correo,
      telefono: telefono,
      password: password,
    );
  }

  @override
  Future<void> logout() async {
    // The backend no longer exposes a logout endpoint. Perform local sign-out
    // by clearing stored tokens and user data.
    await localDataSource.clearAuthData();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await localDataSource.getUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final isLogged = await localDataSource.isLoggedIn();
      return isLogged;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> refreshToken() async {
    final refreshToken = await localDataSource.getRefreshToken();

    if (refreshToken == null) {
      throw CacheException(message: 'No hay refresh token');
    }

    final newAccessToken = await remoteDataSource.refreshToken(refreshToken);

    await localDataSource.saveTokens(
      accessToken: newAccessToken,
      refreshToken: refreshToken,
    );

    return newAccessToken;
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final token = await localDataSource.getAccessToken();

    if (token == null) {
      throw CacheException(message: 'No hay token de acceso');
    }

    await remoteDataSource.changePassword(
      token: token,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> requestPasswordRecovery({required String numDocumento}) async {
    await remoteDataSource.requestPasswordRecovery(numDocumento: numDocumento);
  }

  @override
  Future<void> resetPassword({
    required String numDocumento,
    required String code,
    required String newPassword,
  }) async {
    await remoteDataSource.resetPassword(
      numDocumento: numDocumento,
      code: code,
      newPassword: newPassword,
    );
  }

  @override
  Future<Map<String, dynamic>> activateAccount(String token) async {
    return await remoteDataSource.activateAccount(token);
  }

  @override
  Future<Map<String, dynamic>?> loginWithInactiveCheck({
    required String numDocumento,
    required String password,
  }) async {
    return await remoteDataSource.loginWithInactiveCheck(
      numDocumento: numDocumento,
      password: password,
    );
  }

  @override
  Future<void> resendActivationEmail({
    required int codUser,
    required String numDocumento,
    required String correo,
    required String nombre,
  }) async {
    await remoteDataSource.resendActivationEmail(
      codUser: codUser,
      numDocumento: numDocumento,
      correo: correo,
      nombre: nombre,
    );
  }

  @override
  Future<Map<String, dynamic>> checkInactiveAccount({
    required String identifier,
  }) async {
    return await remoteDataSource.checkInactiveAccount(identifier: identifier);
  }
}
