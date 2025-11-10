import 'user_model.dart';

/// Modelo de respuesta de autenticación
class AuthResponseModel {
  final UserModel user;
  final String token;
  final String refreshToken;
  final int expiresIn;

  AuthResponseModel({
    required this.user,
    required this.token,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return AuthResponseModel(
      user: UserModel.fromJson(data['user'] ?? {}),
      token: data['token'] ?? '',
      refreshToken: data['refreshToken'] ?? '',
      expiresIn: data['expiresIn'] ?? 86400,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
    };
  }
}

/// Modelo de respuesta genérica de la API
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final List<String>? errors;

  ApiResponse({required this.success, this.data, this.message, this.errors});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message'],
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}
