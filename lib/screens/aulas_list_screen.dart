import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class AulasListScreen extends StatelessWidget {
  const AulasListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final aulasEjemplo = [
      {'id': 1, 'nombre': 'Aula 101 - Informática', 'planta': 1},
      {'id': 2, 'nombre': 'Aula 204 - Audiovisuales', 'planta': 2},
      {'id': 3, 'nombre': 'Taller de Hardware y Redes', 'planta': 0},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Aulas'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: aulasEjemplo.length,
        itemBuilder: (context, index) {
          final aula = aulasEjemplo[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
                child: Text('P${aula['planta']}'),
              ),
              title: Text(aula['nombre'] as String, style: theme.textTheme.titleSmall),
              subtitle: Text('Planta ${aula['planta']}', style: theme.textTheme.bodySmall),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.aulaDetalle,
                  arguments: aula['id'] as int,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.nuevaAula);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Aula'),
      ),
    );
  }
}
