import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../models/equipo.dart';
import '../routes/app_routes.dart';

class EquiposListScreen extends StatefulWidget {
  final EquiposController? controller;
  final int? aulaId;

  const EquiposListScreen({super.key, this.controller, this.aulaId});

  @override
  State<EquiposListScreen> createState() => _EquiposListScreenState();
}

class _EquiposListScreenState extends State<EquiposListScreen> {
  late final EquiposController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? EquiposController();
    _ownsController = widget.controller == null;
    if (_controller.equipos.isEmpty) _controller.loadEquipos(widget.aulaId);
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Future<void> _delete(Equipo equipo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar equipo'),
        content: Text(
          '¿Quieres borrar "${equipo.codigo}"? Sus incidencias también se eliminarán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed != true || equipo.id == null) return;
    final deleted = await _controller.deleteEquipo(equipo.id!);
    if (!mounted) return;
    if (!deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.errorMessage ?? 'No se puede borrar el equipo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.aulaId == null
        ? 'Listado de Equipos'
        : 'Equipos del Aula';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.errorMessage != null && _controller.equipos.isEmpty) {
            return Center(child: Text(_controller.errorMessage!));
          }
          if (_controller.equipos.isEmpty) {
            return const Center(child: Text('No hay equipos registrados.'));
          }
          return RefreshIndicator(
            onRefresh: () => _controller.loadEquipos(widget.aulaId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _controller.equipos.length,
              itemBuilder: (context, index) {
                final equipo = _controller.equipos[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.devices)),
                    title: Text(equipo.codigo),
                    subtitle: Text(equipo.tipo),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.equipoDetalle,
                      arguments: {'equipo': equipo, 'equiposCtrl': _controller},
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.nuevoEquipo,
                            arguments: {
                              'equipo': equipo,
                              'equiposCtrl': _controller,
                            },
                          );
                        } else {
                          await _delete(equipo);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Editar')),
                        PopupMenuItem(value: 'delete', child: Text('Borrar')),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.nuevoEquipo,
          arguments: {'aulaId': widget.aulaId, 'equiposCtrl': _controller},
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Equipo'),
      ),
    );
  }
}
