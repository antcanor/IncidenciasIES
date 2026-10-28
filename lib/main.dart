import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'database/database_seeder.dart';
import 'models/models.dart';
import 'repositories/repositories.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializar factory según la plataforma
  DatabaseHelper.initializeDatabaseFactory();

  // 2. Abrir base de datos y cargar seeder si está vacía
  await DatabaseHelper.instance.database;
  final seeder = DatabaseSeeder();
  await seeder.seedIfEmpty();

  runApp(const IncidenciasApp());
}

class IncidenciasApp extends StatelessWidget {
  const IncidenciasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IncidenciasIES',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AulaRepository _aulaRepo = AulaRepository();
  final EquipoRepository _equipoRepo = EquipoRepository();
  final IncidenciaRepository _incidenciaRepo = IncidenciaRepository();
  final ComentarioRepository _comentarioRepo = ComentarioRepository();

  bool _loading = true;
  String? _dbPath;
  bool _fksEnabled = false;

  List<Aula> _aulas = [];
  List<Equipo> _equipos = [];
  List<IncidenciaDetalle> _incidenciasDetalle = [];
  List<Comentario> _comentarios = [];

  Map<Estado, int> _conteoEstado = {};
  Map<Prioridad, int> _conteoPrioridad = {};
  List<Map<String, dynamic>> _conteoPorAula = [];

