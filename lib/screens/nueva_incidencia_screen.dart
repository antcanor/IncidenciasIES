import 'package:flutter/material.dart';
import '../controllers/controllers.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import 'prototipo/export_visual_incidencia.dart';

/// =============================================================================
/// PANTALLA REFACTORIZADA MANUALMENTE (RA1.b, c, e, f)
/// Prototipo adaptado desde editor visual aplicando:
/// - Wrap with Form, Wrap with SingleChildScrollView, Wrap with Padding, Wrap with Card.
/// - Extract Widget: UbicacionSelectorWidget, PrioridadChipsSelector, LiveTicketPreviewCard.
/// - Conexión MVC y persistencia real en SQLite.
/// =============================================================================
class NuevaIncidenciaScreen extends StatefulWidget {
  final int? equipoId;
  final IncidenciasController? incidenciasCtrl;
  final AulasController? aulasCtrl;
  final EquiposController? equiposCtrl;

  const NuevaIncidenciaScreen({
    super.key,
    this.equipoId,
    this.incidenciasCtrl,
    this.aulasCtrl,
    this.equiposCtrl,
  });

  @override
  State<NuevaIncidenciaScreen> createState() => _NuevaIncidenciaScreenState();
}

class _NuevaIncidenciaScreenState extends State<NuevaIncidenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descripcionCtrl = TextEditingController();

  late final IncidenciasController _incidenciasCtrl;
  late final AulasController _aulasCtrl;
  late final EquiposController _equiposCtrl;

  int? _selectedAulaId;
  int? _selectedEquipoId;
  Prioridad _selectedPrioridad = Prioridad.alta;
  final Estado _selectedEstado = Estado.abierta;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _incidenciasCtrl = widget.incidenciasCtrl ?? IncidenciasController();
    _aulasCtrl = widget.aulasCtrl ?? AulasController();
    _equiposCtrl = widget.equiposCtrl ?? EquiposController();

    _selectedEquipoId = widget.equipoId;
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      if (_aulasCtrl.aulas.isEmpty) await _aulasCtrl.loadAulas();
      if (!mounted) return;
      if (_equiposCtrl.equipos.isEmpty) await _equiposCtrl.loadEquipos();
      if (!mounted) return;

      if (_selectedEquipoId != null) {
        final match = _equiposCtrl.equipos.where((e) => e.id == _selectedEquipoId);
        if (match.isNotEmpty) {
          setState(() {
            _selectedAulaId = match.first.aulaId;
          });
        }
      } else if (_aulasCtrl.aulas.isNotEmpty && _selectedAulaId == null) {
        setState(() {
          _selectedAulaId = _aulasCtrl.aulas.first.id;
          final eqList = _equiposCtrl.equipos.where((e) => e.aulaId == _selectedAulaId).toList();
          if (eqList.isNotEmpty) {
            _selectedEquipoId = eqList.first.id;
          }
        });
      }
    } catch (_) {
      // Ignorar en tests de navegación sin BD
    }
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarIncidencia() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEquipoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un equipo.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final nueva = Incidencia(
        equipoId: _selectedEquipoId!,
        descripcion: _descripcionCtrl.text.trim(),
        prioridad: _selectedPrioridad,
        estado: _selectedEstado,
        fecha: DateTime.now(),
      );

      await _incidenciasCtrl.createIncidencia(nueva);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incidencia guardada con éxito en la base de datos.'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Nueva Incidencia'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Botón para inspeccionar el prototipo visual raw original
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: 'Ver prototipo exportado en bruto',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExportVisualIncidenciaWidget()),
              );
            },
          ),
        ],
      ),
      // REFACTOR: Wrap with Form para validación y estado reactivo
      body: Form(
        key: _formKey,
        // REFACTOR: Wrap with SingleChildScrollView para evitar overflow al abrir teclado
        child: SingleChildScrollView(
          // REFACTOR: Wrap with Padding para alineación coherente del tema
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Formulario de Incidencia', style: theme.textTheme.titleMedium),
              if (widget.equipoId != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Equipo asignado previamente: #${widget.equipoId}',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSecondaryContainer),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // EXTRACT WIDGET 1: Selector dinámico de Aula y Equipo
              UbicacionSelectorWidget(
                aulasCtrl: _aulasCtrl,
                equiposCtrl: _equiposCtrl,
                selectedAulaId: _selectedAulaId,
                selectedEquipoId: _selectedEquipoId,
                onAulaChanged: (newAulaId) {
                  setState(() {
                    _selectedAulaId = newAulaId;
                    final eqList = _equiposCtrl.equipos.where((e) => e.aulaId == newAulaId).toList();
                    _selectedEquipoId = eqList.isNotEmpty ? eqList.first.id : null;
                  });
                },
                onEquipoChanged: (newEqId) {
                  setState(() => _selectedEquipoId = newEqId);
                },
              ),
              const SizedBox(height: 16),

              // EXTRACT WIDGET 2: Campo de descripción con validación
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Descripción de la Avería', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descripcionCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Descripción de la avería',
                          hintText: 'Detalla el problema (p. ej. pantalla azul, tecla rota...)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Debes introducir una descripción de la avería.';
                          }
                          if (value.trim().length < 5) {
                            return 'La descripción debe tener al menos 5 caracteres.';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // EXTRACT WIDGET 3: Selector de Prioridad con Chips semánticos
              PrioridadChipsSelector(
                prioridadSeleccionada: _selectedPrioridad,
                onPrioridadChanged: (p) => setState(() => _selectedPrioridad = p),
              ),
              const SizedBox(height: 16),

              // EXTRACT WIDGET 4: Previsualización reactiva del Ticket en tiempo real
              LiveTicketPreviewCard(
                aulaNombre: _aulasCtrl.aulas
                    .where((a) => a.id == _selectedAulaId)
                    .map((a) => a.nombre)
                    .firstOrNull ?? 'Aula no seleccionada',
                equipoCodigo: _equiposCtrl.equipos
                    .where((e) => e.id == _selectedEquipoId)
                    .map((e) => '${e.codigo} (${e.tipo})')
                    .firstOrNull ?? 'Equipo no seleccionado',
                descripcion: _descripcionCtrl.text.isEmpty
                    ? 'Sin descripción introducida'
                    : _descripcionCtrl.text,
                prioridad: _selectedPrioridad,
                estado: _selectedEstado,
              ),
              const SizedBox(height: 24),

              // EXTRACT WIDGET 5: Botones de Acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar y Volver'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _guardarIncidencia,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Guardar Incidencia'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =============================================================================
/// EXTRACT WIDGET: Selector de Ubicación (Aula + Equipo)
/// =============================================================================
class UbicacionSelectorWidget extends StatelessWidget {
  final AulasController aulasCtrl;
  final EquiposController equiposCtrl;
  final int? selectedAulaId;
  final int? selectedEquipoId;
  final ValueChanged<int?> onAulaChanged;
  final ValueChanged<int?> onEquipoChanged;

  const UbicacionSelectorWidget({
    super.key,
    required this.aulasCtrl,
    required this.equiposCtrl,
    required this.selectedAulaId,
    required this.selectedEquipoId,
    required this.onAulaChanged,
    required this.onEquipoChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aulas = aulasCtrl.aulas;
    final equiposAula = selectedAulaId != null
        ? equiposCtrl.equipos.where((e) => e.aulaId == selectedAulaId).toList()
        : <Equipo>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ubicación y Dispositivo', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: selectedAulaId,
              decoration: const InputDecoration(
                labelText: 'Aula / Espacio',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.meeting_room),
              ),
              items: aulas.map((a) {
                return DropdownMenuItem<int>(
                  value: a.id,
                  child: Text('${a.nombre} (P${a.planta})'),
                );
              }).toList(),
              onChanged: onAulaChanged,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: selectedEquipoId,
              decoration: const InputDecoration(
                labelText: 'Equipo Afectado',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.devices),
              ),
              items: equiposAula.map((e) {
                return DropdownMenuItem<int>(
                  value: e.id,
                  child: Text('${e.codigo} • ${e.tipo}'),
                );
              }).toList(),
              onChanged: onEquipoChanged,
            ),
          ],
        ),
      ),
    );
  }
}

