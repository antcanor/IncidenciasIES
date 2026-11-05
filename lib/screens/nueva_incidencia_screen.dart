import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../controllers/controllers.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import 'prototipo/export_visual_incidencia.dart';

/// =============================================================================
/// PANTALLA 4: NUEVA INCIDENCIA (FORMULARIO CON VALIDACIÓN Y DICTADO POR VOZ)
/// - Flujo guiado: Aula → Equipo → Descripción → Prioridad
/// - Validación de formulario con mensajes de error descriptivos.
/// - Botón de dictado por voz (preparado para conectar con módulo STT).
/// - Previsualización de ticket reactiva en tiempo real.
/// - Persistencia real en SQLite y actualización automática de la lista.
/// =============================================================================
class NuevaIncidenciaScreen extends StatefulWidget {
  final int? equipoId;
  final IncidenciasController? incidenciasCtrl;
  final AulasController? aulasCtrl;
  final EquiposController? equiposCtrl;
  final VoidCallback? onDictadoVoz;

  const NuevaIncidenciaScreen({
    super.key,
    this.equipoId,
    this.incidenciasCtrl,
    this.aulasCtrl,
    this.equiposCtrl,
    this.onDictadoVoz,
  });

  @override
  State<NuevaIncidenciaScreen> createState() => NuevaIncidenciaScreenState();
}

class NuevaIncidenciaScreenState extends State<NuevaIncidenciaScreen> {
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
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _speechAvailable = false;
  bool _isListening = false;
  String? _speechError;

  @override
  void initState() {
    super.initState();
    _incidenciasCtrl = widget.incidenciasCtrl ?? IncidenciasController();
    _aulasCtrl = widget.aulasCtrl ?? AulasController();
    _equiposCtrl = widget.equiposCtrl ?? EquiposController();

    _selectedEquipoId = widget.equipoId;
    _cargarDatos();
  }

