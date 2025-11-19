import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

/// Pantalla para restablecer contraseña con código
class ResetPasswordScreen extends StatefulWidget {
  final String? numDocumento;

  const ResetPasswordScreen({super.key, this.numDocumento});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
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
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.numDocumento == null) {
      context.showErrorSnackBar('Número de documento no proporcionado');
      return;
    }

    context.hideKeyboard();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(
      numDocumento: widget.numDocumento!,
      code: _codeController.text.trim(),
      newPassword: _passwordController.text,
    );

    if (success && mounted) {
      context.showSuccessSnackBar('Contraseña restablecida correctamente');
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        context.go(RouteConstants.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final authState = authProvider.state;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (authState is AuthError) {
            context.showErrorSnackBar(authState.message);
          }
        });

        final isLoading = authState is AuthLoading;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => GoRouter.of(context).pop(),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
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
                          shadowColor: AppColors.primary.withAlpha(38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 24 : 40),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: AppColors.primary.withAlpha(26),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(20),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: _buildResetForm(isLoading),
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

  Widget _buildResetForm(bool isLoading) {
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
              child: Icon(Icons.vpn_key, size: 40, color: AppColors.onPrimary),
            ),
          ),
          const SizedBox(height: 24),
          // Título
          Text(
            'Restablecer Contraseña',
            style: TextStyle(
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
            'Ingresa el código que recibiste en tu correo y tu nueva contraseña.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textColorLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Campo de código
          CustomTextField(
            controller: _codeController,
            labelText: 'Código de Recuperación',
            hintText: '123456',
            prefixIcon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El código es requerido';
              }
              if (value.length != 6) {
                return 'El código debe tener 6 dígitos';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
          ),
          const SizedBox(height: 20),
          // Campo de nueva contraseña
          CustomTextField(
            controller: _passwordController,
            labelText: 'Nueva Contraseña',
            hintText: 'Ingresa tu nueva contraseña',
            prefixIcon: Icons.lock_outline,
            suffixIconData: _obscurePassword
                ? Icons.visibility
                : Icons.visibility_off,
            onSuffixIconPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La contraseña es requerida';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
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
            labelText: 'Confirmar Contraseña',
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
                return 'Debes confirmar la contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleReset(),
            enabled: !isLoading,
          ),
          const SizedBox(height: 32),
          // Botón de restablecer
          _buildResetButton(isLoading),
        ],
      ),
    );
  }

  Widget _buildResetButton(bool isLoading) {
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
          onTap: isLoading ? null : _handleReset,
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
                  isLoading ? 'Restableciendo...' : 'Restablecer Contraseña',
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