  int? _aulaFiltroId; // null = Todas las aulas

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _loading = true);

    final status = await DatabaseHelper.instance.checkDatabaseStatus();
    final aulas = await _aulaRepo.getAll();
    final equipos = await _equipoRepo.getAll();
    final comentarios = await _comentarioRepo.getAll();

    // Consultas avanzadas para el Panel
    final conteoEstado = await _incidenciaRepo.countByEstado();
    final conteoPrioridad = await _incidenciaRepo.countByPrioridad();
    final conteoPorAula = await _incidenciaRepo.countPorAula();

    // Consulta con JOIN doble (incidencia -> equipo -> aula)
    final List<IncidenciaDetalle> detalles;
    if (_aulaFiltroId != null) {
      detalles = await _incidenciaRepo.getIncidenciasPorAula(_aulaFiltroId!);
    } else {
      detalles = await _incidenciaRepo.getIncidenciasConDetalle();
    }

    if (mounted) {
      setState(() {
        _dbPath = status['path'] as String;
        _fksEnabled = status['foreignKeysEnabled'] as bool;
        _aulas = aulas;
        _equipos = equipos;
        _incidenciasDetalle = detalles;
        _comentarios = comentarios;
        _conteoEstado = conteoEstado;
        _conteoPrioridad = conteoPrioridad;
        _conteoPorAula = conteoPorAula;
        _loading = false;
      });
    }
  }

  String get _platformName {
    if (kIsWeb) return 'Web (Navegador)';
    if (Platform.isLinux) return 'Linux (Desktop)';
    if (Platform.isWindows) return 'Windows (Desktop)';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isIOS) return 'iOS';
    return 'Desconocida';
  }

  Color _getPrioridadColor(Prioridad p) {
    switch (p) {
      case Prioridad.urgente:
        return Colors.red[700]!;
      case Prioridad.alta:
        return Colors.orange[800]!;
      case Prioridad.media:
        return Colors.amber[800]!;
      case Prioridad.baja:
        return Colors.blueGrey;
    }
  }

  Color _getEstadoColor(Estado e) {
    switch (e) {
      case Estado.abierta:
        return Colors.red[700]!;
      case Estado.enProceso:
        return Colors.blue[700]!;
      case Estado.resuelta:
        return Colors.green[700]!;
      case Estado.cerrada:
        return Colors.grey[700]!;
    }
  }

  Future<void> _agregarIncidenciaEjemplo() async {
    if (_equipos.isEmpty) return;
    final equipo = _equipos.first;
    final nueva = Incidencia(
      equipoId: equipo.id!,
      descripcion: 'Incidencia de prueba rápida (${DateTime.now().second}s)',
      prioridad: Prioridad.alta,
      estado: Estado.abierta,
      fecha: DateTime.now(),
    );
    await _incidenciaRepo.create(nueva);
    await _loadAllData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nueva incidencia creada y persistida en SQLite')),
      );
    }
  }

  Future<void> _eliminarIncidencia(int id) async {
    await _incidenciaRepo.delete(id);
    await _loadAllData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incidencia eliminada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalFilas = _aulas.length + _equipos.length + _incidenciasDetalle.length + _comentarios.length;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IncidenciasIES — Panel & Consultas'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Recargar consultas',
              onPressed: _loadAllData,
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Panel'),
              Tab(icon: Icon(Icons.alt_route), text: 'JOIN Doble (Aulas)'),
              Tab(icon: Icon(Icons.devices), text: 'Equipos y Aulas'),
              Tab(icon: Icon(Icons.storage), text: 'Estado BD'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildPanelTab(),
                  _buildJoinDobleTab(),
                  _buildEquiposTab(),
                  _buildStatusTab(totalFilas),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _agregarIncidenciaEjemplo,
          icon: const Icon(Icons.add),
          label: const Text('Nueva Incidencia'),
        ),
      ),
    );
  }

  /// Pestaña 1: Panel con COUNT por Estado y por Prioridad
  Widget _buildPanelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Métricas por Estado (COUNT)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMetricCard('Abiertas', _conteoEstado[Estado.abierta] ?? 0, Colors.red[700]!, Icons.error_outline),
              _buildMetricCard('En Proceso', _conteoEstado[Estado.enProceso] ?? 0, Colors.blue[700]!, Icons.autorenew),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMetricCard('Resueltas', _conteoEstado[Estado.resuelta] ?? 0, Colors.green[700]!, Icons.check_circle_outline),
              _buildMetricCard('Cerradas', _conteoEstado[Estado.cerrada] ?? 0, Colors.grey[700]!, Icons.archive_outlined),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Métricas por Prioridad (COUNT)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMetricCard('Urgente', _conteoPrioridad[Prioridad.urgente] ?? 0, Colors.red[900]!, Icons.priority_high),
              _buildMetricCard('Alta', _conteoPrioridad[Prioridad.alta] ?? 0, Colors.orange[800]!, Icons.trending_up),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMetricCard('Media', _conteoPrioridad[Prioridad.media] ?? 0, Colors.amber[800]!, Icons.remove),
              _buildMetricCard('Baja', _conteoPrioridad[Prioridad.baja] ?? 0, Colors.blueGrey, Icons.trending_down),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Incidencias por Aula (Agrupación)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: _conteoPorAula.map((row) {
                final nombre = row['aula_nombre'] as String;
                final planta = row['aula_planta'] as int;
                final total = row['total_incidencias'] as int;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1E3A8A),
                    child: Text('P$planta', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Planta $planta'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: total > 0 ? Colors.orange[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$total incidencias',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: total > 0 ? Colors.orange[900] : Colors.grey[700],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, int count, Color color, IconData icon) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                  Text(
                    '$count',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pestaña 2: JOIN Doble (incidencia -> equipo -> aula) con filtro por aula
  Widget _buildJoinDobleTab() {
    return Column(
      children: [
        // Filtro por Aula
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.grey[100],
          child: Row(
            children: [
              const Icon(Icons.filter_list, size: 20, color: Color(0xFF1E3A8A)),
              const SizedBox(width: 8),
              const Text('Filtrar Aula:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<int?>(
                  value: _aulaFiltroId,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Todas las aulas (JOIN completo)'),
                    ),
                    ..._aulas.map((a) => DropdownMenuItem<int?>(
                          value: a.id,
                          child: Text('${a.nombre} (Planta ${a.planta})'),
                        )),
                  ],
                  onChanged: (val) {
                    setState(() => _aulaFiltroId = val);
                    _loadAllData();
                  },
                ),
              ),
            ],
          ),
        ),
        // Lista de incidencias con detalle
        Expanded(
          child: _incidenciasDetalle.isEmpty
              ? const Center(child: Text('No hay incidencias para este filtro.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _incidenciasDetalle.length,
                  itemBuilder: (context, index) {
                    final det = _incidenciasDetalle[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 1.5,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.meeting_room, size: 16, color: Color(0xFF1E3A8A)),
                                    const SizedBox(width: 4),
                                    Text(
                                      det.aulaNombre,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(' (P${det.aulaPlanta})', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  tooltip: 'Eliminar incidencia',
                                  onPressed: () => _eliminarIncidencia(det.id),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.devices, size: 15, color: Colors.teal),
                                const SizedBox(width: 4),
                                Text(
                                  '${det.equipoCodigo} • ${det.equipoTipo}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.teal),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(det.descripcion, style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Chip(
                                  label: Text(det.prioridad.value, style: const TextStyle(fontSize: 11, color: Colors.white)),
                                  backgroundColor: _getPrioridadColor(det.prioridad),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(det.estado.value, style: const TextStyle(fontSize: 11, color: Colors.white)),
                                  backgroundColor: _getEstadoColor(det.estado),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEquiposTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _aulas.length,
      itemBuilder: (context, index) {
        final aula = _aulas[index];
        final equiposAula = _equipos.where((e) => e.aulaId == aula.id).toList();

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: const Icon(Icons.meeting_room, color: Color(0xFF1E3A8A)),
            title: Text(aula.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Planta ${aula.planta} • ${equiposAula.length} equipos asignados'),
            children: equiposAula.map((eq) {
              return ListTile(
                leading: const Icon(Icons.devices, size: 20),
                title: Text(eq.codigo, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(eq.tipo),
                trailing: Text('ID #${eq.id}', style: const TextStyle(color: Colors.grey)),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStatusTab(int totalFilas) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estado de la Base de Datos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.computer),
                    title: const Text('Plataforma activa'),
                    subtitle: Text(_platformName),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.vpn_key),
                    title: const Text('PRAGMA foreign_keys'),
                    subtitle: Text(_fksEnabled ? 'ON (1 - Activadas)' : 'OFF (Desactivadas)'),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.storage),
                    title: const Text('Total registros persistidos'),
                    subtitle: Text('$totalFilas filas (Seeder inicial cargado)'),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.folder_open),
                    title: const Text('Ruta SQLite'),
                    subtitle: SelectableText(_dbPath ?? ''),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