  Future<void> _inicializarVoz() async {
    try {
      final available = await _speech.initialize(
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _speechError = error.errorMsg;
          });
        },
        onStatus: (status) {
          if (!mounted) return;
          setState(() => _isListening = status == 'listening');
        },
      );
      if (mounted) setState(() => _speechAvailable = available);
    } catch (error) {
      if (mounted) {
        setState(
          () => _speechError = 'No se pudo inicializar el dictado: $error',
        );
      }
    }
  }

  Future<void> _cargarDatos() async {
    try {
      if (_aulasCtrl.aulas.isEmpty) await _aulasCtrl.loadAulas();
      if (!mounted) return;
      if (_equiposCtrl.equipos.isEmpty) await _equiposCtrl.loadEquipos();
      if (!mounted) return;

      if (_selectedEquipoId != null) {
        final match = _equiposCtrl.equipos.where(
          (e) => e.id == _selectedEquipoId,
        );
        if (match.isNotEmpty) {
          setState(() {
            _selectedAulaId = match.first.aulaId;
          });
        }
      }
    } catch (_) {
      // Ignorar en tests de navegación sin BD
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> activarDictadoVoz() async {
    if (widget.onDictadoVoz != null) {
      widget.onDictadoVoz!();
      return;
    }

    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    if (!_speechAvailable) {
      await _inicializarVoz();
    }
    if (!_speechAvailable) {
      if (!mounted) return;
      setState(
        () => _speechError =
            'El dictado por voz no está disponible en este dispositivo.',
      );
      return;
    }
    if (_isListening) {
      await _speech.stop();
      return;
    }
    setState(() => _speechError = null);
    await _speech.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        localeId: isEnglish ? 'en_US' : 'es_ES',
      ),
    );
    if (mounted) setState(() => _isListening = true);
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    if (result.recognizedWords.isNotEmpty) {
      _descripcionCtrl
        ..text = result.recognizedWords
        ..selection = TextSelection.collapsed(
          offset: result.recognizedWords.length,
        );
      if (mounted) setState(() {});
    }
    if (result.finalResult) {
      if (mounted) setState(() => _isListening = false);
      if (!mounted) return;
      final isEnglish = Localizations.localeOf(context).languageCode == 'en';
      await _tts.setLanguage(isEnglish ? 'en-US' : 'es-ES');
      await _tts.speak(
        isEnglish ? 'Description dictated' : 'Descripción dictada',
      );
    }
  }

  Future<bool> guardarIncidencia() async {
    final bool isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid || _selectedEquipoId == null || _selectedAulaId == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          key: Key('snackbar_error_validacion'),
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Por favor, completa correctamente todos los campos obligatorios.',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      return false;
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

      final creada = await _incidenciasCtrl.createIncidencia(nueva);

      if (mounted) {
        if (creada != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              key: const Key('snackbar_incidencia_guardada'),
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Incidencia #${creada.id ?? ""} guardada con éxito en la base de datos.',
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _incidenciasCtrl.errorMessage ??
                    'Error al guardar la incidencia.',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
          return false;
        }
      }
      return false;
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
                MaterialPageRoute(
                  builder: (_) => const ExportVisualIncidenciaWidget(),
                ),
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
              Text(
                'Formulario de Incidencia',
                style: theme.textTheme.titleMedium,
              ),
              if (widget.equipoId != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Equipo asignado previamente: #${widget.equipoId}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // PASO 1 & 2: Selector dinámico de Aula y Equipo
              UbicacionSelectorWidget(
                aulasCtrl: _aulasCtrl,
                equiposCtrl: _equiposCtrl,
                selectedAulaId: _selectedAulaId,
                selectedEquipoId: _selectedEquipoId,
                onAulaChanged: (newAulaId) {
                  setState(() {
                    _selectedAulaId = newAulaId;
                    _selectedEquipoId = null;
                  });
                },
                onEquipoChanged: (newEqId) {
                  setState(() => _selectedEquipoId = newEqId);
                },
              ),
              const SizedBox(height: 16),

              // PASO 3: Campo de descripción con validación y botón de dictado por voz
              Card(
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
                              Icon(
                                Icons.edit_note_outlined,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Descripción de la Avería',
                                style: theme.textTheme.titleSmall,
                              ),
                            ],
                          ),
                          // Botón de dictado por voz (se conecta luego con la voz)
                          FilledButton.tonalIcon(
                            key: const Key('btn_dictado_voz'),
                            onPressed: activarDictadoVoz,
                            icon: Icon(
                              _isListening ? Icons.stop : Icons.mic,
                              size: 18,
                            ),
                            label: Text(
                              _isListening ? 'Escuchando...' : 'Dictar por voz',
                            ),
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_isListening || _speechError != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _isListening
                                  ? Icons.graphic_eq
                                  : Icons.info_outline,
                              size: 18,
                              color: _isListening
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isListening
                                    ? 'Escuchando... habla ahora. Pulsa de nuevo para detener.'
                                    : _speechError!,
                                key: const Key('estado_dictado_voz'),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _isListening
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('input_descripcion'),
                        controller: _descripcionCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Descripción de la avería *',
                          hintText: 'Detalla el problema (p. ej. pantalla azul, no enciende, tecla rota...)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.description),
                          suffixIcon: Tooltip(
                            message: _isListening
                                ? 'Detener dictado'
                                : 'Dictar descripción por voz',
                            child: IconButton(
                              key: const Key('btn_dictado_voz_suffix'),
                              icon: Icon(_isListening ? Icons.stop : Icons.mic),
                              onPressed: activarDictadoVoz,
                            ),
                          ),
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

              // PASO 4: Selector de Prioridad con Chips semánticos
              PrioridadChipsSelector(
                prioridadSeleccionada: _selectedPrioridad,
                onPrioridadChanged: (p) =>
                    setState(() => _selectedPrioridad = p),
              ),
              const SizedBox(height: 16),

              // Previsualización reactiva del Ticket en tiempo real
              LiveTicketPreviewCard(
                aulaNombre:
                    _aulasCtrl.aulas
                        .where((a) => a.id == _selectedAulaId)
                        .map((a) => a.nombre)
                        .firstOrNull ??
                    'Aula no seleccionada',
                equipoCodigo:
                    _equiposCtrl.equipos
                        .where((e) => e.id == _selectedEquipoId)
                        .map((e) => '${e.codigo} (${e.tipo})')
                        .firstOrNull ??
                    'Equipo no seleccionado',
                descripcion: _descripcionCtrl.text.isEmpty
                    ? 'Sin descripción introducida'
                    : _descripcionCtrl.text,
                prioridad: _selectedPrioridad,
                estado: _selectedEstado,
              ),
              const SizedBox(height: 24),

              // Botones de Acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('btn_cancelar_incidencia'),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar y Volver'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('btn_guardar_incidencia'),
                      onPressed: _isSaving ? null : guardarIncidencia,
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

    final currentAulaValue = aulas.any((a) => a.id == selectedAulaId)
        ? selectedAulaId
        : null;
    final currentEquipoValue = equiposAula.any((e) => e.id == selectedEquipoId)
        ? selectedEquipoId
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.meeting_room_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ubicación y Dispositivo',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              key: const Key('dropdown_aula'),
              initialValue: currentAulaValue,
              decoration: const InputDecoration(
                labelText: 'Aula / Espacio *',
                hintText: 'Selecciona el aula',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.meeting_room),
              ),
              items: aulas.map((a) {
                return DropdownMenuItem<int>(
                  value: a.id,
                  child: Text('${a.nombre} (P${a.planta})'),
                );
              }).toList(),
              validator: (val) {
                if (val == null) {
                  return 'Por favor, selecciona un aula.';
                }
                return null;
              },
              onChanged: onAulaChanged,
            ),
            const SizedBox(height: 12),
            KeyedSubtree(
              key: ValueKey('subtree_equipo_${selectedAulaId ?? "none"}'),
              child: DropdownButtonFormField<int>(
                key: const Key('dropdown_equipo'),
                initialValue: currentEquipoValue,
                decoration: InputDecoration(
                  labelText: 'Equipo Afectado *',
                  hintText: selectedAulaId == null
                      ? 'Selecciona un aula primero'
                      : (equiposAula.isEmpty
                            ? 'No hay equipos en esta aula'
                            : 'Selecciona el equipo'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.devices),
                ),
                items: equiposAula.map((e) {
                  return DropdownMenuItem<int>(
                    value: e.id,
                    child: Text('${e.codigo} • ${e.tipo}'),
                  );
                }).toList(),
                validator: (val) {
                  if (val == null) {
                    return 'Por favor, selecciona un equipo.';
                  }
                  return null;
                },
                onChanged: equiposAula.isEmpty ? null : onEquipoChanged,
              ),
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
    final incidenciasColors =
        theme.extension<IncidenciasColors>() ?? IncidenciasColors.light;

    return Card(
      key: const Key('card_prioridad_selector'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Nivel de Urgencia (Prioridad)',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Prioridad.values.map((p) {
                final isSelected = p == prioridadSeleccionada;
                final chipColor = incidenciasColors.colorParaPrioridad(p);

                return ChoiceChip(
                  key: Key('chip_prioridad_${p.name}'),
                  label: Text(
                    p.value,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
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
    final incidenciasColors =
        theme.extension<IncidenciasColors>() ?? IncidenciasColors.light;

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
              Icon(
                Icons.preview_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
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
                backgroundColor: incidenciasColors.colorParaPrioridad(
                  prioridad,
                ),
                visualDensity: VisualDensity.compact,
                side: BorderSide.none,
              ),
            ],
          ),
          const Divider(height: 16),
          Text(
            'Ubicación: $aulaNombre',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Dispositivo: $equipoCodigo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '"$descripcion"',
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
