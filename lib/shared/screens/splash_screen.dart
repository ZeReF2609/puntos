import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../app/constants/app_colors.dart';
import '../../features/auth/auth_provider.dart';
import '../services/version_service.dart';
import '../widgets/version_update_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _versionService = VersionService();

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 SplashScreen initState iniciado');
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Solo navegar cuando la animación ha terminado
    _controller.addStatusListener((status) {
      debugPrint('🎬 Animation status: $status');
      if (status == AnimationStatus.completed) {
        debugPrint(
          '🎯 Animación completada - iniciando verificación de versión',
        );
        _checkVersionAndNavigate();
      }
    });
  }

  // Método para verificar versión y navegar
  void _checkVersionAndNavigate() async {
    // Verificar que el widget aún esté montado antes de continuar
    if (!mounted) return;

    // Esperamos un momento corto después de que termina la animación
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return; // Verificar nuevamente después del delay

    try {
      debugPrint('🔍 Iniciando verificación de versión en splash...');

      // Verificar si se debe mostrar el diálogo de actualización
      final shouldShowUpdate = await _versionService.shouldShowUpdateDialog();

      debugPrint('📋 Resultado verificación versión: $shouldShowUpdate');

      if (!mounted) return; // Verificar una vez más antes de navegar

      // Si necesita actualización, mostrar pantalla de actualización
      if (shouldShowUpdate) {
        debugPrint('🔄 Navegando a pantalla de actualización...');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VersionUpdateDialog()),
        );
        return;
      }

      debugPrint('✅ Versión OK - navegando a página principal...');
      // Si no necesita actualización, continuar con la navegación normal
      _navigateToNextPage();
    } catch (e) {
      debugPrint('❌ Error verificando versión en splash: $e');
      // En caso de error, continuar con la navegación normal
      if (mounted) {
        _navigateToNextPage();
      }
    }
  }

  // Método para manejar la transición suave hacia la página correcta
  void _navigateToNextPage() {
    // Verificar que el widget aún esté montado antes de navegar
    if (!mounted) return;

    debugPrint('🧭 Iniciando navegación desde splash...');

    // Esperamos un momento corto después de que termina la animación
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return; // Verificar nuevamente después del delay

      // Verificar el estado de autenticación
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      debugPrint('🔐 Estado de autenticación: ${authProvider.isAuthenticated}');

      // Redirigir según el estado de autenticación
      if (authProvider.isAuthenticated) {
        debugPrint('➡️ Navegando a /home');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        debugPrint('➡️ Navegando a /login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco como solicitaste
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animación Lottie controlada con fallback
              SizedBox(
                width: screenSize.width < 600 ? screenSize.width * 0.8 : 400,
                height: screenSize.width < 600 ? screenSize.width * 0.8 : 400,
                child: Lottie.asset(
                  'assets/anim/loading.json',
                  controller: _controller,
                  onLoaded: (composition) {
                    // Configura el controlador con la duración correcta de la animación
                    _controller.duration = composition.duration;
                    // Inicia la animación
                    _controller.forward();
                  },
                  fit: BoxFit.contain,
                  // Fallback en caso de que no se pueda cargar la animación
                  errorBuilder: (context, error, stackTrace) {
                    // Iniciar la animación manualmente si hay error
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _controller.forward();
                    });

                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.themeColor1.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.factory,
                            size: 100,
                            color: AppColors.themeColor1,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'PionierFactory',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.themeColor2,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Texto de carga con el estilo de la aplicación
              Text(
                'Cargando...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.themeColor2,
                ),
              ),
              const SizedBox(height: 10),
              // Pequeño indicador de progreso para dar feedback visual adicional
              SizedBox(
                width: 50,
                height: 5,
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.themeColor1,
                  ),
                  backgroundColor: AppColors.themeGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
