import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ui/incidencias_ui.dart';

void main() {
  testWidgets('IncidentCard mantiene su apariencia visual', (tester) async {
    const incident = IncidentCardData(
      id: 42,
      title: 'Proyector sin imagen',
      details: 'Aula 204 · PROY-204-01',
      priority: Priority.high,
      status: 'ABIERTA',
      priorityColor: Colors.deepOrange,
      statusColor: Colors.red,
    );

    await tester.binding.setSurfaceSize(const Size(420, 190));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8),
            child: IncidentCard(
              incident: incident,
              onClose: _noop,
              onComment: _noop,
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(IncidentCard),
      matchesGoldenFile('goldens/incident_card.png'),
    );
  });
}

void _noop(IncidentCardData _) {}