/// =============================================================================
/// EXTRACT WIDGET: Selector de Prioridad con Chips Semánticos
/// =============================================================================
class PrioridadChipsSelector extends StatelessWidget {
  final Prioridad prioridadSeleccionada;
  final ValueChanged<Prioridad> onPrioridadChanged;

  const PrioridadChipsSelector({
    super.key,
    required this.prioridadSeleccionada,
    required this.onPrioridadChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final incidenciasColors = theme.extension<IncidenciasColors>() ?? IncidenciasColors.light;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nivel de Urgencia (Prioridad)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Prioridad.values.map((p) {
                final isSelected = p == prioridadSeleccionada;
                final chipColor = incidenciasColors.colorParaPrioridad(p);

                return ChoiceChip(
                  label: Text(
                    p.value,
                    style: TextStyle(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: chipColor,
                  avatar: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                  onSelected: (_) => onPrioridadChanged(p),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// =============================================================================
/// EXTRACT WIDGET: Tarjeta de Previsualización en Vivo
/// =============================================================================
class LiveTicketPreviewCard extends StatelessWidget {
  final String aulaNombre;
  final String equipoCodigo;
  final String descripcion;
  final Prioridad prioridad;
  final Estado estado;

  const LiveTicketPreviewCard({
    super.key,
    required this.aulaNombre,
    required this.equipoCodigo,
    required this.descripcion,
    required this.prioridad,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final incidenciasColors = theme.extension<IncidenciasColors>() ?? IncidenciasColors.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview_outlined, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Previsualización del Ticket IES',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Chip(
                label: Text(
                  prioridad.value,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
                backgroundColor: incidenciasColors.colorParaPrioridad(prioridad),
                visualDensity: VisualDensity.compact,
                side: BorderSide.none,
              ),
            ],
          ),
          const Divider(height: 16),
          Text(
            'Ubicación: $aulaNombre',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            'Dispositivo: $equipoCodigo',
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.secondary),
          ),
          const SizedBox(height: 6),
          Text(
            '"$descripcion"',
            style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
