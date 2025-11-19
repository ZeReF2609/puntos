import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';

/// Vista de Puntos - Gestión de puntos del usuario
class PointsView extends StatelessWidget {
  const PointsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Container(
          color: isDark ? const Color(0xFF121212) : AppColors.background,
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance de puntos principal
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.secondary, AppColors.secondaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tus Puntos',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1,234',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Historial de movimientos
                  Text(
                    'Historial de movimientos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildMovementItem(
                    context,
                    isDark: isDark,
                    icon: Icons.add_circle,
                    iconColor: AppColors.success,
                    title: 'Compra realizada',
                    subtitle: 'Tienda Central - Compra #12345',
                    date: '18/11/2025 10:30',
                    points: '+50',
                    isPositive: true,
                  ),
                  _buildMovementItem(
                    context,
                    isDark: isDark,
                    icon: Icons.remove_circle,
                    iconColor: AppColors.error,
                    title: 'Canje de premio',
                    subtitle: 'Vale de consumo S/ 20',
                    date: '17/11/2025 15:45',
                    points: '-200',
                    isPositive: false,
                  ),
                  _buildMovementItem(
                    context,
                    isDark: isDark,
                    icon: Icons.add_circle,
                    iconColor: AppColors.success,
                    title: 'Bono de bienvenida',
                    subtitle: 'Nuevo usuario registrado',
                    date: '15/11/2025 09:00',
                    points: '+100',
                    isPositive: true,
                  ),
                  _buildMovementItem(
                    context,
                    isDark: isDark,
                    icon: Icons.add_circle,
                    iconColor: AppColors.success,
                    title: 'Compra realizada',
                    subtitle: 'Tienda Norte - Compra #12340',
                    date: '14/11/2025 18:20',
                    points: '+75',
                    isPositive: true,
                  ),
                  _buildMovementItem(
                    context,
                    isDark: isDark,
                    icon: Icons.card_giftcard,
                    iconColor: AppColors.secondary,
                    title: 'Puntos promocionales',
                    subtitle: 'Campaña Navidad 2025',
                    date: '10/11/2025 12:00',
                    points: '+200',
                    isPositive: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMovementItem(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String date,
    required String points,
    required bool isPositive,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: const Color(0xFF404040)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFFB0B0B0)
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF808080) : AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            points,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isPositive ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
