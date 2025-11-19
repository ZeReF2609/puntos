import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/errors/exceptions.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

// Intent personalizado para manejar el envío del formulario
class SubmitFormIntent extends Intent {
  const SubmitFormIntent();
}

/// Pantalla de Login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();

  // Login controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Último mensaje de error mostrado (evita repetir snackbars)
  String? _lastAuthErrorMessage;

  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    // Ocultar teclado
    context.hideKeyboard();

    // Ejecutar login
    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on InactiveAccountException catch (e) {
      // Capturar excepción de cuenta inactiva y mostrar dialog
      if (mounted) {
        _showInactiveAccountDialog(e.message, e.userData);
      }
    }
  }

  /// Muestra dialog cuando la cuenta no está activa
  void _showInactiveAccountDialog(
    String message,
    Map<String, dynamic>? userData,
  ) {
    final email = userData?['correo'] as String? ?? '';
    final maskedEmail = email.isNotEmpty ? email.maskEmail : 'tu correo';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_unread_outlined,
                color: AppColors.warning,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Cuenta No Verificada',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tu cuenta aún no ha sido activada.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Text(
              'Por favor revisa tu correo electrónico y haz clic en el enlace de verificación.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            const Text(
              'Correo registrado:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      maskedEmail
                          .toUpperCase(), // Email en mayúsculas parcialmente oculto
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '¿No recibiste el correo? Puedes reenviarlo.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Cerrar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _resendActivationEmail(userData);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.send_rounded, size: 20),
            label: const Text(
              'Reenviar Correo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      ),
    );
  }

  /// Reenvía el email de activación
  Future<void> _resendActivationEmail(Map<String, dynamic>? userData) async {
    if (userData == null) return;

    try {
      // Mostrar loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Reenviando correo...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      final authProvider = context.read<AuthProvider>();
      await authProvider.resendActivationEmail(
        codUser: userData['codUser'],
        numDocumento: userData['numDocumento'],
        correo: userData['correo'],
        nombre: userData['nombre'] ?? 'Usuario',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      context.showSuccessSnackBar(
        '📧 Correo enviado exitosamente. Por favor revisa tu bandeja de entrada.',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      context.showErrorSnackBar(
        'Error al enviar el correo. Intenta nuevamente.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isSmallScreen = size.width < 600;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Escuchar cambios en el estado
        final authState = authProvider.state;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (authState is Authenticated) {
            // limpia el último error y navega
            _lastAuthErrorMessage = null;
            context.go(RouteConstants.home);
          } else if (authState is AuthError) {
            final msg = authState.message;
            // Mostrar snackbar sólo si el mensaje cambió desde la última vez
            if (msg != _lastAuthErrorMessage) {
              _lastAuthErrorMessage = msg;
              context.showErrorSnackBar(msg);
            }
          }
        });

        final isLoading = authState is AuthLoading;

        return Shortcuts(
          shortcuts: <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.enter): const SubmitFormIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              SubmitFormIntent: CallbackAction<SubmitFormIntent>(
                onInvoke: (SubmitFormIntent intent) => _handleLogin(),
              ),
            },
            child: Scaffold(
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
                            constraints: BoxConstraints(
                              maxWidth: isLandscape && !isSmallScreen
                                  ? 900
                                  : 500,
                            ),
                            child: Card(
                              elevation: 20,
                              shadowColor: AppColors.primary.withAlpha(38),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(
                                  isSmallScreen ? 24 : 40,
                                ),
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
                                child: isLandscape && !isSmallScreen
                                    ? _buildLandscapeLayout(isLoading)
                                    : _buildPortraitLayout(isLoading),
                              ),
                            ),
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

  Widget _buildLandscapeLayout(bool isLoading) {
    return Row(
      children: [
        // Lado izquierdo - Header
        Expanded(flex: 1, child: _buildHeader()),
        const SizedBox(width: 32),
        // Lado derecho - Formulario
        Expanded(
          flex: 1,
          child: Form(
            key: _loginFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLoginForm(isLoading),
                const SizedBox(height: 24),
                _buildLoginButton(isLoading),
                const SizedBox(height: 16),
                _buildRegisterLink(isLoading),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(bool isLoading) {
    return Form(
      key: _loginFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildLoginForm(isLoading),
          const SizedBox(height: 24),
          _buildLoginButton(isLoading),
          const SizedBox(height: 16),
          _buildRegisterLink(isLoading),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    const double blockHeight = 140.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 420;

        return SizedBox(
          height: blockHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo a la izquierda
              SizedBox(
                width: isNarrow ? 120 : 140,
                height: blockHeight,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Círculo de fondo animado
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.9 + (_animationController.value * 0.1),
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.primary.withAlpha(20),
                                    AppColors.primary.withAlpha(10),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        width: 92,
                        height: 92,
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
                            Icons.star_rounded,
                            size: 44,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 18),

              // Texto a la derecha
              Expanded(
                child: SizedBox(
                  height: blockHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título grande
                      Text(
                        '¡Bienvenido!',
                        style: TextStyle(
                          fontSize: isNarrow ? 22 : 30,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = AppColors.primaryGradient.createShader(
                              const Rect.fromLTWH(0, 0, 200, 0),
                            ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Puntos Pionier',
                        style: TextStyle(
                          fontSize: isNarrow ? 18 : 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.themeColor2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Acumula puntos con cada compra y canjéalos por premios exclusivos',
                        style: TextStyle(
                          fontSize: isNarrow ? 12 : 14,
                          color: AppColors.themeColor3,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Campo de Email/DNI
        CustomTextField(
          controller: _emailController,
          labelText: 'Email o DNI',
          hintText: 'correo@ejemplo.com o 12345678',
          prefixIcon: Icons.person_outline,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
            LengthLimitingTextInputFormatter(255),
          ],
          onChanged: (value) {
            if (value.length > 255) {
              final trimmed = value.substring(0, 255);
              _emailController.value = TextEditingValue(
                text: trimmed,
                selection: TextSelection.collapsed(offset: trimmed.length),
              );
            }
            // limpiar último mensaje de error al modificar el campo
            _lastAuthErrorMessage = null;
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Campo requerido';
            }
            return null;
          },
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
        ),
        const SizedBox(height: 20),
        // Campo de contraseña
        CustomTextField(
          controller: _passwordController,
          labelText: 'Contraseña',
          hintText: 'Ingresa tu contraseña',
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
          onChanged: (_) {
            // limpiar último mensaje de error al modificar la contraseña
            _lastAuthErrorMessage = null;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La contraseña es requerida';
            }
            if (value.length < 3) {
              return 'La contraseña debe tener al menos 3 caracteres';
            }
            return null;
          },
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
          enabled: !isLoading,
        ),
        const SizedBox(height: 16),
        // Recordar sesión
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Text(
              'Recordar sesión',
              style: TextStyle(color: AppColors.textColorLight, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Botón de olvidaste tu contraseña
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: isLoading
                ? null
                : () => context.push('/forgot-password'),
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink(bool isLoading) {
    return Column(
      children: [
        // Divisor con texto
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppColors.primary.withAlpha(51),
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'o',
                style: TextStyle(
                  color: AppColors.textColorLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.primary.withAlpha(51),
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Botón para ir a registro
        Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isLoading
                  ? null
                  : () => context.push(RouteConstants.register),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '¿No tienes cuenta? Regístrate',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(bool isLoading) {
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
          onTap: isLoading ? null : _handleLogin,
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
                    Icons.login_rounded,
                    color: AppColors.onPrimary,
                    size: 22,
                  ),
                const SizedBox(width: 12),
                Text(
                  isLoading ? 'Iniciando sesión...' : 'Iniciar Sesión',
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
