import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/auth_provider.dart';

/// Widget que protege rutas requiriendo autenticación
class AuthGuard extends StatelessWidget {
  final Widget child;
  final String? redirectTo;

  const AuthGuard({
    super.key,
    required this.child,
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Si está cargando datos de autenticación, mostrar loading
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si está autenticado, mostrar el contenido
        if (authProvider.isAuthenticated) {
          return child;
        }

        // Si no está autenticado, redirigir al login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(
            context, 
            redirectTo ?? '/login',
          );
        });

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

/// Widget que redirige a home si ya está autenticado (para login/splash)
class GuestGuard extends StatelessWidget {
  final Widget child;
  final String? redirectTo;

  const GuestGuard({
    super.key,
    required this.child,
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Si está cargando, mostrar el contenido (splash screen)
        if (authProvider.isLoading) {
          return child;
        }

        // Si ya está autenticado, redirigir a home
        if (authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(
              context, 
              redirectTo ?? '/home',
            );
          });
          
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si no está autenticado, mostrar el contenido (login)
        return child;
      },
    );
  }
}
