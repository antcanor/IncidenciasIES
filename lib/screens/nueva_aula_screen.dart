import 'package:flutter/material.dart';
import '../controllers/controllers.dart';
import '../models/aula.dart';

class NuevaAulaScreen extends StatefulWidget {
  final Aula? aula;
  final AulasController? controller;

  const NuevaAulaScreen({super.key, this.aula, this.controller});

  @override
  State<NuevaAulaScreen> createState() => _NuevaAulaScreenState();
}

class _NuevaAulaScreenState extends State<NuevaAulaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _planta;
  late final AulasController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AulasController();
    _nombre = TextEditingController(text: widget.aula?.nombre);
    _planta = TextEditingController(text: widget.aula?.planta.toString());
  }

  @override
  void dispose() {
    _nombre.dispose();
    _planta.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final aula = Aula(
      id: widget.aula?.id,
      nombre: _nombre.text.trim(),
      planta: int.parse(_planta.text.trim()),
    );
    final success = widget.aula == null
        ? await _controller.createAula(aula) != null
        : await _controller.updateAula(aula);
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage ?? 'No se pudo guardar el aula.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.aula != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Editar Aula' : 'Crear Nueva Aula')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre del Aula', border: OutlineInputBorder()),
              validator: (value) => value == null || value.trim().isEmpty ? 'Introduce un nombre.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _planta,
              decoration: const InputDecoration(labelText: 'Número de Planta', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (value) {
                final planta = int.tryParse(value?.trim() ?? '');
                return planta == null ? 'Introduce una planta válida.' : null;
              },
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
                    child: Text(_saving ? 'Guardando...' : 'Guardar Aula'),
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
