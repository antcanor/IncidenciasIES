import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class EquiposListScreen extends StatelessWidget {
  const EquiposListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final equiposEjemplo = [
      {'id': 1, 'codigo': 'PC-101-01', 'tipo': 'PC Sobremesa'},
      {'id': 2, 'codigo': 'PC-101-02', 'tipo': 'PC Sobremesa'},
      {'id': 3, 'codigo': 'PROY-204-01', 'tipo': 'Proyector Láser'},
      {'id': 4, 'codigo': 'IMP-3D-TALLER', 'tipo': 'Impresora 3D'},
      {'id': 5, 'codigo': 'SW-RACK-01', 'tipo': 'Switch Gestionable'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Equipos'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: equiposEjemplo.length,
        itemBuilder: (context, index) {
          final eq = equiposEjemplo[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.tertiaryContainer,
                foregroundColor: theme.colorScheme.onTertiaryContainer,
                child: const Icon(Icons.devices, size: 20),
              ),
              title: Text(eq['codigo'] as String, style: theme.textTheme.titleSmall),
              subtitle: Text(eq['tipo'] as String, style: theme.textTheme.bodySmall),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.equipoDetalle,
                  arguments: eq['id'] as int,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.nuevoEquipo);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Equipo'),
      ),
    );
  }
}
