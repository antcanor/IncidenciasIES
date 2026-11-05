import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../models/equipo.dart';
import '../routes/app_routes.dart';

class EquipoDetalleScreen extends StatelessWidget {
  final int equipoId;
  final Equipo? equipo;
  final EquiposController? equiposController;

  const EquipoDetalleScreen({
    super.key,
    required this.equipoId,
    this.equipo,
    this.equiposController,
  });

  @override
  Widget build(BuildContext context) {
    final current = equipo;
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Equipo #$equipoId'),
        actions: [
          if (current != null)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar equipo',
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.nuevoEquipo,
                arguments: {
                  'equipo': current,
                  'equiposCtrl': equiposController,
                },
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: const Text('Código de inventario'),
                  subtitle: Text(current?.codigo ?? 'Equipo #$equipoId'),
                ),
                if (equipo == null)
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Referencia'),
                    subtitle: Text('Argumento recibido: $equipoId'),
                  ),
                ListTile(
                  leading: const Icon(Icons.devices),
                  title: const Text('Tipo'),
                  subtitle: Text(current?.tipo ?? 'No disponible'),
                ),
                ListTile(
                  leading: const Icon(Icons.meeting_room),
                  title: const Text('Aula asignada'),
                  subtitle: Text(
                    current == null
                        ? 'No disponible'
                        : 'Aula #${current.aulaId}',
                  ),
                ),
              ],
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
    );
  }
}
