import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'controllers/controllers.dart';
import 'database/database_helper.dart';
import 'database/database_seeder.dart';
import 'models/models.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializar factory según la plataforma
  DatabaseHelper.initializeDatabaseFactory();

  // 2. Abrir base de datos y cargar seeder si está vacía
  await DatabaseHelper.instance.database;
  final seeder = DatabaseSeeder();
  await seeder.seedIfEmpty();

  final themeController = ThemeController();

  runApp(IncidenciasApp(themeController: themeController));
}

class IncidenciasApp extends StatelessWidget {
  final IncidenciasController? incidenciasCtrl;
  final AulasController? aulasCtrl;
  final EquiposController? equiposCtrl;
  final ThemeController? themeController;

  const IncidenciasApp({
    super.key,
    this.incidenciasCtrl,
    this.aulasCtrl,
    this.equiposCtrl,
    this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    final themeCtrl = themeController ?? ThemeController();

    return ListenableBuilder(
      listenable: themeCtrl,
      builder: (context, _) {
        return MaterialApp(
          title: 'IncidenciasIES',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeCtrl.themeMode,
          home: HomeScreen(
            incidenciasCtrl: incidenciasCtrl,
            aulasCtrl: aulasCtrl,
            equiposCtrl: equiposCtrl,
            themeController: themeCtrl,
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final IncidenciasController? incidenciasCtrl;
  final AulasController? aulasCtrl;
  final EquiposController? equiposCtrl;
  final ThemeController? themeController;

  const HomeScreen({
    super.key,
    this.incidenciasCtrl,
    this.aulasCtrl,
    this.equiposCtrl,
    this.themeController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // CONTROLADORES MVC (ChangeNotifier)
  late final IncidenciasController _incidenciasCtrl;
  late final AulasController _aulasCtrl;
  late final EquiposController _equiposCtrl;
  late final ThemeController _themeCtrl;

  String? _dbPath;
  bool _fksEnabled = false;

  @override
  void initState() {
    super.initState();
    _incidenciasCtrl = widget.incidenciasCtrl ?? IncidenciasController();
    _aulasCtrl = widget.aulasCtrl ?? AulasController();
    _equiposCtrl = widget.equiposCtrl ?? EquiposController();
    _themeCtrl = widget.themeController ?? ThemeController();

    _inicializarDatos();
  }

  @override
  void dispose() {
    if (widget.incidenciasCtrl == null) _incidenciasCtrl.dispose();
    if (widget.aulasCtrl == null) _aulasCtrl.dispose();
    if (widget.equiposCtrl == null) _equiposCtrl.dispose();
    if (widget.themeController == null) _themeCtrl.dispose();
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
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IncidenciasIES — Material 3'),
          actions: [
            // Botón para cambiar entre Tema Claro y Tema Oscuro
            ListenableBuilder(
              listenable: _themeCtrl,
              builder: (context, _) {
                final isDark = _themeCtrl.isDarkMode;
                return IconButton(
                  key: const Key('theme_toggle_button'),
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  tooltip: isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
                  onPressed: _themeCtrl.toggleTheme,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Recargar controladores',
              onPressed: _inicializarDatos,
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.onPrimary,
            tabs: const [
              Tab(icon: Icon(Icons.dashboard), text: 'Panel'),
              Tab(icon: Icon(Icons.alt_route), text: 'Incidencias (JOIN)'),
              Tab(icon: Icon(Icons.devices), text: 'Equipos y Aulas'),
              Tab(icon: Icon(Icons.storage), text: 'Estado BD'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPanelTab(),
            _buildIncidenciasJoinTab(),
            _buildEquiposTab(),
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

  /// Pestaña 1: Panel con métricas integradas con el Tema Material 3
  Widget _buildPanelTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final incidenciasColors = theme.extension<IncidenciasColors>()!;

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
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildMetricCard(
                    'Abiertas',
                    conteoEstado[Estado.abierta] ?? 0,
                    incidenciasColors.estadoAbierta,
                    Icons.error_outline,
                  ),
                  _buildMetricCard(
                    'En Proceso',
                    conteoEstado[Estado.enProceso] ?? 0,
                    incidenciasColors.estadoEnProceso,
                    Icons.autorenew,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMetricCard(
                    'Resueltas',
                    conteoEstado[Estado.resuelta] ?? 0,
                    incidenciasColors.estadoResuelta,
                    Icons.check_circle_outline,
                  ),
                  _buildMetricCard(
                    'Cerradas',
                    conteoEstado[Estado.cerrada] ?? 0,
                    incidenciasColors.estadoCerrada,
                    Icons.archive_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Métricas por Prioridad (COUNT)',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildMetricCard(
                    'Urgente',
                    conteoPrioridad[Prioridad.urgente] ?? 0,
                    incidenciasColors.prioridadUrgente,
                    Icons.priority_high,
                  ),
                  _buildMetricCard(
                    'Alta',
                    conteoPrioridad[Prioridad.alta] ?? 0,
                    incidenciasColors.prioridadAlta,
                    Icons.trending_up,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMetricCard(
                    'Media',
                    conteoPrioridad[Prioridad.media] ?? 0,
                    incidenciasColors.prioridadMedia,
                    Icons.remove,
                  ),
                  _buildMetricCard(
                    'Baja',
                    conteoPrioridad[Prioridad.baja] ?? 0,
                    incidenciasColors.prioridadBaja,
                    Icons.trending_down,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Incidencias por Aula (JOIN doble & COUNT)',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Card(
                child: Column(
                  children: conteoPorAula.map((row) {
                    final nombre = row['aula_nombre'] as String;
                    final planta = row['aula_planta'] as int;
                    final total = row['total_incidencias'] as int;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        child: Text(
                          'P$planta',
                          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(nombre, style: theme.textTheme.titleSmall),
                      subtitle: Text('Planta $planta', style: theme.textTheme.bodySmall),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: total > 0 ? colorScheme.tertiaryContainer : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$total incidencias',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: total > 0 ? colorScheme.onTertiaryContainer : colorScheme.onSurfaceVariant,
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

  Widget _buildMetricCard(String title, int count, Color accentColor, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Card(
        color: colorScheme.surface,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: accentColor, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pestaña 2: Vista de Incidencias con colores semánticos de Tema
  Widget _buildIncidenciasJoinTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final incidenciasColors = theme.extension<IncidenciasColors>()!;

    return ListenableBuilder(
      listenable: Listenable.merge([_incidenciasCtrl, _aulasCtrl]),
      builder: (context, _) {
        final aulas = _aulasCtrl.aulas;
        final incidencias = _incidenciasCtrl.incidencias;
        final filtroAulaId = _incidenciasCtrl.filtroAulaId;

        return Column(
          children: [
            // Filtro por aula usando surfaceContainerHighest
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Filtrar Aula:', style: theme.textTheme.titleSmall),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<int?>(
                      value: filtroAulaId,
                      isExpanded: true,
                      dropdownColor: colorScheme.surface,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Todas las aulas (JOIN completo)', style: theme.textTheme.bodyMedium),
                        ),
                        ...aulas.map((a) => DropdownMenuItem<int?>(
                              value: a.id,
                              child: Text('${a.nombre} (Planta ${a.planta})', style: theme.textTheme.bodyMedium),
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
                      ? Center(child: Text('No hay incidencias para este filtro.', style: theme.textTheme.bodyMedium))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: incidencias.length,
                          itemBuilder: (context, index) {
                            final det = incidencias[index];
                            final bool esCerrada = det.estado == Estado.cerrada;
                            final colorPrioridad = incidenciasColors.colorParaPrioridad(det.prioridad);
                            final colorEstado = incidenciasColors.colorParaEstado(det.estado);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
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
                                            Icon(Icons.meeting_room, size: 16, color: colorScheme.primary),
                                            const SizedBox(width: 4),
                                            Text(
                                              det.aulaNombre,
                                              style: theme.textTheme.titleSmall,
                                            ),
                                            Text(
                                              ' (P${det.aulaPlanta})',
                                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 20),
                                          tooltip: 'Eliminar incidencia',
                                          onPressed: () => _incidenciasCtrl.deleteIncidencia(det.id),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.devices, size: 15, color: colorScheme.secondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${det.equipoCodigo} • ${det.equipoTipo}',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.secondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(det.descripcion, style: theme.textTheme.bodyMedium),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Chip(
                                          label: Text(
                                            det.prioridad.value,
                                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                                          ),
                                          backgroundColor: colorPrioridad,
                                          visualDensity: VisualDensity.compact,
                                          side: BorderSide.none,
                                        ),
                                        const SizedBox(width: 8),
                                        Chip(
                                          label: Text(
                                            det.estado.value,
                                            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                                          ),
                                          backgroundColor: colorEstado,
                                          visualDensity: VisualDensity.compact,
                                          side: BorderSide.none,
                                        ),
                                        const Spacer(),
                                        if (!esCerrada)
                                          TextButton.icon(
                                            onPressed: () => _cerrarIncidencia(det.id),
                                            icon: Icon(Icons.check, size: 16, color: colorScheme.secondary),
                                            label: Text(
                                              'Cerrar',
                                              style: TextStyle(
                                                color: colorScheme.secondary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              backgroundColor: colorScheme.secondaryContainer.withValues(alpha: 0.5),
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

  /// Pestaña 3: Equipos y Aulas
  Widget _buildEquiposTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                leading: Icon(Icons.meeting_room, color: colorScheme.primary),
                title: Text(aula.nombre, style: theme.textTheme.titleMedium),
                subtitle: Text(
                  'Planta ${aula.planta} • ${equiposAula.length} equipos asignados',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                children: equiposAula.map((eq) {
                  return ListTile(
                    leading: Icon(Icons.devices, size: 20, color: colorScheme.secondary),
                    title: Text(eq.codigo, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    subtitle: Text(eq.tipo, style: theme.textTheme.bodySmall),
                    trailing: Text(
                      'ID #${eq.id}',
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  /// Pestaña 4: Estado BD con estilo adaptativo
  Widget _buildStatusTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estado de la Base de Datos', style: theme.textTheme.titleMedium),
                      const Divider(height: 24),
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.computer, color: colorScheme.primary),
                        title: Text('Plataforma activa', style: theme.textTheme.titleSmall),
                        subtitle: Text(_platformName, style: theme.textTheme.bodySmall),
                      ),
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.vpn_key, color: colorScheme.primary),
                        title: Text('PRAGMA foreign_keys', style: theme.textTheme.titleSmall),
                        subtitle: Text(
                          _fksEnabled ? 'ON (1 - Activadas)' : 'OFF (Desactivadas)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _fksEnabled ? colorScheme.primary : colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.storage, color: colorScheme.primary),
                        title: Text('Total registros sincronizados', style: theme.textTheme.titleSmall),
                        subtitle: Text(
                          '$totalFilas registros sincronizados en ChangeNotifier',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.folder_open, color: colorScheme.primary),
                        title: Text('Ruta SQLite', style: theme.textTheme.titleSmall),
                        subtitle: SelectableText(_dbPath ?? '', style: theme.textTheme.bodySmall),
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
