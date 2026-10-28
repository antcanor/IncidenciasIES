import 'package:flutter/material.dart';

class AulaDetalleScreen extends StatelessWidget {
  final int aulaId;

  const AulaDetalleScreen({
    super.key,
    required this.aulaId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Aula #$aulaId'),
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
                    Text('Información del Aula', style: theme.textTheme.titleLarge),
                    const Divider(height: 20),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.meeting_room, color: colorScheme.primary),
                      title: const Text('Identificador'),
                      subtitle: Text('ID recibido por ruta: $aulaId'),
                    ),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.layers, color: colorScheme.secondary),
                      title: const Text('Planta'),
                      subtitle: const Text('Planta 1'),
                    ),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.devices, color: colorScheme.tertiary),
                      title: const Text('Equipos instalados'),
                      subtitle: const Text('2 ordenadores y 1 proyector'),
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
                label: const Text('Volver a Aulas'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
