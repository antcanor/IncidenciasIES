import 'package:flutter/material.dart';

import '../controllers/controllers.dart';
import '../models/aula.dart';
import '../models/equipo.dart';
import '../repositories/aula_repository.dart';

class NuevoEquipoScreen extends StatefulWidget {
  final int? aulaId;
  final Equipo? equipo;
  final EquiposController? controller;

  const NuevoEquipoScreen({
    super.key,
    this.aulaId,
    this.equipo,
    this.controller,
  });

  @override
  State<NuevoEquipoScreen> createState() => _NuevoEquipoScreenState();
}

class _NuevoEquipoScreenState extends State<NuevoEquipoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codigo;
  late final TextEditingController _tipo;
  late final EquiposController _controller;
  final _aulaRepository = AulaRepository();
  List<Aula> _aulas = [];
  int? _selectedAulaId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? EquiposController();
    _codigo = TextEditingController(text: widget.equipo?.codigo);
    _tipo = TextEditingController(text: widget.equipo?.tipo);
    _selectedAulaId = widget.equipo?.aulaId ?? widget.aulaId;
    _loadAulas();
  }

  Future<void> _loadAulas() async {
    final aulas = await _aulaRepository.getAll();
    if (mounted) setState(() => _aulas = aulas);
  }

  @override
  void dispose() {
    _codigo.dispose();
    _tipo.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedAulaId == null) return;
    setState(() => _saving = true);
    final equipo = Equipo(
      id: widget.equipo?.id,
      aulaId: _selectedAulaId!,
      tipo: _tipo.text.trim(),
      codigo: _codigo.text.trim(),
    );
    final success = widget.equipo == null
        ? await _controller.createEquipo(equipo) != null
        : await _controller.updateEquipo(equipo);
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.errorMessage ?? 'No se pudo guardar el equipo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.equipo != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Editar Equipo' : 'Registrar Nuevo Equipo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _codigo,
              decoration: const InputDecoration(
                labelText: 'Código de Inventario',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Introduce un código.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de Dispositivo',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Introduce un tipo.'
                  : null,
            ),
            const SizedBox(height: 16),
            if (!editing && widget.aulaId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text('Aula asignada por defecto: #${widget.aulaId}'),
              ),
            DropdownButtonFormField<int>(
              key: ValueKey(_aulas.length),
              initialValue: _aulas.any((aula) => aula.id == _selectedAulaId)
                  ? _selectedAulaId
                  : null,
              decoration: const InputDecoration(
                labelText: 'Aula',
                border: OutlineInputBorder(),
              ),
              items: _aulas.where((aula) => aula.id != null).map((aula) {
                return DropdownMenuItem(
                  value: aula.id,
                  child: Text(aula.nombre),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedAulaId = value),
              validator: (value) =>
                  value == null ? 'Selecciona un aula.' : null,
            ),
            const SizedBox(height: 24),
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
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Guardando...' : 'Guardar Equipo'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
