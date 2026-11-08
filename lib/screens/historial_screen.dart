import 'package:flutter/material.dart';
import 'package:incidencias_ui/incidencias_ui.dart' as ui;

import '../controllers/incidencias_controller.dart';
import '../models/estado.dart';
import '../models/aula.dart';
import '../models/incidencia_detalle.dart';
import '../models/prioridad.dart';
import '../repositories/aula_repository.dart';
import '../repositories/incidencia_repository.dart';
import '../routes/app_routes.dart';
import '../theme/theme.dart';

class HistorialScreen extends StatefulWidget {
  final IncidenciasController? controller;

  const HistorialScreen({super.key, this.controller});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  late final IncidenciasController _controller;
  final _repository = IncidenciaRepository();
  final _aulaRepository = AulaRepository();
  final _searchController = TextEditingController();
  List<IncidenciaDetalle> _incidencias = [];
  int? _aulaId;
  List<Aula> _aulas = [];
  DateTime? _fecha;
  bool _loading = true;
  String? _error;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? IncidenciasController();
    _ownsController = widget.controller == null;
    _loadAulas();
    _load();
  }

  Future<void> _loadAulas() async {
    try {
      final aulas = await _aulaRepository.getAll();
      if (mounted) setState(() => _aulas = aulas);
    } catch (_) {
      // La consulta del historial muestra el error principal si la BD no está disponible.
    }
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final incidencias = await _repository.getHistorialCerradas(
        aulaId: _aulaId,
        texto: _searchController.text,
        fecha: _fecha,
      );
      if (mounted) {
        setState(() {
          _incidencias = incidencias;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar el historial: $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _reabrir(IncidenciaDetalle incidencia) async {
    final success = await _controller.cambiarEstado(
      incidencia.id,
      Estado.abierta,
    );
    if (!mounted) return;
    if (success) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incidencia #${incidencia.id} reabierta.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.errorMessage ?? 'No se pudo reabrir la incidencia.',
          ),
        ),
      );
    }
  }

  ui.Priority _toUiPriority(Prioridad priority) {
    return switch (priority) {
      Prioridad.baja => ui.Priority.low,
      Prioridad.media => ui.Priority.medium,
      Prioridad.alta => ui.Priority.high,
      Prioridad.urgente => ui.Priority.urgent,
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Incidencias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar historial',
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por aula, equipo o descripción',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _load();
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _load(),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    initialValue: _aulaId,
                    decoration: const InputDecoration(
                      labelText: 'Aula',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Todas las aulas'),
                      ),
                      ..._aulas
                          .where((aula) => aula.id != null)
                          .map(
                            (aula) => DropdownMenuItem<int?>(
                              value: aula.id,
                              child: Text(aula.nombre),
                            ),
                          ),
                    ],
                    onChanged: (value) {
                      setState(() => _aulaId = value);
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _fecha == null
                          ? 'Cualquier fecha'
                          : '${_fecha!.day.toString().padLeft(2, '0')}/${_fecha!.month.toString().padLeft(2, '0')}/${_fecha!.year}',
                    ),
                    onPressed: _selectDate,
                  ),
                ),
                if (_fecha != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Quitar fecha',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() => _fecha = null);
                      _load();
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (selected == null) return;
    setState(() => _fecha = selected);
    _load();
  }

  Widget _buildResults() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_incidencias.isEmpty) {
      return const Center(
        child: Text('No hay incidencias cerradas con esos filtros.'),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _incidencias.length,
        itemBuilder: (context, index) {
          final incidencia = _incidencias[index];
          final colors =
              Theme.of(context).extension<IncidenciasColors>() ??
              IncidenciasColors.light;
          return ui.IncidentCard(
            incident: ui.IncidentCardData(
              id: incidencia.id,
              title: incidencia.descripcion,
              details:
                  '${incidencia.aulaNombre} · ${incidencia.equipoCodigo} · '
                  '${_formatDate(incidencia.fecha)}',
              priority: _toUiPriority(incidencia.prioridad),
              status: incidencia.estado.value,
              priorityColor: colors.colorParaPrioridad(incidencia.prioridad),
              statusColor: colors.colorParaEstado(incidencia.estado),
            ),
            showClose: false,
            onClose: (_) {},
            onComment: (data) => Navigator.pushNamed(
              context,
              AppRoutes.incidenciaDetalle,
              arguments: data.id,
            ),
            trailing: TextButton(
              key: Key('reabrir_${incidencia.id}'),
              onPressed: () => _reabrir(incidencia),
              child: const Text('Reabrir'),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
