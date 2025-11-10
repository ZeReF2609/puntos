class LoginResponse {
  final bool success;
  final String message;
  final LoginData? data;

  LoginResponse({required this.success, required this.message, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }
}

class LoginData {
  final int coUser;
  final String usrTrab;
  final int coRol;
  final String noRol;
  final int coArea;
  final String noArea;
  final String token;
  final String refreshToken;
  final String fechaExpiraToken;
  final String fechaExpiraRefresh;
  final List<dynamic> grupos;
  final List<PermisoMenu> permisos;
  final int estadoVersion;

  LoginData({
    required this.coUser,
    required this.usrTrab,
    required this.coRol,
    required this.noRol,
    required this.coArea,
    required this.noArea,
    required this.token,
    required this.refreshToken,
    required this.fechaExpiraToken,
    required this.fechaExpiraRefresh,
    required this.grupos,
    required this.permisos,
    required this.estadoVersion,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      coUser: json['cO_USER'] ?? 0,
      usrTrab: json['usR_TRAB'] ?? '',
      coRol: json['cO_ROL'] ?? 0,
      noRol: json['nO_ROL'] ?? '',
      coArea: json['cO_AREA'] ?? 0,
      noArea: json['nO_AREA'] ?? '',
      token: json['token'] ?? '',
      refreshToken: json['refresH_TOKEN'] ?? '',
      fechaExpiraToken: json['fechA_EXPIRA_TOKEN'] ?? '',
      fechaExpiraRefresh: json['fechA_EXPIRA_REFRESH'] ?? '',
      grupos: json['grupos'] ?? [],
      permisos:
          (json['permisos'] as List<dynamic>?)
              ?.map((p) => PermisoMenu.fromJson(p))
              .toList() ??
          [],
      estadoVersion: json['estadO_VERSION'] ?? 0,
    );
  }
}

class PermisoMenu {
  final int coRol;
  final int coMenu;
  final String icMenu;
  final String noMenu;
  final int coSubmenu;
  final String noSubmenu;
  final int coAccion;
  final String noAccion;
  final bool permitido;
  final String icSubmenu;
  final String ruSubmenu;

  PermisoMenu({
    required this.coRol,
    required this.coMenu,
    required this.icMenu,
    required this.noMenu,
    required this.coSubmenu,
    required this.noSubmenu,
    required this.coAccion,
    required this.noAccion,
    required this.permitido,
    required this.icSubmenu,
    required this.ruSubmenu,
  });

  factory PermisoMenu.fromJson(Map<String, dynamic> json) {
    return PermisoMenu(
      coRol: json['cO_ROL'] ?? 0,
      coMenu: json['cO_MENU'] ?? 0,
      icMenu: json['iC_MENU'] ?? '',
      noMenu: json['nO_MENU'] ?? '',
      coSubmenu: json['cO_SUBMENU'] ?? 0,
      noSubmenu: json['nO_SUBMENU'] ?? '',
      coAccion: json['cO_ACCION'] ?? 0,
      noAccion: json['nO_ACCION'] ?? '',
      permitido: json['permitido'] ?? false,
      icSubmenu: json['iC_SUBMENU'] ?? '',
      ruSubmenu: json['rU_SUBMENU'] ?? '',
    );
  }
}
