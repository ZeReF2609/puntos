import 'dart:io';
import 'package:flutter/material.dart';
import '../../app/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _launchUrl(Uri url) async {
  try {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('No se pudo verificar la URL');
    }
  } catch (e) {
    debugPrint('❌ Error al abrir la URL: $url - Error: $e');
    rethrow;
  }
}

class VersionUpdateDialog extends StatefulWidget {
  const VersionUpdateDialog({super.key});

  @override
  State<VersionUpdateDialog> createState() => _VersionUpdateDialogState();
}

class _VersionUpdateDialogState extends State<VersionUpdateDialog> {
  bool _isUpdating = false;

  Future<void> _handleUpdate() async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      const baseUrl = 'http://10.80.40.243:8081';

      if (Platform.isAndroid) {
        final apkUrl = Uri.parse('$baseUrl/build/android/PioinierPuntos.apk');
        await _launchUrl(apkUrl);
      } else if (Platform.isWindows) {
        final exeUrl = Uri.parse(
          '$baseUrl/build/windows/PioinierPuntos_Installer.exe',
        );
        await _launchUrl(exeUrl);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Plataforma no soportada para actualización automática',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Descarga iniciada. Revisa tus notificaciones.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Mostrar mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar la descarga: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.system_update, size: 48, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Actualización requerida',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Por favor actualiza el sistema antes de continuar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isUpdating ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  disabledForegroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isUpdating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Actualizar ahora'),
              ),
              if (_isUpdating) ...[
                const SizedBox(height: 16),
                const Text(
                  'Iniciando descarga...',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
