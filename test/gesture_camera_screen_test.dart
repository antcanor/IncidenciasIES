import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/screens/gesture_camera_screen.dart';

void main() {
  testWidgets('muestra el respaldo táctil fuera de Android e iOS', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: GestureCameraScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Pose corporal'), findsOneWidget);
    expect(find.byKey(const Key('btn_foto_respaldo')), findsOneWidget);
    expect(find.byKey(const Key('gesture_camera_status')), findsOneWidget);
  });
}
