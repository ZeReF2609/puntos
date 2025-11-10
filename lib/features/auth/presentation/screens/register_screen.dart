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

/// Pantalla de Registro
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  // Tipos de documento
  final List<Map<String, String>> _tiposDocumento = [
    {'codigo': '01', 'nombre': 'DNI'},
    {'codigo': '02', 'nombre': 'CE'},
    {'codigo': '03', 'nombre': 'RUC'},
    {'codigo': '04', 'nombre': 'PASAPORTE'},
  ];

  @override
  void dispose() {
    _tipoDocumentoController.dispose();
    _numDocumentoController.dispose();
    _nombreController.dispose();
    _apePaternoController.dispose();
    _apeMaternoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Ocultar teclado
    context.hideKeyboard();

    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Ejecutar registro con todos los campos
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
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
          appBar: AppBar(
            title: const Text('Crear Cuenta'),
            leading: isLoading
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    // Título
                    Text(
                      'Regístrate',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Crea tu cuenta para comenzar',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Dropdown de tipo de documento
                    DropdownButtonFormField<String>(
                      value: _selectedTipoDocumento,
                      decoration: InputDecoration(
                        labelText: 'Tipo de documento',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      items: _tiposDocumento.map((tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo['codigo'],
                          child: Text(tipo['nombre']!),
                        );
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _selectedTipoDocumento = value!;
                                _tipoDocumentoController.text = value;
                              });
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecciona un tipo de documento';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Campo de número de documento
                    CustomTextField(
                      controller: _numDocumentoController,
                      labelText: 'Número de documento',
                      hintText: _selectedTipoDocumento == '01'
                          ? '12345678'
                          : 'Ingresa tu documento',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.assignment_ind_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu número de documento';
                        }
                        if (_selectedTipoDocumento == '01' &&
                            value.length != 8) {
                          return 'El DNI debe tener 8 dígitos';
                        }
                        if (_selectedTipoDocumento == '03' &&
                            value.length != 11) {
                          return 'El RUC debe tener 11 dígitos';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Campo de nombre
                    CustomTextField(
                      controller: _nombreController,
                      labelText: 'Nombre',
                      hintText: 'Juan',
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.person_outline,
                      validator: Validators.name,
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Campo de apellido paterno
                    CustomTextField(
                      controller: _apePaternoController,
                      labelText: 'Apellido paterno',
                      hintText: 'Pérez',
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.person_outline,
                      validator: Validators.name,
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Campo de apellido materno
                    CustomTextField(
                      controller: _apeMaternoController,
                      labelText: 'Apellido materno',
                      hintText: 'García',
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.person_outline,
                      validator: Validators.name,
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Campo de correo
                    CustomTextField(
                      controller: _correoController,
                      labelText: 'Correo electrónico',
                      hintText: 'juan.perez@email.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.email,
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Campo de teléfono
                    CustomTextField(
                      controller: _telefonoController,
                      labelText: 'Teléfono',
                      hintText: '987654321',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.phone_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu teléfono';
                        }
                        if (value.length < 9) {
                          return 'El teléfono debe tener al menos 9 dígitos';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Campo de contraseña
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Contraseña',
                      hintText: '••••••••',
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.lock_outline,
                      validator: Validators.password,
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Campo de confirmar contraseña
                    CustomTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirmar contraseña',
                      hintText: '••••••••',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outline,
                      validator: (value) => Validators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      enabled: !isLoading,
                      onSubmitted: (_) => _handleRegister(),
                    ),

                    const SizedBox(height: 24),

                    // Botón de registro
                    CustomButton(
                      text: 'Crear Cuenta',
                      onPressed: isLoading ? null : _handleRegister,
                      isLoading: isLoading,
                    ),

                    const SizedBox(height: 24),

                    // Términos y condiciones
                    Center(
                      child: Text(
                        'Al registrarte, aceptas nuestros\nTérminos y Condiciones',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
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
