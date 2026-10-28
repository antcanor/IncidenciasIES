import 'package:flutter/material.dart';

class NuevaIncidenciaScreen extends StatelessWidget {
  final int? equipoId;

  const NuevaIncidenciaScreen({
    super.key,
    this.equipoId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Nueva Incidencia'),
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
            Text('Formulario de Incidencia', style: theme.textTheme.titleMedium),
            if (equipoId != null) ...[
              const SizedBox(height: 8),
              Text('Equipo asignado previamente: #$equipoId', style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Descripción de la avería',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Código del Equipo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.devices),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar y Volver'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Guardar Incidencia'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
