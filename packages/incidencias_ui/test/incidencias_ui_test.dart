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
}
