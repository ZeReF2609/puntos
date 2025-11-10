import 'dart:convert';
import '../../domain/entities/user_entity.dart';

/// Modelo de usuario (capa de datos)
/// Se encarga de la serialización/deserialización de datos
class UserModel extends UserEntity {
  const UserModel({
    required super.codPersona,
    required super.tipoDocumento,
    required super.numDocumento,
    required super.nombre,
    required super.apePaterno,
    required super.apeMaterno,
    required super.correo,
    super.telefono,
    super.puntos,
    super.createdAt,
  });

  /// Crear UserModel desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      codPersona: json['codPersona'] ?? json['COD_PERSONA'] ?? 0,
      tipoDocumento: json['tipoDocumento'] ?? json['TIPO_DOCUMENTO'] ?? 'DNI',
      numDocumento: json['numDocumento'] ?? json['NUM_DOCUMENTO'] ?? '',
      nombre: json['nombre'] ?? json['NOMBRE'] ?? '',
      apePaterno: json['apePaterno'] ?? json['APE_PATERNO'] ?? '',
      apeMaterno: json['apeMaterno'] ?? json['APE_MATERNO'] ?? '',
      correo: json['correo'] ?? json['CORREO'] ?? '',
      telefono: json['telefono'] ?? json['TELEFONO'],
      puntos: json['puntos'] ?? json['PUNTOS'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  /// Convertir UserModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'codPersona': codPersona,
      'tipoDocumento': tipoDocumento,
      'numDocumento': numDocumento,
      'nombre': nombre,
      'apePaterno': apePaterno,
      'apeMaterno': apeMaterno,
      'correo': correo,
      'telefono': telefono,
      'puntos': puntos,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Crear copia con modificaciones
  UserModel copyWith({
    int? codPersona,
    String? tipoDocumento,
    String? numDocumento,
    String? nombre,
    String? apePaterno,
    String? apeMaterno,
    String? correo,
    String? telefono,
    int? puntos,
    DateTime? createdAt,
  }) {
    return UserModel(
      codPersona: codPersona ?? this.codPersona,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      numDocumento: numDocumento ?? this.numDocumento,
      nombre: nombre ?? this.nombre,
      apePaterno: apePaterno ?? this.apePaterno,
      apeMaterno: apeMaterno ?? this.apeMaterno,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      puntos: puntos ?? this.puntos,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convertir entidad a modelo
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      codPersona: entity.codPersona,
      tipoDocumento: entity.tipoDocumento,
      numDocumento: entity.numDocumento,
      nombre: entity.nombre,
      apePaterno: entity.apePaterno,
      apeMaterno: entity.apeMaterno,
      correo: entity.correo,
      telefono: entity.telefono,
      puntos: entity.puntos,
      createdAt: entity.createdAt,
    );
  }

  /// Convertir modelo a String JSON
  String toJsonString() => json.encode(toJson());

  /// Crear UserModel desde String JSON
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(json.decode(jsonString));
  }
}
