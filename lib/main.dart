import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'controllers/controllers.dart';
import 'database/database_helper.dart';
import 'database/database_seeder.dart';
import 'models/models.dart';

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
  final IncidenciasController? incidenciasCtrl;
  final AulasController? aulasCtrl;
  final EquiposController? equiposCtrl;

  const IncidenciasApp({
    super.key,
    this.incidenciasCtrl,
    this.aulasCtrl,
    this.equiposCtrl,
  });

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
      home: HomeScreen(
        incidenciasCtrl: incidenciasCtrl,
        aulasCtrl: aulasCtrl,
        equiposCtrl: equiposCtrl,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final IncidenciasController? incidenciasCtrl;
  final AulasController? aulasCtrl;
  final EquiposController? equiposCtrl;

  const HomeScreen({
    super.key,
    this.incidenciasCtrl,
    this.aulasCtrl,
    this.equiposCtrl,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // CONTROLADORES MVC (ChangeNotifier)
  late final IncidenciasController _incidenciasCtrl;
  late final AulasController _aulasCtrl;
  late final EquiposController _equiposCtrl;

  String? _dbPath;
  bool _fksEnabled = false;

  @override
  void initState() {
    super.initState();
    _incidenciasCtrl = widget.incidenciasCtrl ?? IncidenciasController();
    _aulasCtrl = widget.aulasCtrl ?? AulasController();
    _equiposCtrl = widget.equiposCtrl ?? EquiposController();

    _inicializarDatos();
  }

  @override
  void dispose() {
    if (widget.incidenciasCtrl == null) _incidenciasCtrl.dispose();
    if (widget.aulasCtrl == null) _aulasCtrl.dispose();
    if (widget.equiposCtrl == null) _equiposCtrl.dispose();
    super.dispose();
  }

  Future<void> _inicializarDatos() async {
    final status = await DatabaseHelper.instance.checkDatabaseStatus();
    if (mounted) {
      setState(() {
        _dbPath = status['path'] as String?;
        _fksEnabled = (status['foreignKeysEnabled'] as bool?) ?? false;
      });
    }

    if (widget.incidenciasCtrl == null) {
      await Future.wait([
        _aulasCtrl.loadAulas(),
        _equiposCtrl.loadEquipos(),
        _incidenciasCtrl.loadIncidencias(),
      ]);
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

  Future<void> _crearIncidenciaRapida() async {
    List<Equipo> equipos = _equiposCtrl.equipos;
    if (equipos.isEmpty) {
      await _equiposCtrl.loadEquipos();
      equipos = _equiposCtrl.equipos;
    }
    if (equipos.isEmpty) return;

    final equipo = equipos.first;
    final nueva = Incidencia(
      equipoId: equipo.id!,
      descripcion: 'Incidencia creada con ChangeNotifier MVC (${DateTime.now().second}s)',
      prioridad: Prioridad.alta,
      estado: Estado.abierta,
      fecha: DateTime.now(),
    );

    // El controlador añade la incidencia y notifica mediante ListenableBuilder
    await _incidenciasCtrl.createIncidencia(nueva);

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incidencia creada y lista refrescada reactivamente'),
          duration: Duration(milliseconds: 1500),
        ),
      );
    }
  }

  Future<void> _cerrarIncidencia(int id) async {
    await _incidenciasCtrl.cerrarIncidencia(id);
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incidencia #$id marcada como CERRADA'),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IncidenciasIES — MVC con ListenableBuilder'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Recargar controladores',
              onPressed: _inicializarDatos,
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Panel'),
              Tab(icon: Icon(Icons.alt_route), text: 'Incidencias (JOIN)'),
              Tab(icon: Icon(Icons.devices), text: 'Equipos y Aulas'),
              Tab(icon: Icon(Icons.storage), text: 'Estado BD'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 1. Pestaña Panel reactiva
            _buildPanelTab(),
            // 2. Pestaña Incidencias con ListenableBuilder
            _buildIncidenciasJoinTab(),
            // 3. Pestaña Equipos y Aulas reactiva
            _buildEquiposTab(),
            // 4. Pestaña Estado BD
            _buildStatusTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _crearIncidenciaRapida,
          icon: const Icon(Icons.add),
          label: const Text('Nueva Incidencia'),
        ),
      ),
    );
  }

  /// Pestaña 1: Panel reactivo con ListenableBuilder para métricas
  Widget _buildPanelTab() {
    return ListenableBuilder(
      listenable: _incidenciasCtrl,
      builder: (context, _) {
        if (_incidenciasCtrl.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final conteoEstado = _incidenciasCtrl.conteoEstado;
        final conteoPrioridad = _incidenciasCtrl.conteoPrioridad;
        final conteoPorAula = _incidenciasCtrl.conteoPorAula;

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
                  _buildMetricCard('Abiertas', conteoEstado[Estado.abierta] ?? 0, Colors.red[700]!, Icons.error_outline),
                  _buildMetricCard('En Proceso', conteoEstado[Estado.enProceso] ?? 0, Colors.blue[700]!, Icons.autorenew),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMetricCard('Resueltas', conteoEstado[Estado.resuelta] ?? 0, Colors.green[700]!, Icons.check_circle_outline),
                  _buildMetricCard('Cerradas', conteoEstado[Estado.cerrada] ?? 0, Colors.grey[700]!, Icons.archive_outlined),
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
                  _buildMetricCard('Urgente', conteoPrioridad[Prioridad.urgente] ?? 0, Colors.red[900]!, Icons.priority_high),
                  _buildMetricCard('Alta', conteoPrioridad[Prioridad.alta] ?? 0, Colors.orange[800]!, Icons.trending_up),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMetricCard('Media', conteoPrioridad[Prioridad.media] ?? 0, Colors.amber[800]!, Icons.remove),
                  _buildMetricCard('Baja', conteoPrioridad[Prioridad.baja] ?? 0, Colors.blueGrey, Icons.trending_down),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Incidencias por Aula (JOIN doble & COUNT)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: conteoPorAula.map((row) {
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
      },
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

  /// Pestaña 2: Vista de Incidencias actualizada con ListenableBuilder (JOIN doble y botón cerrar)
  Widget _buildIncidenciasJoinTab() {
    return ListenableBuilder(
      listenable: Listenable.merge([_incidenciasCtrl, _aulasCtrl]),
      builder: (context, _) {
        final aulas = _aulasCtrl.aulas;
        final incidencias = _incidenciasCtrl.incidencias;
        final filtroAulaId = _incidenciasCtrl.filtroAulaId;

        return Column(
          children: [
            // Filtro por aula
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
                      value: filtroAulaId,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Todas las aulas (JOIN completo)'),
                        ),
                        ...aulas.map((a) => DropdownMenuItem<int?>(
                              value: a.id,
                              child: Text('${a.nombre} (Planta ${a.planta})'),
                            )),
                      ],
                      onChanged: (val) {
                        _incidenciasCtrl.setFiltroAula(val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Lista de Incidencias
            Expanded(
              child: _incidenciasCtrl.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : incidencias.isEmpty
                      ? const Center(child: Text('No hay incidencias para este filtro.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: incidencias.length,
                          itemBuilder: (context, index) {
                            final det = incidencias[index];
                            final bool esCerrada = det.estado == Estado.cerrada;

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
                                          onPressed: () => _incidenciasCtrl.deleteIncidencia(det.id),
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
                                        const Spacer(),
                                        // Botón para CERRAR incidencia sin recargar pantalla
                                        if (!esCerrada)
                                          TextButton.icon(
                                            onPressed: () => _cerrarIncidencia(det.id),
                                            icon: const Icon(Icons.check, size: 16, color: Colors.green),
                                            label: const Text('Cerrar', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.green[50],
                                              visualDensity: VisualDensity.compact,
                                            ),
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
      },
    );
  }

  /// Pestaña 3: Equipos y Aulas reactivo con ListenableBuilder
  Widget _buildEquiposTab() {
    return ListenableBuilder(
      listenable: Listenable.merge([_aulasCtrl, _equiposCtrl]),
      builder: (context, _) {
        if (_aulasCtrl.isLoading || _equiposCtrl.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final aulas = _aulasCtrl.aulas;
        final equipos = _equiposCtrl.equipos;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: aulas.length,
          itemBuilder: (context, index) {
            final aula = aulas[index];
            final equiposAula = equipos.where((e) => e.aulaId == aula.id).toList();

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
      },
    );
  }

  /// Pestaña 4: Estado BD reactivo con ListenableBuilder
  Widget _buildStatusTab() {
    return ListenableBuilder(
      listenable: Listenable.merge([_aulasCtrl, _equiposCtrl, _incidenciasCtrl]),
      builder: (context, _) {
        final totalFilas = _aulasCtrl.totalAulas +
            _equiposCtrl.totalEquipos +
            _incidenciasCtrl.totalIncidencias;

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
                        title: const Text('Total registros en memoria reactiva'),
                        subtitle: Text('$totalFilas registros sincronizados por ChangeNotifier'),
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
      },
    );
  }
}
