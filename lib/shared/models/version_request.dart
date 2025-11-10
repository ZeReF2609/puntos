class VersionRequest {
  final String dispositivo;
  final String version;

  VersionRequest({
    required this.dispositivo,
    required this.version,
  });

  Map<String, dynamic> toJson() {
    return {
      'Dispositivo': dispositivo,
      'Version': version,
    };
  }

  factory VersionRequest.fromJson(Map<String, dynamic> json) {
    return VersionRequest(
      dispositivo: json['Dispositivo'] ?? '',
      version: json['Version'] ?? '',
    );
  }

  @override
  String toString() {
    return 'VersionRequest(dispositivo: $dispositivo, version: $version)';
  }
}
