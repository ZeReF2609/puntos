import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';

/// Pantalla para cambiar contraseña
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    context.hideKeyboard();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.changePassword(
      oldPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (success && mounted) {
      context.showSuccessSnackBar('Contraseña actualizada correctamente');
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        GoRouter.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        final authState = authProvider.state;
        final isDark = themeProvider.isDarkMode;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (authState is AuthError) {
            context.showErrorSnackBar(authState.message);
          }
        });

        final isLoading = authState is AuthLoading;

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF121212)
              : AppColors.background,
          appBar: AppBar(
            backgroundColor: isDark
                ? const Color(0xFF1E1E1E)
                : AppColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => GoRouter.of(context).pop(),
            ),
            title: const Text(
              'Cambiar Contraseña',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1E1E1E),
                        const Color(0xFF121212),
                        const Color(0xFF0D0D0D),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withAlpha(13),
                        AppColors.themeColor2.withAlpha(20),
                        AppColors.background,
                        AppColors.themeBgVitrina.withAlpha(38),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Card(
                          elevation: 20,
                          shadowColor: isDark
                              ? Colors.black.withOpacity(0.5)
                              : AppColors.primary.withAlpha(38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 24 : 40),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF404040)
                                    : AppColors.primary.withAlpha(26),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withOpacity(0.3)
                                      : AppColors.primary.withAlpha(20),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: _buildForm(isLoading, isDark),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(bool isLoading, bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icono
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(71),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.lock_reset,
                size: 40,
                color: AppColors.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Título
          Text(
            'Cambiar Contraseña',
            style: isDark
                ? const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )
                : TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = AppColors.primaryGradient.createShader(
                        const Rect.fromLTWH(0, 0, 200, 0),
                      ),
                  ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Descripción
          Text(
            'Ingresa tu contraseña actual y la nueva contraseña que deseas utilizar.',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? const Color(0xFFB0B0B0)
                  : AppColors.textColorLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Campo de contraseña actual
          CustomTextField(
            controller: _currentPasswordController,
            labelText: 'Contraseña Actual',
            hintText: 'Ingresa tu contraseña actual',
            prefixIcon: Icons.lock_outline,
            suffixIconData: _obscureCurrentPassword
                ? Icons.visibility
                : Icons.visibility_off,
            onSuffixIconPressed: () {
              setState(() {
                _obscureCurrentPassword = !_obscureCurrentPassword;
              });
            },
            obscureText: _obscureCurrentPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La contraseña actual es requerida';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
          ),
          const SizedBox(height: 20),
          // Campo de nueva contraseña
          CustomTextField(
            controller: _newPasswordController,
            labelText: 'Nueva Contraseña',
            hintText: 'Ingresa tu nueva contraseña',
            prefixIcon: Icons.lock_outline,
            suffixIconData: _obscureNewPassword
                ? Icons.visibility
                : Icons.visibility_off,
            onSuffixIconPressed: () {
              setState(() {
                _obscureNewPassword = !_obscureNewPassword;
              });
            },
            obscureText: _obscureNewPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La nueva contraseña es requerida';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              if (value == _currentPasswordController.text) {
                return 'La nueva contraseña debe ser diferente a la actual';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
          ),
          const SizedBox(height: 20),
          // Campo de confirmar contraseña
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirmar Nueva Contraseña',
            hintText: 'Confirma tu nueva contraseña',
            prefixIcon: Icons.lock_outline,
            suffixIconData: _obscureConfirmPassword
                ? Icons.visibility
                : Icons.visibility_off,
            onSuffixIconPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            obscureText: _obscureConfirmPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Debes confirmar la nueva contraseña';
              }
              if (value != _newPasswordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleChangePassword(),
            enabled: !isLoading,
          ),
          const SizedBox(height: 32),
          // Mensaje de seguridad
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primary.withOpacity(0.15)
                  : AppColors.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
              border: isDark
                  ? Border.all(color: AppColors.primary.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tu contraseña debe tener al menos 6 caracteres',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.primary.withOpacity(0.9)
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Botón de cambiar contraseña
          _buildChangeButton(isLoading),
        ],
      ),
    );
  }

  Widget _buildChangeButton(bool isLoading) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(102),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.primary.withAlpha(51),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : _handleChangePassword,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.onPrimary,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.onPrimary,
                    size: 22,
                  ),
                const SizedBox(width: 12),
                Text(
                  isLoading ? 'Cambiando...' : 'Cambiar Contraseña',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
