import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Provider de autenticación usando ChangeNotifier
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  AuthState _state = const AuthInitial();

  AuthProvider({required AuthRepository repository})
    : _repository = repository {
    _checkAuthStatus();
  }

  /// Estado actual
  AuthState get state => _state;

  /// Cambiar estado y notificar
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Verificar estado de autenticación al iniciar
  Future<void> _checkAuthStatus() async {
    try {
      final isLogged = await _repository.isLoggedIn();

      if (isLogged) {
        final user = await _repository.getCurrentUser();
        if (user != null) {
          _setState(Authenticated(user));
        } else {
          _setState(const Unauthenticated());
        }
      } else {
        _setState(const Unauthenticated());
      }
    } catch (e) {
      // Si ocurre un error al verificar el estado, dejar como no autenticado.
      _setState(const Unauthenticated());
    }
  }

  /// Login
  Future<void> login({required String email, required String password}) async {
    try {
      _setState(const AuthLoading());

      // Usar loginWithInactiveCheck para manejar cuentas inactivas
      final result = await _repository.loginWithInactiveCheck(
        numDocumento: email,
        password: password,
      );

      // Si es un resultado de cuenta inactiva, lanzar excepción especial
      if (result != null && result['accountInactive'] == true) {
        final message =
            result['message'] as String? ?? 'Tu cuenta aún no ha sido activada';
        final data = result['data'] as Map<String, dynamic>?;

        // Lanzar excepción con datos de cuenta inactiva
        throw InactiveAccountException(message: message, userData: data);
      }

      // Si es login exitoso
      if (result != null && result['user'] != null) {
        _setState(Authenticated(result['user']));
        return;
      }

      // Error genérico
      _setState(const AuthError('Error al iniciar sesión'));
    } catch (e) {
      // Si es InactiveAccountException, no cambiar el estado a error
      if (e is InactiveAccountException) {
        _setState(const Unauthenticated());
        rethrow; // Re-lanzar para que el login screen lo capture
      }
      _setState(AuthError(_getErrorMessage(e)));
    }
  }

  /// Login con verificación de cuenta inactiva
  /// Retorna Map con info si la cuenta está inactiva, null si todo OK
  Future<Map<String, dynamic>?> loginWithInactiveCheck({
    required String email,
    required String password,
  }) async {
    try {
      _setState(const AuthLoading());

      final result = await _repository.loginWithInactiveCheck(
        numDocumento: email,
        password: password,
      );

      // Si es un resultado de cuenta inactiva
      if (result != null && result['accountInactive'] == true) {
        _setState(const Unauthenticated());
        return result;
      }

      // Si es login exitoso
      if (result != null && result['user'] != null) {
        _setState(Authenticated(result['user']));
        return null;
      }

      // Error genérico
      _setState(const AuthError('Error al iniciar sesión'));
      return null;
    } catch (e) {
      _setState(AuthError(_getErrorMessage(e)));
      return null;
    }
  }

  /// Registro
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
      _setState(const AuthLoading());

      await _repository.register(
        tipoDocumento: tipoDocumento,
        numDocumento: numDocumento,
        nombre: nombre,
        apePaterno: apePaterno,
        apeMaterno: apeMaterno,
        correo: correo,
        telefono: telefono,
        password: password,
      );

      // Indicar que el registro fue exitoso para que la UI redirija al login.
      _setState(const Registered('Cuenta creada correctamente'));
    } catch (e) {
      _setState(AuthError(_getErrorMessage(e)));
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _repository.logout();
      _setState(const Unauthenticated());
    } catch (e) {
      _setState(AuthError(_getErrorMessage(e)));
    }
  }

  /// Solicitar recuperación de contraseña
  Future<bool> requestPasswordRecovery({required String numDocumento}) async {
    try {
      _setState(const AuthLoading());

      await _repository.requestPasswordRecovery(numDocumento: numDocumento);

      _setState(const Unauthenticated());
      return true;
    } catch (e) {
      _setState(AuthError(_getErrorMessage(e)));
      return false;
    }
  }

  /// Restablecer contraseña
  Future<bool> resetPassword({
    required String numDocumento,
    required String code,
    required String newPassword,
  }) async {
    try {
      _setState(const AuthLoading());

      await _repository.resetPassword(
        numDocumento: numDocumento,
        code: code,
        newPassword: newPassword,
      );

      _setState(const Unauthenticated());
      return true;
    } catch (e) {
      _setState(AuthError(_getErrorMessage(e)));
      return false;
    }
  }

  /// Cambiar contraseña
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      _setState(const AuthLoading());

      await _repository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      // Mantener el usuario autenticado después de cambiar la contraseña
      final currentUser = await _repository.getCurrentUser();
      if (currentUser != null) {
        _setState(Authenticated(currentUser));
      } else {
        _setState(const Unauthenticated());
      }
      return true;
    } catch (e) {
      // Restaurar el estado autenticado si hay error
      final currentUser = await _repository.getCurrentUser();
      if (currentUser != null) {
        _setState(Authenticated(currentUser));
      }
      _setState(AuthError(_getErrorMessage(e)));
      return false;
    }
  }

  /// Activar cuenta con token
  Future<Map<String, dynamic>> activateAccount(String token) async {
    try {
      final response = await _repository.activateAccount(token);
      return response;
    } catch (e) {
      return {'success': false, 'message': _getErrorMessage(e)};
    }
  }

  /// Reenviar email de activación
  Future<void> resendActivationEmail({
    required int codUser,
    required String numDocumento,
    required String correo,
    required String nombre,
  }) async {
    await _repository.resendActivationEmail(
      codUser: codUser,
      numDocumento: numDocumento,
      correo: correo,
      nombre: nombre,
    );
  }

  /// Verificar si una cuenta está inactiva
  /// Retorna los datos de la cuenta si está inactiva para poder reenviar el correo
  Future<Map<String, dynamic>> checkInactiveAccount({
    required String identifier,
  }) async {
    try {
      final result = await _repository.checkInactiveAccount(
        identifier: identifier,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener mensaje de error amigable
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('SocketException') ||
        errorString.contains('NetworkException')) {
      return 'Sin conexión a internet';
    }

    if (errorString.contains('TimeoutException') ||
        errorString.contains('Tiempo de conexión')) {
      return 'Tiempo de espera agotado';
    }

    if (errorString.contains('401') ||
        errorString.contains('Unauthorized') ||
        errorString.contains('credenciales')) {
      return 'Credenciales incorrectas';
    }

    if (errorString.contains('404')) {
      return 'Servicio no encontrado';
    }

    if (errorString.contains('500')) {
      return 'Error en el servidor';
    }

    // Intentar extraer el mensaje específico
    if (errorString.contains('Exception:')) {
      final parts = errorString.split('Exception:');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }

    return errorString.length > 100
        ? 'Error al procesar la solicitud'
        : errorString;
  }
}

/// Función helper para crear el provider
Future<AuthProvider> createAuthProvider() async {
  final prefs = await SharedPreferences.getInstance();
  final dioClient = DioClient();

  final remoteDataSource = AuthRemoteDataSourceImpl(dioClient: dioClient);
  final localDataSource = AuthLocalDataSourceImpl(prefs: prefs);

  final repository = AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  return AuthProvider(repository: repository);
}
