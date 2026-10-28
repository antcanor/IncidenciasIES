import 'package:flutter/material.dart';

class IncidenciaDetalleScreen extends StatelessWidget {
  final int incidenciaId;

  const IncidenciaDetalleScreen({
    super.key,
    required this.incidenciaId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle Incidencia #$incidenciaId'),
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
                    Text('Incidencia #$incidenciaId', style: theme.textTheme.titleLarge),
                    const Divider(height: 20),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.info_outline, color: colorScheme.primary),
                      title: const Text('ID de Incidencia recibido por argumento'),
                      subtitle: Text('$incidenciaId'),
                    ),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.devices, color: colorScheme.secondary),
                      title: const Text('Equipo afectado'),
                      subtitle: const Text('PC Sobremesa (PC-101-01)'),
                    ),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.meeting_room, color: colorScheme.tertiary),
                      title: const Text('Ubicación'),
                      subtitle: const Text('Aula 101 - Informática (Planta 1)'),
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
                label: const Text('Volver al Listado'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
