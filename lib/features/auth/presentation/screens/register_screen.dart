import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

// Intent personalizado para manejar el envío del formulario
class SubmitFormIntent extends Intent {
  const SubmitFormIntent();
}

/// Pantalla de Registro
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _tipoDocumentoController = TextEditingController(
    text: '01',
  ); // DNI por defecto
  final _numDocumentoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apePaternoController = TextEditingController();
  final _apeMaternoController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedTipoDocumento = '01'; // DNI por defecto
  int _currentStep = 0; // paso oculto
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  // Notifier for reactive full-name preview (acts like a light 'signal')
  final ValueNotifier<String> _fullNameNotifier = ValueNotifier<String>(
    'Completa los campos arriba',
  );
  // Notifiers for reactive contact previews
  final ValueNotifier<String> _emailNotifier = ValueNotifier<String>(
    'No especificado',
  );
  final ValueNotifier<String> _phoneNotifier = ValueNotifier<String>(
    'No especificado',
  );

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Tipos de documento
  final List<Map<String, String>> _tiposDocumento = [
    {'codigo': '01', 'nombre': 'DNI'},
    {'codigo': '02', 'nombre': 'CE'},
  ];

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
    // Update full name live when any name field changes
    _nombreController.addListener(_updateFullName);
    _apePaternoController.addListener(_updateFullName);
    _apeMaternoController.addListener(_updateFullName);
    // Update contact previews live
    _correoController.addListener(_updateEmail);
    _telefonoController.addListener(_updatePhone);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tipoDocumentoController.dispose();
    _numDocumentoController.dispose();
    _nombreController.dispose();
    _apePaternoController.dispose();
    _apeMaternoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreController.removeListener(_updateFullName);
    _apePaternoController.removeListener(_updateFullName);
    _apeMaternoController.removeListener(_updateFullName);
    _correoController.removeListener(_updateEmail);
    _telefonoController.removeListener(_updatePhone);
    _emailNotifier.dispose();
    _phoneNotifier.dispose();
    _fullNameNotifier.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Ocultar teclado
    context.hideKeyboard();

    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await context.read<AuthProvider>().register(
      tipoDocumento: _selectedTipoDocumento,
      numDocumento: _numDocumentoController.text.trim(),
      nombre: _nombreController.text.trim(),
      apePaterno: _apePaternoController.text.trim(),
      apeMaterno: _apeMaternoController.text.trim(),
      correo: _correoController.text.trim(),
      telefono: _telefonoController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final authState = authProvider.state;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (authState is Authenticated) {
            context.go(RouteConstants.home);
          } else if (authState is Registered) {
            // Al completar el registro, mostrar pantalla indicando que la cuenta está pendiente de revisión
            context.go(RouteConstants.pendingReview);
          } else if (authState is AuthError) {
            context.showErrorSnackBar(authState.message);
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
                onInvoke: (SubmitFormIntent intent) => _handleRegister(),
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
                  child: Column(
                    children: [
                      // Header con botón de retroceso
                      _buildHeader(isLoading),
                      // Contenido con scroll
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 600,
                                ),
                                child: Card(
                                  elevation: 20,
                                  shadowColor: AppColors.primary.withAlpha(38),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      isSmallScreen ? 24 : 32,
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
                                          color: AppColors.primary.withAlpha(
                                            20,
                                          ),
                                          blurRadius: 30,
                                          offset: const Offset(0, 15),
                                        ),
                                      ],
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Mostrar solo la sección actual (multi-paso oculto)
                                          _buildCurrentStepContent(isLoading),
                                          const SizedBox(height: 24),
                                          _buildNavigationButtons(isLoading),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear Cuenta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = AppColors.primaryGradient.createShader(
                        const Rect.fromLTWH(0, 0, 200, 0),
                      ),
                  ),
                ),
                Text(
                  'Completa tus datos para crear tu cuenta',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textColorLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // We show the entire registration form in a single vertical layout.

  Widget _buildDocumentStep(bool isLoading) {
    return Column(
      children: [
        _buildSectionTitle(
          'Datos de Identificación',
          'Ingresa tu documento de identidad',
          Icons.badge_rounded,
        ),
        const SizedBox(height: 24),
        // Selector de tipo de documento (vertical)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withAlpha(26)),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedTipoDocumento,
            isExpanded: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            items: _tiposDocumento.map((tipo) {
              final codigo = tipo['codigo']!;
              final nombre = tipo['nombre']!;
              return DropdownMenuItem<String>(
                value: codigo,
                child: Text(
                  nombre,
                  style: TextStyle(
                    color: _selectedTipoDocumento == codigo
                        ? AppColors.primary
                        : AppColors.themeColor2,
                    fontWeight: _selectedTipoDocumento == codigo
                        ? FontWeight.w600
                        : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            onChanged: isLoading
                ? null
                : (val) {
                    setState(() {
                      _selectedTipoDocumento = val!;
                      _tipoDocumentoController.text = val;
                      _numDocumentoController.clear();
                    });
                  },
          ),
        ),
        const SizedBox(height: 20),
        // Configure inputFormatters based on document type: digits-only for DNI/RUC,
        // alphanumeric (no spaces/special chars) for others.
        Builder(
          builder: (context) {
            List<TextInputFormatter> docInputFormatters;
            if (_selectedTipoDocumento == '01') {
              // DNI: exactly digits, limit 8
              docInputFormatters = [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ];
            } else if (_selectedTipoDocumento == '03') {
              // RUC: digits only, limit 11
              docInputFormatters = [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ];
            } else {
              // CE / PASAPORTE / others: allow letters and digits only (no spaces, no special chars)
              docInputFormatters = [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(50),
              ];
            }

            return CustomTextField(
              controller: _numDocumentoController,
              labelText: 'Número de documento',
              hintText: _selectedTipoDocumento == '01'
                  ? '12345678'
                  : _selectedTipoDocumento == '03'
                  ? '12345678901'
                  : 'Ingresa tu documento',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.assignment_ind_outlined,
              inputFormatters: docInputFormatters,
              onChanged: (value) {
                // sanitize pasted input: remove any non-alphanumeric characters
                final pattern = RegExp(r'[^A-Za-z0-9]');
                final sanitized = value.replaceAll(pattern, '');
                if (sanitized != value) {
                  _numDocumentoController.value = TextEditingValue(
                    text: sanitized,
                    selection: TextSelection.collapsed(
                      offset: sanitized.length,
                    ),
                  );
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu número de documento';
                }
                if (_selectedTipoDocumento == '01' && value.length != 8) {
                  return 'El DNI debe tener 8 dígitos';
                }
                if (_selectedTipoDocumento == '03' && value.length != 11) {
                  return 'El RUC debe tener 11 dígitos';
                }
                if (_selectedTipoDocumento == '02' && value.length < 8) {
                  return 'El CE debe tener al menos 8 caracteres';
                }
                if (_selectedTipoDocumento == '04' && value.length < 6) {
                  return 'El pasaporte debe tener al menos 6 caracteres';
                }
                return null;
              },
              enabled: !isLoading,
            );
          },
        ),
        const SizedBox(height: 16),
        // Información adicional
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _getDocumentInfo(),
                  style: TextStyle(fontSize: 12, color: AppColors.themeColor2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepContent(bool isLoading) {
    switch (_currentStep) {
      case 0:
        return _buildDocumentStep(isLoading);
      case 1:
        return _buildPersonalStep(isLoading);
      case 2:
        return _buildContactStep(isLoading);
      case 3:
        return _buildSecurityStep(isLoading);
      default:
        return _buildDocumentStep(isLoading);
    }
  }

  String _getDocumentInfo() {
    switch (_selectedTipoDocumento) {
      case '01':
        return 'Documento Nacional de Identidad (8 dígitos)';
      case '02':
        return 'Carné de Extranjería';
      case '03':
        return 'Registro Único de Contribuyentes (11 dígitos)';
      case '04':
        return 'Pasaporte internacional';
      default:
        return 'Selecciona tu tipo de documento';
    }
  }

  Widget _buildPersonalStep(bool isLoading) {
    return Column(
      children: [
        _buildSectionTitle(
          'Datos Personales',
          'Cuéntanos quién eres',
          Icons.person_rounded,
        ),
        const SizedBox(height: 24),
        // Nombre con icono especial
        CustomTextField(
          controller: _nombreController,
          labelText: 'Nombre(s)',
          hintText: 'Juan Carlos',
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.account_circle_outlined,
          validator: Validators.name,
          enabled: !isLoading,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÀ-ÿ\s']")),
            LengthLimitingTextInputFormatter(100),
          ],
          onChanged: (v) {
            if (v.length > 100) {
              final trimmed = v.substring(0, 100);
              _nombreController.value = TextEditingValue(
                text: trimmed,
                selection: TextSelection.collapsed(offset: trimmed.length),
              );
            }
          },
        ),
        const SizedBox(height: 20),
        // Apellidos en una fila para dispositivos grandes
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _apePaternoController,
                labelText: 'Apellido paterno',
                hintText: 'Pérez',
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.person_outline,
                validator: Validators.name,
                enabled: !isLoading,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÀ-ÿ\s']")),
                  LengthLimitingTextInputFormatter(100),
                ],
                onChanged: (v) {
                  if (v.length > 100) {
                    final trimmed = v.substring(0, 100);
                    _apePaternoController.value = TextEditingValue(
                      text: trimmed,
                      selection: TextSelection.collapsed(
                        offset: trimmed.length,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _apeMaternoController,
          labelText: 'Apellido materno',
          hintText: 'García',
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.done,
          prefixIcon: Icons.person_outline,
          validator: Validators.name,
          enabled: !isLoading,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÀ-ÿ\s']")),
            LengthLimitingTextInputFormatter(100),
          ],
          onChanged: (v) {
            if (v.length > 100) {
              final trimmed = v.substring(0, 100);
              _apeMaternoController.value = TextEditingValue(
                text: trimmed,
                selection: TextSelection.collapsed(offset: trimmed.length),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        // Previsualización del nombre completo
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primary.withAlpha(26),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(51),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.badge, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu nombre completo:',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textColorLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ValueListenableBuilder<String>(
                      valueListenable: _fullNameNotifier,
                      builder: (context, value, child) {
                        return Text(
                          value,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.themeColor2,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateFullName() {
    final nombre = _nombreController.text.trim();
    final paterno = _apePaternoController.text.trim();
    final materno = _apeMaternoController.text.trim();
    final parts = [
      nombre,
      paterno,
      materno,
    ].where((s) => s.isNotEmpty).toList();
    _fullNameNotifier.value = parts.isEmpty
        ? 'Completa los campos arriba'
        : parts.join(' ');
  }

  void _updateEmail() {
    final raw = _correoController.text.trim();
    _emailNotifier.value = raw.isEmpty ? 'No especificado' : raw;
  }

  void _updatePhone() {
    final raw = _telefonoController.text.trim();
    _phoneNotifier.value = raw.isEmpty ? 'No especificado' : raw;
  }

  Widget _buildContactStep(bool isLoading) {
    return Column(
      children: [
        _buildSectionTitle(
          'Datos de Contacto',
          '¿Cómo podemos comunicarnos contigo?',
          Icons.contact_mail_rounded,
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _correoController,
          labelText: 'Correo electrónico',
          hintText: 'juan.perez@email.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.email_outlined,
          validator: Validators.email,
          inputFormatters: [
            // deny any whitespace and limit length to 250
            FilteringTextInputFormatter.deny(RegExp(r"\s")),
            LengthLimitingTextInputFormatter(250),
          ],
          onChanged: (value) {
            // sanitize pasted input: remove whitespace
            final sanitized = value.replaceAll(RegExp(r"\s+"), '');
            if (sanitized != value) {
              _correoController.value = TextEditingValue(
                text: sanitized,
                selection: TextSelection.collapsed(offset: sanitized.length),
              );
            }
          },
          enabled: !isLoading,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _telefonoController,
          labelText: 'Teléfono / Celular',
          hintText: '987654321',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          prefixIcon: Icons.phone_outlined,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
          ],
          onChanged: (value) {
            final sanitized = value.replaceAll(RegExp(r'[^0-9]'), '');
            if (sanitized != value) {
              _telefonoController.value = TextEditingValue(
                text: sanitized,
                selection: TextSelection.collapsed(offset: sanitized.length),
              );
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingresa tu teléfono';
            }
            if (value.length < 9) {
              return 'El teléfono debe tener al menos 9 dígitos';
            }
            if (!RegExp(r'^\d+$').hasMatch(value)) {
              return 'Solo ingresa números';
            }
            return null;
          },
          enabled: !isLoading,
        ),
        const SizedBox(height: 16),
        // Resumen de contacto
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withAlpha(15),
                AppColors.themeColor2.withAlpha(10),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withAlpha(26),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              ValueListenableBuilder<String>(
                valueListenable: _emailNotifier,
                builder: (context, value, child) {
                  return _buildContactInfoRow(Icons.email, 'Email', value);
                },
              ),
              const SizedBox(height: 10),
              ValueListenableBuilder<String>(
                valueListenable: _phoneNotifier,
                builder: (context, value, child) {
                  return _buildContactInfoRow(
                    Icons.phone_android,
                    'Teléfono',
                    value,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(51),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textColorLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.themeColor2,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityStep(bool isLoading) {
    return Column(
      children: [
        _buildSectionTitle(
          'Seguridad',
          'Protege tu cuenta con una contraseña segura',
          Icons.security_rounded,
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _passwordController,
          labelText: 'Contraseña',
          hintText: '••••••••',
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
          validator: Validators.password,
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
          onChanged: (_) => setState(() {}), // Para actualizar el indicador
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _confirmPasswordController,
          labelText: 'Confirmar contraseña',
          hintText: '••••••••',
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
          validator: (value) =>
              Validators.confirmPassword(value, _passwordController.text),
          textInputAction: TextInputAction.done,
          enabled: !isLoading,
          onSubmitted: (_) => _handleRegister(),
        ),
        const SizedBox(height: 20),
        // Indicador de fortaleza de contraseña
        _buildPasswordStrengthIndicator(),
        const SizedBox(height: 16),
        // Requisitos de contraseña
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Requisitos de la contraseña:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.themeColor2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildPasswordRequirement(
                'Al menos 6 caracteres',
                _passwordController.text.length >= 6,
              ),
              _buildPasswordRequirement(
                'Las contraseñas coinciden',
                _passwordController.text.isNotEmpty &&
                    _passwordController.text == _confirmPasswordController.text,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    int strength = 0;
    String strengthText = 'Muy débil';
    Color strengthColor = Colors.red;

    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;

    switch (strength) {
      case 0:
      case 1:
        strengthText = 'Débil';
        strengthColor = Colors.red;
        break;
      case 2:
        strengthText = 'Regular';
        strengthColor = Colors.orange;
        break;
      case 3:
        strengthText = 'Buena';
        strengthColor = Colors.blue;
        break;
      case 4:
        strengthText = 'Fuerte';
        strengthColor = Colors.green;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fortaleza:',
              style: TextStyle(fontSize: 12, color: AppColors.textColorLight),
            ),
            Text(
              strengthText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: strengthColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: index < strength
                      ? strengthColor
                      : AppColors.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirement(String requirement, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green : AppColors.textColorLight,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              requirement,
              style: TextStyle(
                fontSize: 11,
                color: isMet ? AppColors.themeColor2 : AppColors.textColorLight,
                fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(51),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.onPrimary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.themeColor2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: AppColors.textColorLight),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(bool isLoading) {
    return Column(
      children: [
        // Principal: Siguiente o Crear
        Container(
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
              onTap: isLoading
                  ? null
                  : () {
                      // Validar la sección actual antes de continuar
                      if (_formKey.currentState!.validate()) {
                        if (_currentStep < 3) {
                          setState(() => _currentStep++);
                        } else {
                          _handleRegister();
                        }
                      }
                    },
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
                      Icon(
                        _currentStep < 3
                            ? Icons.arrow_forward_rounded
                            : Icons.check_circle_outline,
                        color: AppColors.onPrimary,
                        size: 22,
                      ),
                    const SizedBox(width: 12),
                    Text(
                      isLoading
                          ? 'Creando cuenta...'
                          : _currentStep < 3
                          ? 'Siguiente'
                          : 'Crear Cuenta',
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
        ),

        // Botón de retroceso (si no es el primer paso)
        if (_currentStep > 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextButton.icon(
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() {
                        _currentStep--;
                      });
                    },
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Anterior'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),

        const SizedBox(height: 8),
        Text(
          'Al registrarte, aceptas nuestros Términos y Condiciones',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textColorLight),
        ),
      ],
    );
  }
}
