import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/environment_info.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';

/// Pantalla de Configuración
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final authState = authProvider.state;
        final isLoading = authState is AuthLoading;

        // Redirigir si cierra sesión
        if (authState is Unauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(RouteConstants.login);
          });
        }

        // Mostrar error si hay
        if (authState is AuthError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authState.message),
                backgroundColor: AppColors.error,
              ),
            );
          });
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Configuración')),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de General
                _buildSectionHeader(context, 'General'),
                _buildSettingOption(
                  context,
                  icon: Icons.language,
                  title: 'Idioma',
                  subtitle: 'Español',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente')),
                    );
                  },
                ),
                _buildSettingOption(
                  context,
                  icon: Icons.dark_mode,
                  title: 'Tema',
                  subtitle: 'Claro',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente')),
                    );
                  },
                ),

                const Divider(height: 32),

                // Sección de Notificaciones
                _buildSectionHeader(context, 'Notificaciones'),
                _buildSwitchOption(
                  context,
                  icon: Icons.notifications_active,
                  title: 'Notificaciones push',
                  value: true,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente')),
                    );
                  },
                ),
                _buildSwitchOption(
                  context,
                  icon: Icons.email,
                  title: 'Notificaciones por email',
                  value: false,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente')),
                    );
                  },
                ),

                const Divider(height: 32),

                // Sección de Cuenta
                _buildSectionHeader(context, 'Cuenta'),
                _buildSettingOption(
                  context,
                  icon: Icons.privacy_tip,
                  title: 'Privacidad',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente')),
                    );
                  },
                ),
                _buildSettingOption(
                  context,
                  icon: Icons.security,
                  title: 'Seguridad',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente')),
                    );
                  },
                ),

                const Divider(height: 32),

                // Sección de Desarrollo (solo en debug)
                if (kDebugMode) ...[
                  _buildSectionHeader(context, 'Desarrollo'),
                  const EnvironmentInfo(),
                  const Divider(height: 32),
                ],

                // Sección de Información
                _buildSectionHeader(context, 'Información'),
                _buildSettingOption(
                  context,
                  icon: Icons.description,
                  title: 'Términos y condiciones',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente')),
                    );
                  },
                ),
                _buildSettingOption(
                  context,
                  icon: Icons.policy,
                  title: 'Política de privacidad',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente')),
                    );
                  },
                ),
                _buildSettingOption(
                  context,
                  icon: Icons.info,
                  title: 'Acerca de',
                  subtitle: 'Versión 1.0.0',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'PionierPuntos',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.loyalty,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Botón de cerrar sesión
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: CustomButton(
                    text: 'Cerrar Sesión',
                    onPressed: () => _showLogoutDialog(context, authProvider),
                    isLoading: isLoading,
                    backgroundColor: AppColors.error,
                    icon: Icons.logout,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        AppConstants.defaultPadding,
        AppConstants.defaultPadding,
        AppConstants.smallPadding,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              authProvider.logout();
            },
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
