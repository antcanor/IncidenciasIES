import 'package:flutter/material.dart';

import '../models/incidencia_detalle.dart';
import '../repositories/incidencia_repository.dart';

class ArViewScreen extends StatefulWidget {
  final int equipoId;
  final String? equipoLabel;
  final IncidenciaRepository? repository;

  const ArViewScreen({
    super.key,
    required this.equipoId,
    this.equipoLabel,
    this.repository,
  });

  @override
  State<ArViewScreen> createState() => _ArViewScreenState();
}

class _ArViewScreenState extends State<ArViewScreen> {
  late final IncidenciaRepository _repository;
  List<IncidenciaDetalle> _incidencias = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? IncidenciaRepository();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final incidencias =
          await _repository.getIncidenciasPorEquipo(widget.equipoId);
      if (!mounted) return;
      setState(() {
        _incidencias = incidencias;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar el historial: $error';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista AR (maqueta)'),
        actions: [
          IconButton(
            tooltip: 'Actualizar historial',
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildCameraMock(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildHistoryOverlay()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraMock() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff263238), Color(0xff607d8b), Color(0xff37474f)],
          ),
        ),
        child: Center(
          child: Opacity(
            opacity: 0.35,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam, size: 96, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  'VISTA DE CÁMARA · MAQUETA',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      margin: const EdgeInsets.all(12),
      color: Colors.black.withValues(alpha: 0.72),
      child: ListTile(
        leading: const Icon(Icons.view_in_ar, color: Colors.cyanAccent),
        title: Text(
          widget.equipoLabel ?? 'Equipo #${widget.equipoId}',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: const Text(
          'Historial superpuesto sobre la cámara',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildHistoryOverlay() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_error!),
          ),
        ),
      );
    }
    if (_incidencias.isEmpty) {
      return const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Este equipo no tiene incidencias registradas.'),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: _incidencias.length,
      itemBuilder: (context, index) {
        final incidencia = _incidencias[index];
        return Card(
          key: ValueKey('ar_incidencia_${incidencia.id}'),
          color: Colors.black.withValues(alpha: 0.78),
          child: ListTile(
            leading: const Icon(Icons.warning_amber, color: Colors.orangeAccent),
            title: Text(
              incidencia.descripcion,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '${incidencia.estado.value} · ${incidencia.prioridad.value} · '
              '${_formatDate(incidencia.fecha)}',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
