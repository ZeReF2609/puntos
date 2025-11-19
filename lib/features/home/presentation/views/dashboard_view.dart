import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../widgets/info_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/recent_activity_item.dart';

/// Vista principal del Dashboard
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        final authState = authProvider.state;
        final isDark = themeProvider.isDarkMode;
        String userName = 'Usuario';

        if (authState is Authenticated) {
          userName = authState.user.nombre;
        }

        return Container(
          color: isDark ? const Color(0xFF121212) : AppColors.background,
          child: RefreshIndicator(
            onRefresh: () async {
              // Aquí iría la lógica de actualización
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta de bienvenida
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '¡Bienvenido de nuevo!',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Puntos disponibles',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '1,234',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.stars_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Estadísticas rápidas
                  Row(
                    children: [
                      Expanded(
                        child: InfoCard(
                          icon: Icons.trending_up,
                          title: 'Ganados',
                          value: '+250',
                          subtitle: 'Este mes',
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InfoCard(
                          icon: Icons.redeem,
                          title: 'Canjeados',
                          value: '5',
                          subtitle: 'Premios',
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Acciones rápidas
                  Text(
                    'Acciones rápidas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      QuickActionButton(
                        icon: Icons.card_giftcard,
                        label: 'Beneficios',
                        color: AppColors.secondary,
                        onTap: () {
                          // Navegar a beneficios
                        },
                      ),
                      QuickActionButton(
                        icon: Icons.history,
                        label: 'Historial',
                        color: AppColors.info,
                        onTap: () {
                          // Navegar a historial
                        },
                      ),
                      QuickActionButton(
                        icon: Icons.support_agent,
                        label: 'Ayuda',
                        color: AppColors.warning,
                        onTap: () {
                          // Navegar a ayuda
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Actividad reciente
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Actividad reciente',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Ver todo el historial
                        },
                        child: const Text('Ver todo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  RecentActivityItem(
                    icon: Icons.add_circle_outline,
                    title: 'Puntos ganados',
                    subtitle: 'Compra en Tienda Central',
                    value: '+50',
                    date: 'Hace 2 horas',
                    isPositive: true,
                  ),
                  const SizedBox(height: 8),
                  RecentActivityItem(
                    icon: Icons.remove_circle_outline,
                    title: 'Canje de premio',
                    subtitle: 'Vale de S/ 20',
                    value: '-200',
                    date: 'Hace 1 día',
                    isPositive: false,
                  ),
                  const SizedBox(height: 8),
                  RecentActivityItem(
                    icon: Icons.add_circle_outline,
                    title: 'Bono especial',
                    subtitle: 'Cliente frecuente',
                    value: '+100',
                    date: 'Hace 3 días',
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
}
