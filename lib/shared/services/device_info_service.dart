import 'dart:io';
import 'package:flutter/foundation.dart';

class DeviceInfoService {
  /// Obtener la IP local del dispositivo
  static Future<String> getLocalIpAddress() async {
    try {
      if (kIsWeb) {
        // En web no podemos obtener la IP directamente
        return 'Web Client';
      }

      // Obtener todas las interfaces de red
      final interfaces = await NetworkInterface.list();

      for (final interface in interfaces) {
        // Buscar interfaces que no sean loopback y estén activas
        if (!interface.name.toLowerCase().contains('loopback') &&
            !interface.name.toLowerCase().contains('docker') &&
            !interface.name.toLowerCase().contains('vmware')) {
          for (final address in interface.addresses) {
            // Buscar IPv4 que no sea loopback
            if (address.type == InternetAddressType.IPv4 &&
                !address.isLoopback) {
              return address.address;
            }
          }
        }
      }

      // Si no encuentra ninguna, usar localhost como fallback
      return '127.0.0.1';
    } catch (e) {
      // En caso de error, devolver IP por defecto
      return '192.168.1.100';
    }
  }

  /// Obtener información detallada del dispositivo
  static Future<Map<String, String>> getDeviceInfo() async {
    try {
      final ip = await getLocalIpAddress();
      final deviceType = _getDeviceType();
      final platform = _getPlatformName();

      return {
        'ip': ip,
        'deviceType': deviceType,
        'platform': platform,
        'userAgent': _getUserAgent(),
      };
    } catch (e) {
      return {
        'deviceType': 'Unknown',
        'platform': 'Unknown',
        'userAgent': 'Flutter App',
      };
    }
  }

  static String _getDeviceType() {
    if (kIsWeb) {
      return 'Web Browser';
    } else if (Platform.isWindows) {
      return 'Windows Desktop';
    } else if (Platform.isAndroid) {
      return 'Android Mobile';
    } else if (Platform.isIOS) {
      return 'iOS Mobile';
    } else if (Platform.isMacOS) {
      return 'macOS Desktop';
    } else if (Platform.isLinux) {
      return 'Linux Desktop';
    } else {
      return 'Unknown Device';
    }
  }

  static String _getPlatformName() {
    if (kIsWeb) {
      return 'Web';
    } else {
      return Platform.operatingSystem;
    }
  }

  static String _getUserAgent() {
    final deviceType = _getDeviceType();
    final platform = _getPlatformName();
    return 'PionierFactory/$deviceType ($platform)';
  }
}
