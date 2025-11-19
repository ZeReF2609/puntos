import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';

/// Vista de Notificaciones
class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF121212)
              : AppColors.background,
          appBar: AppBar(
            // We'll build a custom title that includes the back button and label together
            backgroundColor: isDark
                ? const Color(0xFF1E1E1E)
                : AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            // Remove default leading to place our own inside the title
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Row(
              children: [
                IconButton(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 2),
                const Text(
                  'Notificaciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: TextButton(
                  onPressed: () {
                    // Marcar todas como leídas
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: isDark ? Colors.white12 : Colors.white24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Marcar todo leído',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            children: [
              _buildNotificationItem(
                isDark: isDark,
                icon: Icons.stars,
                iconColor: AppColors.secondary,
                title: 'Puntos ganados',
                message: 'Has ganado 50 puntos por tu compra reciente',
                time: 'Hace 2 horas',
                isUnread: true,
              ),
              _buildNotificationItem(
                isDark: isDark,
                icon: Icons.card_giftcard,
                iconColor: AppColors.success,
                title: 'Nuevo beneficio disponible',
                message:
                    'Tienes un nuevo descuento del 20% en tu próxima compra',
                time: 'Hace 5 horas',
                isUnread: true,
              ),
              _buildNotificationItem(
                isDark: isDark,
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.warning,
                title: 'Puntos próximos a vencer',
                message: '50 puntos vencen el 30/12/2025. ¡No los pierdas!',
                time: 'Hace 1 día',
                isUnread: true,
              ),
              _buildNotificationItem(
                isDark: isDark,
                icon: Icons.check_circle,
                iconColor: AppColors.success,
                title: 'Canje realizado',
                message: 'Tu vale de S/ 20 ha sido procesado exitosamente',
                time: 'Hace 2 días',
                isUnread: false,
              ),
              _buildNotificationItem(
                isDark: isDark,
                icon: Icons.celebration,
                iconColor: AppColors.secondary,
                title: '¡Promoción especial!',
                message: 'Doble puntos en todas tus compras este fin de semana',
                time: 'Hace 3 días',
                isUnread: false,
              ),
              _buildNotificationItem(
                isDark: isDark,
                icon: Icons.info,
                iconColor: AppColors.info,
                title: 'Actualización de términos',
                message: 'Hemos actualizado nuestros términos y condiciones',
                time: 'Hace 5 días',
                isUnread: false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDark ? 0 : 2,
      color: isUnread
          ? (isDark ? AppColors.primary.withOpacity(0.12) : Colors.white)
          : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUnread
              ? AppColors.primary.withOpacity(isDark ? 0.28 : 0.14)
              : (isDark ? const Color(0xFF303030) : Colors.grey.shade200),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.15,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFFB0B0B0)
                            : AppColors.textSecondary,
                        fontWeight: isUnread
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF808080) : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
