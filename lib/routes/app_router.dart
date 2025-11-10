import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Router de la aplicación
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

    // Home Screen
    GoRoute(
      path: RouteConstants.home,
      name: RouteConstants.homeName,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const HomeScreen()),
    ),

    // Settings Screen
    GoRoute(
      path: RouteConstants.settings,
      name: RouteConstants.settingsName,
      pageBuilder: (context, state) =>
          MaterialPage(key: state.pageKey, child: const SettingsScreen()),
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
