import 'package:equatable/equatable.dart';

/// Entidad de usuario (capa de dominio)
/// Esta clase representa el modelo de negocio puro, sin dependencias externas
class UserEntity extends Equatable {
  final int codPersona;
  final String tipoDocumento;
  final String numDocumento;
  final String nombre;
  final String apePaterno;
  final String apeMaterno;
  final String correo;
  final String? telefono;
  final int? puntos;
  final DateTime? createdAt;

  const UserEntity({
    required this.codPersona,
    required this.tipoDocumento,
    required this.numDocumento,
    required this.nombre,
    required this.apePaterno,
    required this.apeMaterno,
    required this.correo,
    this.telefono,
    this.puntos,
    this.createdAt,
  });

  String get nombreCompleto => '$nombre $apePaterno $apeMaterno';

  @override
  List<Object?> get props => [
    codPersona,
    tipoDocumento,
    numDocumento,
    nombre,
    apePaterno,
    apeMaterno,
    correo,
    telefono,
    puntos,
    createdAt,
  ];

  @override
  String toString() {
    return 'UserEntity(codPersona: $codPersona, nombre: $nombreCompleto, correo: $correo)';
  }
}
