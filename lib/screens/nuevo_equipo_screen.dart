import 'package:flutter/material.dart';

class NuevoEquipoScreen extends StatelessWidget {
  final int? aulaId;

  const NuevoEquipoScreen({
    super.key,
    this.aulaId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Nuevo Equipo'),
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
            Text('Datos del Dispositivo', style: theme.textTheme.titleMedium),
            if (aulaId != null) ...[
              const SizedBox(height: 8),
              Text('Aula asignada por defecto: #$aulaId', style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Código de Inventario',
                hintText: 'Ej: PC-102-01',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Tipo de Dispositivo',
                hintText: 'Ej: PC Sobremesa, Proyector, Impresora 3D',
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
                    child: const Text('Guardar Equipo'),
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
