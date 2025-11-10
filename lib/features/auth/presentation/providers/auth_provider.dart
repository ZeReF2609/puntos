import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
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
      _setState(const Unauthenticated());
    }
  }

  /// Login
  Future<void> login({required String email, required String password}) async {
    try {
      _setState(const AuthLoading());

      final user = await _repository.login(
        numDocumento: email,
        password: password,
      );

      _setState(Authenticated(user));
    } catch (e) {
      _setState(AuthError(_getErrorMessage(e)));
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

      // Después del registro, hacer login automáticamente
      await login(email: numDocumento, password: password);
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
