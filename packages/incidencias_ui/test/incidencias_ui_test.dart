import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ui/incidencias_ui.dart';

void main() {
  testWidgets('expone la etiqueta de maqueta AR', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MaquetaArBadge())),
    );
    expect(find.text('UI compartida · maqueta AR'), findsOneWidget);
  });

  testWidgets('permite cambiar la prioridad con un callback tipado', (
    tester,
  ) async {
    Priority? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PriorityBadge(
            priority: Priority.medium,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(find.text('MEDIA'), findsOneWidget);
    await tester.tap(find.byType(PriorityBadge));
    await tester.pumpAndSettle();
    await tester.tap(find.text('URGENTE').last);

    expect(selected, Priority.urgent);
  });

  testWidgets(
    'representa las opciones compacta, personalizada y deshabilitada',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PriorityBadge(
              priority: Priority.low,
              compact: false,
              enabled: false,
              semanticLabel: 'Prioridad baja',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('BAJA'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(PriorityBadge)),
        matchesSemantics(
          label: 'Prioridad baja',
          isButton: false,
          hasExpandedState: true,
        ),
      );
      await tester.tap(find.byType(PriorityBadge));
      expect(find.text('URGENTE'), findsNothing);
    },
  );

  testWidgets('emite eventos tipados de cierre y comentario', (tester) async {
    IncidentCardData? closed;
    IncidentCardData? commented;
    const incident = IncidentCardData(
      id: 8,
      title: 'Proyector sin imagen',
      details: 'Aula 204 · PROY-204-01',
      priority: Priority.high,
      status: 'ABIERTA',
      priorityColor: Colors.deepOrange,
      statusColor: Colors.red,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IncidentCard(
            incident: incident,
            onClose: (value) => closed = value,
            onComment: (value) => commented = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('btn_comentar_8')));
    await tester.tap(find.byKey(const Key('btn_cerrar_8')));

    expect(commented, same(incident));
    expect(closed, same(incident));
  });
}
