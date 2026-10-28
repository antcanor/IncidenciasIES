import 'package:flutter/material.dart';

class EquipoDetalleScreen extends StatelessWidget {
  final int equipoId;

  const EquipoDetalleScreen({
    super.key,
    required this.equipoId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Equipo #$equipoId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ficha del Dispositivo', style: theme.textTheme.titleLarge),
                    const Divider(height: 20),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.qr_code, color: colorScheme.primary),
                      title: const Text('ID de Equipo'),
                      subtitle: Text('Argumento recibido: $equipoId'),
                    ),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.devices, color: colorScheme.secondary),
                      title: const Text('Código Inventario'),
                      subtitle: const Text('PC-101-01 (Intel Core i5, 16GB RAM)'),
                    ),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.meeting_room, color: colorScheme.tertiary),
                      title: const Text('Aula Asignada'),
                      subtitle: const Text('Aula 101 - Informática'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver a Equipos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
