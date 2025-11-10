import 'package:flutter/material.dart';
import '../../features/auth/auth.dart';
import '../../shared/screens/splash_screen.dart';
import '../../features/home/home_page.dart';
import '../guards/auth_guard.dart';

class AppRoutes {
  static const String initial = '/splash';

  static final Map<String, WidgetBuilder> routes = {
    // =====================================================
    // RUTAS PÚBLICAS (No requieren autenticación)
    // =====================================================
    '/splash': (context) => GuestGuard(child: const SplashScreen()),
    '/login': (context) => GuestGuard(child: const LoginPage()),

    // =====================================================
    // RUTAS PROTEGIDAS (Requieren autenticación)
    // =====================================================
    '/home': (context) => AuthGuard(child: const HomePage()),
  };
}

/// Información de ruta para mapeo con permisos
class RouteInfo {
  final String menu;
  final String submenu;
  final List<String> actions;

  const RouteInfo({
    required this.menu,
    required this.submenu,
    required this.actions,
  });
}
