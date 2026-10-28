import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class IncidenciasListScreen extends StatelessWidget {
  const IncidenciasListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Lista de ejemplo para navegación rápida
    final incidenciasEjemplo = [
      {'id': 1, 'titulo': 'PC-101-01 no enciende tras tormenta', 'aula': 'Aula 101'},
      {'id': 2, 'titulo': 'Teclado con teclas bloqueadas', 'aula': 'Aula 101'},
      {'id': 3, 'titulo': 'Lámpara de proyector parpadeando', 'aula': 'Aula 204'},
      {'id': 4, 'titulo': 'Extrusor obstruido', 'aula': 'Taller Redes'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Incidencias'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: incidenciasEjemplo.length,
        itemBuilder: (context, index) {
          final inc = incidenciasEjemplo[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: Text('#${inc['id']}'),
              ),
              title: Text(inc['titulo'] as String, style: theme.textTheme.titleSmall),
              subtitle: Text(inc['aula'] as String, style: theme.textTheme.bodySmall),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.incidenciaDetalle,
                  arguments: inc['id'] as int,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.nuevaIncidencia);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Incidencia'),
      ),
    );
  }
}
