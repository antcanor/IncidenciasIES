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
}
