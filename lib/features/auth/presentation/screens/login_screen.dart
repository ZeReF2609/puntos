import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

/// Pantalla de Login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Ocultar teclado
    context.hideKeyboard();

    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Ejecutar login
    await context.read<AuthProvider>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _goToRegister() {
    context.push(RouteConstants.register);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Escuchar cambios en el estado
        final authState = authProvider.state;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (authState is Authenticated) {
            context.go(RouteConstants.home);
          } else if (authState is AuthError) {
            context.showErrorSnackBar(authState.message);
          }
        });

        final isLoading = authState is AuthLoading;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),

                    // Logo o Título
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Bienvenido',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Inicia sesión para continuar',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Campo de email/DNI
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email o DNI',
                      hintText: 'correo@ejemplo.com o 12345678',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Campo de password
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Contraseña',
                      hintText: '••••••••',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outline,
                      validator: Validators.password,
                      enabled: !isLoading,
                      onSubmitted: (_) => _handleLogin(),
                    ),

                    const SizedBox(height: 24),

                    // Botón de login
                    CustomButton(
                      text: 'Iniciar Sesión',
                      onPressed: isLoading ? null : _handleLogin,
                      isLoading: isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Botón para ir a registro
                    CustomButton(
                      text: 'Crear Cuenta',
                      onPressed: isLoading ? null : _goToRegister,
                      isOutlined: true,
                    ),

                    const SizedBox(height: 24),

                    // Link de recuperar contraseña
                    Center(
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                // TODO: Implementar recuperación de contraseña
                                context.showSnackBar(
                                  'Recuperar contraseña (próximamente)',
                                );
                              },
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: isLoading ? Colors.grey : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
