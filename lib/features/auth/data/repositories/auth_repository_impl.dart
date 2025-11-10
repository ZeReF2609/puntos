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
    final token = await localDataSource.getAccessToken();

    if (token != null) {
      try {
        await remoteDataSource.logout(token);
      } catch (e) {
        // Continuamos aunque falle el logout remoto
      }
    }

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
}
