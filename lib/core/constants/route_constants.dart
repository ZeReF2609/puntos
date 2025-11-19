/// Constantes de rutas de navegación
class RouteConstants {
  // Prevenir instanciación
  RouteConstants._();

  // Rutas principales
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String scan = '/scan';
  static const String points = '/points';
  static const String offers = '/offers';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String pendingReview = '/pending-review';

  // Rutas con parámetros
  static const String userDetails = '/user/:id';
  static const String offerDetail = '/offer/:id';
  static const String pointsHistory = '/points/history';

  // Nombres de rutas (para GoRouter)
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String homeName = 'home';
  static const String scanName = 'scan';
  static const String pointsName = 'points';
  static const String offersName = 'offers';
  static const String profileName = 'profile';
  static const String settingsName = 'settings';
  static const String pendingReviewName = 'pendingReview';
  static const String offerDetailName = 'offerDetail';
  static const String pointsHistoryName = 'pointsHistory';
}
