import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../app/constants/app_colors.dart';
import '../../shared/widgets/custom_text_field.dart';
import 'auth_provider.dart';

// Intent personalizado para manejar el envío del formulario
class SubmitFormIntent extends Intent {
  const SubmitFormIntent();
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login controllers
  final _dniLoginController = TextEditingController();
  final _passwordController = TextEditingController();

  // Register controllers
  final _emailController = TextEditingController();
  final _dniController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureRegPassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;
  bool _isLoginMode = true;

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
    _dniLoginController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _dniController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _regPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _dniLoginController.text,
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Error de autenticación',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        );
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registro completado exitosamente (Demo)'),
        backgroundColor: Colors.green,
      ),
    );

    // Limpiar formulario
    _emailController.clear();
    _dniController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _regPasswordController.clear();
    _confirmPasswordController.clear();

    // Volver al modo login
    setState(() {
      _isLoginMode = true;
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 3) {
      return 'La contraseña debe tener al menos 3 caracteres';
    }
    return null;
  }

  // Validadores para registro
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es requerido';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  String? _validateDni(String? value) {
    if (value == null || value.isEmpty) {
      return 'El DNI es requerido';
    }
    if (value.length != 8 || !RegExp(r'^\d+$').hasMatch(value)) {
      return 'El DNI debe tener 8 dígitos';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
    if (value.length < 2) {
      return 'Debe tener al menos 2 caracteres';
    }
    return null;
  }

  String? _validateRegPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != _regPasswordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isSmallScreen = size.width < 600;

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.enter): const SubmitFormIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SubmitFormIntent: CallbackAction<SubmitFormIntent>(
            onInvoke: (SubmitFormIntent intent) =>
                _isLoginMode ? _handleLogin() : _handleRegister(),
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
                          maxWidth: isLandscape && !isSmallScreen ? 900 : 500,
                        ),
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
                            child: isLandscape && !isSmallScreen
                                ? _buildLandscapeLayout()
                                : _buildPortraitLayout(),
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
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // Lado izquierdo - Header
        Expanded(flex: 1, child: _buildHeader()),
        const SizedBox(width: 32),
        // Lado derecho - Formulario
        Expanded(
          flex: 1,
          child: Form(
            key: _isLoginMode ? _loginFormKey : _registerFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModeToggle(),
                const SizedBox(height: 24),
                _isLoginMode ? _buildLoginForm() : _buildRegisterForm(),
                const SizedBox(height: 24),
                _isLoginMode ? _buildLoginButton() : _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout() {
    return Form(
      key: _isLoginMode ? _loginFormKey : _registerFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildModeToggle(),
          const SizedBox(height: 24),
          _isLoginMode ? _buildLoginForm() : _buildRegisterForm(),
          const SizedBox(height: 24),
          _isLoginMode ? _buildLoginButton() : _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary.withAlpha(38), width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: _buildToggleButton(
                'Iniciar Sesión',
                _isLoginMode,
                Icons.login,
                () {
                  setState(() => _isLoginMode = true);
                },
              ),
            ),
            Flexible(
              child: _buildToggleButton(
                'Registrarse',
                !_isLoginMode,
                Icons.person_add,
                () {
                  setState(() => _isLoginMode = false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
    String text,
    bool isActive,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(76),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.onPrimary : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: isActive ? AppColors.onPrimary : AppColors.primary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Logo (izquierda) y textos (derecha) en una fila. Ambos tendrán la misma altura
    // para mantener simetría. El ancho se adapta según el espacio disponible.
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
                          fontSize: isNarrow ? 26 : 32,
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

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Campo de DNI
        CustomTextField(
          controller: _dniLoginController,
          labelText: 'DNI',
          hintText: 'Ingresa tu número de DNI',
          prefixIcon: Icons.badge_outlined,
          validator: _validateDni,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        // Campo de contraseña
        CustomTextField(
          controller: _passwordController,
          labelText: 'Contraseña',
          hintText: 'Ingresa tu contraseña',
          prefixIcon: Icons.lock_outline,
          suffixIcon: _obscurePassword
              ? Icons.visibility
              : Icons.visibility_off,
          onSuffixIconPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          obscureText: _obscurePassword,
          validator: _validatePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleLogin(),
        ),
        const SizedBox(height: 16),
        // Recordar sesión
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
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
        // Enlace para registrarse con mejor diseño
        if (_isLoginMode)
          Container(
            margin: const EdgeInsets.only(top: 16),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  '¿No tienes cuenta? ',
                  style: TextStyle(
                    color: AppColors.textColorLight,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isLoginMode = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Regístrate aquí',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email
        CustomTextField(
          controller: _emailController,
          labelText: 'Correo Electrónico',
          hintText: 'Ingresa tu correo electrónico',
          prefixIcon: Icons.email_outlined,
          validator: _validateEmail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        // DNI
        CustomTextField(
          controller: _dniController,
          labelText: 'DNI',
          hintText: 'Ingresa tu número de DNI',
          prefixIcon: Icons.badge_outlined,
          validator: _validateDni,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        // Nombres
        CustomTextField(
          controller: _firstNameController,
          labelText: 'Nombres',
          hintText: 'Ingresa tus nombres',
          prefixIcon: Icons.person_outline,
          validator: _validateName,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        // Apellidos
        CustomTextField(
          controller: _lastNameController,
          labelText: 'Apellidos',
          hintText: 'Ingresa tus apellidos',
          prefixIcon: Icons.person_outline,
          validator: _validateName,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        // Contraseña
        CustomTextField(
          controller: _regPasswordController,
          labelText: 'Contraseña',
          hintText: 'Crea una contraseña',
          prefixIcon: Icons.lock_outline,
          suffixIcon: _obscureRegPassword
              ? Icons.visibility
              : Icons.visibility_off,
          onSuffixIconPressed: () {
            setState(() {
              _obscureRegPassword = !_obscureRegPassword;
            });
          },
          obscureText: _obscureRegPassword,
          validator: _validateRegPassword,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        // Confirmar contraseña
        CustomTextField(
          controller: _confirmPasswordController,
          labelText: 'Confirmar Contraseña',
          hintText: 'Confirma tu contraseña',
          prefixIcon: Icons.lock_outline,
          suffixIcon: _obscureConfirmPassword
              ? Icons.visibility
              : Icons.visibility_off,
          onSuffixIconPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
          obscureText: _obscureConfirmPassword,
          validator: _validateConfirmPassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleRegister(),
        ),
        const SizedBox(height: 16),
        // Ya tienes cuenta
        Container(
          margin: const EdgeInsets.only(top: 16),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              const Text(
                '¿Ya tienes cuenta? ',
                style: TextStyle(color: AppColors.textColorLight, fontSize: 14),
              ),
              GestureDetector(
                onTap: () => setState(() => _isLoginMode = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Inicia sesión',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
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
              onTap: authProvider.isLoading ? null : _handleLogin,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (authProvider.isLoading)
                      SizedBox(
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
                      Icon(
                        Icons.login_rounded,
                        color: AppColors.onPrimary,
                        size: 22,
                      ),
                    const SizedBox(width: 12),
                    Text(
                      authProvider.isLoading
                          ? 'Iniciando sesión...'
                          : 'Iniciar Sesión',
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
      },
    );
  }

  Widget _buildRegisterButton() {
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
          onTap: _handleRegister,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_add_rounded,
                  color: AppColors.onPrimary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Crear Cuenta',
                  style: TextStyle(
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
