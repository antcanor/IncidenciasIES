import 'package:flutter/material.dart';

class NuevaAulaScreen extends StatelessWidget {
  const NuevaAulaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Aula'),
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
            Text('Datos del Aula', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nombre del Aula',
                hintText: 'Ej: Aula 105 - Telemática',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.meeting_room),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Número de Planta',
                hintText: 'Ej: 0, 1, 2',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.layers),
              ),
              keyboardType: TextInputType.number,
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
                    child: const Text('Guardar Aula'),
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
