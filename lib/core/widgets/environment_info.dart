import 'package:flutter/material.dart';
import '../config/environment.dart';

/// Widget para mostrar y configurar información del entorno
/// Útil para desarrollo y debugging
class EnvironmentInfo extends StatefulWidget {
  const EnvironmentInfo({super.key});

  @override
  State<EnvironmentInfo> createState() => _EnvironmentInfoState();
}

class _EnvironmentInfoState extends State<EnvironmentInfo> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Configuración de Desarrollo',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildInfoRow(
              'Entorno',
              Environment.isDevelopment ? 'Desarrollo' : 'Producción',
            ),
            _buildInfoRow('URL Base', Environment.baseUrl),
            _buildInfoRow('API URL', Environment.apiUrl),

            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Usar IP Local'),
              subtitle: Text(Environment.localIpUrl),
              value: Environment.useLocalIp,
              onChanged: (value) {
                setState(() {
                  Environment.useLocalIp = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Usando IP Local: ${Environment.localIpUrl}'
                          : 'Usando URL automática: ${Environment.baseUrl}',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            Text(
              'Nota: Reinicia la app después de cambiar la URL',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
