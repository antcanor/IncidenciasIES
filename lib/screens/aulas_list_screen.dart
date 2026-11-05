import 'package:flutter/material.dart';
import '../controllers/controllers.dart';
import '../models/aula.dart';
import '../routes/app_routes.dart';

class AulasListScreen extends StatefulWidget {
  final AulasController? controller;

  const AulasListScreen({super.key, this.controller});

  @override
  State<AulasListScreen> createState() => _AulasListScreenState();
}

class _AulasListScreenState extends State<AulasListScreen> {
  late final AulasController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AulasController();
    _ownsController = widget.controller == null;
    if (_controller.aulas.isEmpty) _controller.loadAulas();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Future<void> _delete(Aula aula) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar aula'),
        content: Text('¿Quieres borrar "${aula.nombre}"? Solo es posible si no tiene equipos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Borrar')),
        ],
      ),
    );
    if (confirmed != true || aula.id == null) return;
    final deleted = await _controller.deleteAula(aula.id!);
    if (!mounted) return;
    if (!deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage ?? 'No se puede borrar el aula.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listado de Aulas')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) return const Center(child: CircularProgressIndicator());
          if (_controller.errorMessage != null && _controller.aulas.isEmpty) {
            return Center(child: Text(_controller.errorMessage!));
          }
          if (_controller.aulas.isEmpty) {
            return const Center(child: Text('No hay aulas registradas.'));
          }
          return RefreshIndicator(
            onRefresh: _controller.loadAulas,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _controller.aulas.length,
              itemBuilder: (context, index) {
                final aula = _controller.aulas[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('P${aula.planta}')),
                    title: Text(aula.nombre),
                    subtitle: Text('Planta ${aula.planta}'),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.aulaDetalle,
                      arguments: {'aula': aula, 'aulasCtrl': _controller},
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.nuevaAula,
                            arguments: {'aula': aula, 'aulasCtrl': _controller},
                          );
                        } else {
                          await _delete(aula);
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
          AppRoutes.nuevaAula,
          arguments: {'aulasCtrl': _controller},
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Aula'),
      ),
    );
  }
}
