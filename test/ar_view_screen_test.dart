import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/models/models.dart';
import 'package:incidencias_ies/repositories/incidencia_repository.dart';
import 'package:incidencias_ies/screens/ar_view_screen.dart';

class _FakeIncidenciaRepository extends IncidenciaRepository {
  @override
  Future<List<IncidenciaDetalle>> getIncidenciasPorEquipo(int equipoId) async {
    return [
      IncidenciaDetalle(
        id: 7,
        equipoId: equipoId,
        descripcion: 'Lámpara del proyector parpadea',
        prioridad: Prioridad.media,
        estado: Estado.cerrada,
        fecha: DateTime(2026, 11, 5),
        equipoTipo: 'Proyector Láser',
        equipoCodigo: 'PROY-204-01',
        aulaId: 2,
        aulaNombre: 'Aula 204 - Audiovisuales',
        aulaPlanta: 2,
      ),
    ];
  }
}

void main() {
  testWidgets('muestra la cámara simulada y el historial superpuesto', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ArViewScreen(
          equipoId: 3,
          equipoLabel: 'PROY-204-01',
          repository: _FakeIncidenciaRepository(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Vista AR (maqueta)'), findsOneWidget);
    expect(find.text('VISTA DE CÁMARA · MAQUETA'), findsOneWidget);
    expect(find.text('PROY-204-01'), findsOneWidget);
    expect(find.byKey(const ValueKey('ar_incidencia_7')), findsOneWidget);
    expect(find.text('Lámpara del proyector parpadea'), findsOneWidget);
  });
}
