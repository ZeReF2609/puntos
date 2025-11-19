import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/providers/auth_state.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/account_pending_screen.dart';
import '../features/auth/presentation/screens/activate_account_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/change_password_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Crear el router con el AuthProvider para manejar redirecciones
GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteConstants.splash,
    debugLogDiagnostics: true,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final authState = authProvider.state;
      final isAuthenticated = authState is Authenticated;
      final isAuthenticating = authState is AuthLoading;
      final isRegistered = authState is Registered;
      final isOnSplash = state.matchedLocation == RouteConstants.splash;
      final isOnLogin = state.matchedLocation == RouteConstants.login;
      final isOnRegister = state.matchedLocation == RouteConstants.register;
      final isOnForgotPassword = state.matchedLocation == '/forgot-password';
      final isOnResetPassword = state.matchedLocation == '/reset-password';
      final isOnPendingReview =
          state.matchedLocation == RouteConstants.pendingReview;

      // Si está en splash, dejar que continúe
      if (isOnSplash) {
        return null;
      }

      // Si está autenticando, no redirigir
      if (isAuthenticating) {
        return null;
      }

      // Si el usuario se acaba de registrar, permitir acceso a pendingReview
      if (isRegistered) {
        if (!isOnPendingReview) {
          return RouteConstants.pendingReview;
        }
        return null;
      }

      // Si está en la pantalla pendingReview sin estar registrado, ir a login
      if (isOnPendingReview && !isRegistered) {
        return RouteConstants.login;
      }

      // Si NO está autenticado y NO está en login/register/forgot/reset/pending, ir a login
      if (!isAuthenticated &&
          !isOnLogin &&
          !isOnRegister &&
          !isOnForgotPassword &&
          !isOnResetPassword &&
          !isOnPendingReview) {
        return RouteConstants.login;
      }

      // Si está autenticado y está en login/register/forgot/reset, ir a home
      if (isAuthenticated &&
          (isOnLogin ||
              isOnRegister ||
              isOnForgotPassword ||
              isOnResetPassword)) {
        return RouteConstants.home;
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: RouteConstants.splash,
        name: RouteConstants.splashName,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SplashScreen()),
      ),

      // Login Screen
      GoRoute(
        path: RouteConstants.login,
        name: RouteConstants.loginName,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const LoginScreen()),
      ),

      // Register Screen
      GoRoute(
        path: RouteConstants.register,
        name: RouteConstants.registerName,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const RegisterScreen()),
      ),

      // Forgot Password Screen
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),

      // Reset Password Screen
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        pageBuilder: (context, state) {
          final numDocumento = state.extra as String?;
          return MaterialPage(
            key: state.pageKey,
            child: ResetPasswordScreen(numDocumento: numDocumento),
          );
        },
      ),

      // Change Password Screen
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ChangePasswordScreen(),
        ),
      ),

      // Account pending review screen
      GoRoute(
        path: RouteConstants.pendingReview,
        name: RouteConstants.pendingReviewName,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AccountPendingScreen(),
        ),
      ),

      // Account activation screen (deep link)
      GoRoute(
        path: '/activate/:token',
        name: 'activate',
        pageBuilder: (context, state) {
          final token = state.pathParameters['token'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: ActivateAccountScreen(token: token),
          );
        },
      ),

      // Home Screen
      GoRoute(
        path: RouteConstants.home,
        name: RouteConstants.homeName,
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const HomeScreen()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'La página que buscas no existe.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteConstants.home),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Router legacy (mantener para compatibilidad)
final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteConstants.splash,
  debugLogDiagnostics: true,
  routes: [
    // Splash Screen
    GoRoute(
      path: RouteConstants.splash,
      name: RouteConstants.splashName,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const SplashScreen()),
    ),

    // Login Screen
    GoRoute(
      path: RouteConstants.login,
      name: RouteConstants.loginName,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const LoginScreen()),
    ),

    // Register Screen
    GoRoute(
      path: RouteConstants.register,
      name: RouteConstants.registerName,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const RegisterScreen()),
    ),

    // Forgot Password Screen
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const ForgotPasswordScreen()),
    ),

    // Reset Password Screen
    GoRoute(
      path: '/reset-password',
      name: 'reset-password',
      pageBuilder: (context, state) {
        final numDocumento = state.extra as String?;
        return MaterialPage(
          key: state.pageKey,
          child: ResetPasswordScreen(numDocumento: numDocumento),
        );
      },
    ),

    // Change Password Screen
    GoRoute(
      path: '/change-password',
      name: 'change-password',
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const ChangePasswordScreen()),
    ),

    // Account pending review screen
    GoRoute(
      path: RouteConstants.pendingReview,
      name: RouteConstants.pendingReviewName,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const AccountPendingScreen()),
    ),

    // Account activation screen (deep link)
    GoRoute(
      path: '/activate/:token',
      name: 'activate-legacy',
      pageBuilder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        return MaterialPage(
          key: state.pageKey,
          child: ActivateAccountScreen(token: token),
        );
      },
    ),

    // Home Screen
    GoRoute(
      path: RouteConstants.home,
      name: RouteConstants.homeName,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const HomeScreen()),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Página no encontrada',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'La página que buscas no existe.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(RouteConstants.home),
            child: const Text('Ir al inicio'),
          ),
        ],
      ),
    ),
  ),
);
