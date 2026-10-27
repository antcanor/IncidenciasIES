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
  List<Incidencia> _incidencias = [];
  List<Comentario> _comentarios = [];

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
    final incidencias = await _incidenciaRepo.getAll();
    final comentarios = await _comentarioRepo.getAll();

    if (mounted) {
      setState(() {
        _dbPath = status['path'] as String;
        _fksEnabled = status['foreignKeysEnabled'] as bool;
        _aulas = aulas;
        _equipos = equipos;
        _incidencias = incidencias;
        _comentarios = comentarios;
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
        return Colors.red;
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
      descripcion: 'Incidencia de prueba rápida creada desde UI (${DateTime.now().second}s)',
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
        const SnackBar(content: Text('Incidencia eliminada con éxito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalFilas = _aulas.length + _equipos.length + _incidencias.length + _comentarios.length;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IncidenciasIES — CRUD & SQLite'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Recargar datos',
              onPressed: _loadAllData,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.report_problem), text: 'Incidencias'),
              Tab(icon: Icon(Icons.devices), text: 'Equipos y Aulas'),
              Tab(icon: Icon(Icons.info_outline), text: 'Estado BD'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Pestaña 1: Incidencias
                  _buildIncidenciasTab(),
                  // Pestaña 2: Equipos y Aulas
                  _buildEquiposTab(),
                  // Pestaña 3: Estado de la Base de Datos
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

  Widget _buildIncidenciasTab() {
    if (_incidencias.isEmpty) {
      return const Center(child: Text('No hay incidencias registradas.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _incidencias.length,
      itemBuilder: (context, index) {
        final inc = _incidencias[index];
        final equipo = _equipos.firstWhere(
          (e) => e.id == inc.equipoId,
          orElse: () => Equipo(aulaId: 0, tipo: 'Desconocido', codigo: 'ID-${inc.equipoId}'),
        );
        final comentarios = _comentarios.where((c) => c.incidenciaId == inc.id).toList();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1.5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Incidencia #${inc.id} — ${equipo.codigo}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      tooltip: 'Eliminar incidencia',
                      onPressed: () => _eliminarIncidencia(inc.id!),
                    ),
                  ],
                ),
                Text(
                  inc.descripcion,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Chip(
                      label: Text(inc.prioridad.value, style: const TextStyle(fontSize: 11, color: Colors.white)),
                      backgroundColor: _getPrioridadColor(inc.prioridad),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(inc.estado.value, style: const TextStyle(fontSize: 11, color: Colors.white)),
                      backgroundColor: _getEstadoColor(inc.estado),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                    const Spacer(),
                    Text(
                      '${comentarios.length} comentarios',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
          const SizedBox(height: 16),
          const Text('Desglose por tabla:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildCountCard('Aulas', _aulas.length, Icons.meeting_room, Colors.blue),
              _buildCountCard('Equipos', _equipos.length, Icons.devices, Colors.teal),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildCountCard('Incidencias', _incidencias.length, Icons.report_problem, Colors.orange),
              _buildCountCard('Comentarios', _comentarios.length, Icons.comment, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountCard(String title, int count, IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                  Text('$count filas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
