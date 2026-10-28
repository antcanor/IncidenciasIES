// =============================================================================
// CÓDIGO EXPORTADO EN BRUTO DESDE EDITOR VISUAL (FlutterFlow / Visual Builder)
// RA1.b, c: Prototipado rápido y exportación de layout visual sin refactorizar.
// =============================================================================
// NOTA: Este archivo contiene el código monolítico inicial generado automáticamente.
// Obsérvese el uso de colores fijos hexadecimales, estilos hardcodeados, tamaños fijos
// y ausencia de separación de responsabilidades o integración con la arquitectura MVC.
// =============================================================================

import 'package:flutter/material.dart';

class ExportVisualIncidenciaWidget extends StatefulWidget {
  const ExportVisualIncidenciaWidget({super.key});

  @override
  State<ExportVisualIncidenciaWidget> createState() => _ExportVisualIncidenciaWidgetState();
}

class _ExportVisualIncidenciaWidgetState extends State<ExportVisualIncidenciaWidget> {
  // Variables locales del prototipo visual
  String? selectedAula = 'Aula 101 - Informática';
  String? selectedEquipo = 'PC-101-01';
  String selectedPrioridad = 'Alta';
  String selectedEstado = 'Abierta';
  final TextEditingController _descripcionCtrl = TextEditingController(
    text: 'El monitor parpadea y la torre emite 3 pitidos intermitentes al arrancar.',
  );

  @override
  Widget build(BuildContext context) {
    // Código monolítico con widgets anidados profundamente típico de exportadores visuales
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          'Nueva Incidencia (Export Visual)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera visual del prototipo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Paso 1: Localización del Hardware',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Aula / Espacio IES',
                        style: TextStyle(fontSize: 13, color: Color(0xFF616161)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: const SizedBox(),
                          value: selectedAula,
                          items: const [
                            DropdownMenuItem(
                              value: 'Aula 101 - Informática',
                              child: Text('Aula 101 - Informática (Planta 1)'),
                            ),
                            DropdownMenuItem(
                              value: 'Aula 204 - Audiovisuales',
                              child: Text('Aula 204 - Audiovisuales (Planta 2)'),
                            ),
                            DropdownMenuItem(
                              value: 'Taller de Hardware',
                              child: Text('Taller de Hardware (Planta 0)'),
                            ),
                          ],
                          onChanged: (val) => setState(() => selectedAula = val),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Equipo / Dispositivo Afectado',
                        style: TextStyle(fontSize: 13, color: Color(0xFF616161)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: const SizedBox(),
                          value: selectedEquipo,
                          items: const [
                            DropdownMenuItem(
                              value: 'PC-101-01',
                              child: Text('PC-101-01 • PC Sobremesa'),
                            ),
                            DropdownMenuItem(
                              value: 'PC-101-02',
                              child: Text('PC-101-02 • PC Sobremesa'),
                            ),
                            DropdownMenuItem(
                              value: 'PROY-101',
                              child: Text('PROY-101 • Proyector Techo'),
                            ),
                          ],
                          onChanged: (val) => setState(() => selectedEquipo = val),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Paso 2: Detalles de la Avería
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Paso 2: Detalles y Nivel de Prioridad',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Descripción de la Incidencia',
                        style: TextStyle(fontSize: 13, color: Color(0xFF616161)),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _descripcionCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Explica con detalle el problema encontrado...',
                          fillColor: const Color(0xFFF8FAFC),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nivel de Urgencia / Prioridad',
                        style: TextStyle(fontSize: 13, color: Color(0xFF616161)),
                      ),
                      const SizedBox(height: 8),
                      // Chips de prioridad generados por el exportador visual
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ChoiceChip(
                            label: const Text('Baja'),
                            selected: selectedPrioridad == 'Baja',
                            selectedColor: const Color(0xFF43A047),
                            onSelected: (_) => setState(() => selectedPrioridad = 'Baja'),
                          ),
                          ChoiceChip(
                            label: const Text('Media'),
                            selected: selectedPrioridad == 'Media',
                            selectedColor: const Color(0xFFFB8C00),
                            onSelected: (_) => setState(() => selectedPrioridad = 'Media'),
                          ),
                          ChoiceChip(
                            label: const Text('Alta'),
                            selected: selectedPrioridad == 'Alta',
                            selectedColor: const Color(0xFFE53935),
                            onSelected: (_) => setState(() => selectedPrioridad = 'Alta'),
                          ),
                          ChoiceChip(
                            label: const Text('Urgente'),
                            selected: selectedPrioridad == 'Urgente',
                            selectedColor: const Color(0xFF8E24AA),
                            onSelected: (_) => setState(() => selectedPrioridad = 'Urgente'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Paso 3: Tarjeta de previsualización en vivo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF90CAF9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.preview, color: Color(0xFF1565C0)),
                          SizedBox(width: 8),
                          Text(
                            'Vista previa del Ticket generado',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16, color: Color(0xFF90CAF9)),
                      Text('Ubicación: $selectedAula', style: const TextStyle(fontSize: 13)),
                      Text('Equipo: $selectedEquipo', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('Prioridad: $selectedPrioridad', style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('Descripción: ${_descripcionCtrl.text}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botones de acción inferiores
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF64748B)),
                        ),
                        child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Acción no conectada a SQLite en el prototipo
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Prototipo visual: Guardado simulado')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Registrar Incidencia', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
