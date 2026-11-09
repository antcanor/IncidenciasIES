import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../models/aula.dart';
import '../models/equipo.dart';
import '../repositories/aula_repository.dart';
import '../repositories/equipo_repository.dart';
import '../repositories/incidencia_repository.dart';
import '../routes/app_routes.dart';

class AulaDetalleScreen extends StatefulWidget {
  final int aulaId;
  final Aula? aula;
  final AulasController? aulasController;
  final EquiposController? equiposController;

  const AulaDetalleScreen({
    super.key,
    required this.aulaId,
    this.aula,
    this.aulasController,
    this.equiposController,
  });

  @override
  State<AulaDetalleScreen> createState() => _AulaDetalleScreenState();
}

class _AulaDetalleScreenState extends State<AulaDetalleScreen> {
  late final EquiposController _equiposController;
  final _aulaRepository = EquipoRepository();
  final _aulaInfoRepository = AulaRepository();
  final _incidenciaRepository = IncidenciaRepository();
  Aula? _aula;
  List<Equipo> _equipos = [];
  Map<int, int> _incidenciasAbiertas = {};
  bool _loading = true;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _aula = widget.aula;
    _equiposController = widget.equiposController ?? EquiposController();
    _ownsController = widget.equiposController == null;
    _loading = false;
    _load();
  }

  Future<void> _load() async {
    final equipos = _equiposController.equipos.isNotEmpty
        ? _equiposController.equipos
              .where((e) => e.aulaId == widget.aulaId)
              .toList()
        : await _aulaRepository.getByAula(widget.aulaId);
    final aula =
        _aula ??
        widget.aulasController?.aulas.cast<Aula?>().firstWhere(
          (candidate) => candidate?.id == widget.aulaId,
          orElse: () => null,
        ) ??
        await _aulaInfoRepository.getById(widget.aulaId);
    if (!mounted) return;
    setState(() {
      _equipos = equipos;
      _aula = aula;
      _loading = false;
    });
    final counts = await _incidenciaRepository.countActiveByEquipoIds(
      equipos.where((e) => e.id != null).map((e) => e.id!),
    );
    if (mounted) setState(() => _incidenciasAbiertas = counts);
  }

  @override
  void dispose() {
    if (_ownsController) _equiposController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Aula #${widget.aulaId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar aula',
            onPressed: _aula == null
                ? null
                : () => Navigator.pushNamed(
                    context,
                    AppRoutes.nuevaAula,
                    arguments: {
                      'aula': _aula,
                      'aulasCtrl': widget.aulasController,
                    },
                  ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.meeting_room),
                          title: Text(
                            _aula?.nombre ?? 'Aula #${widget.aulaId}',
                          ),
                          subtitle: Text('Planta ${_aula?.planta ?? '-'}'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.tag),
                          title: const Text('Identificador'),
                          subtitle: Text(
                            'ID recibido por ruta: ${widget.aulaId}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Equipos instalados',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ..._buildEquipos(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            AppRoutes.nuevoEquipo,
            arguments: {
              'aulaId': widget.aulaId,
              'equiposCtrl': _equiposController,
            },
          );
          _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Equipo'),
      ),
    );
  }

  List<Widget> _buildEquipos() {
    return [
      if (_equipos.isEmpty)
        const Text('No hay equipos asignados a esta aula.')
      else
        Column(
          children: _equipos.map((equipo) {
            final abiertas = _incidenciasAbiertas[equipo.id] ?? 0;
            return Card(
              child: ListTile(
                leading: const Icon(Icons.devices),
                title: Text(equipo.codigo),
                subtitle: Text(
                  '${equipo.tipo} · $abiertas incidencias abiertas',
                ),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.equipoDetalle,
                  arguments: {
                    'equipo': equipo,
                    'equiposCtrl': _equiposController,
                  },
                ),
              ),
            );
          }).toList(),
        ),
      const SizedBox(height: 24),
      Center(
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Volver a Aulas'),
        ),
      ),
    ];
  }
}
