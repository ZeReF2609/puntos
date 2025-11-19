import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../views/dashboard_view.dart';
import '../views/points_view.dart';
import '../views/profile_view.dart';
import '../views/notifications_view.dart';
import '../widgets/custom_drawer.dart';

/// Pantalla principal del HOME - Contenedor de todas las vistas
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Vistas principales
  final List<Widget> _views = [
    const DashboardView(),
    const PointsView(),
    const ProfileView(),
  ];

  // Títulos de las vistas
  final List<String> _titles = ['Inicio', 'Mis Puntos', 'Mi Perfil'];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsView()),
    );
  }

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

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: isDark
              ? const Color(0xFF121212)
              : AppColors.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: isDark
                ? const Color(0xFF1E1E1E)
                : AppColors.primary,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  tooltip: 'Menú',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _titles[_currentIndex],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '¡Hola, $userName!',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // Badge de notificaciones
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                    onPressed: _openNotifications,
                    tooltip: 'Notificaciones',
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Drawer lateral con menú adicional
          drawer: CustomDrawer(userName: userName),

          // Cuerpo principal - Vista dinámica
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _views[_currentIndex],
          ),

          // Bottom Navigation Bar
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              selectedItemColor: isDark
                  ? AppColors.primary.withOpacity(0.9)
                  : AppColors.primary,
              unselectedItemColor: isDark
                  ? Colors.grey.shade600
                  : AppColors.grey,
              selectedFontSize: 12,
              unselectedFontSize: 11,
              elevation: 8,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                  ),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    _currentIndex == 1
                        ? Icons.stars_rounded
                        : Icons.stars_outlined,
                  ),
                  label: 'Puntos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    _currentIndex == 2 ? Icons.person : Icons.person_outline,
                  ),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
