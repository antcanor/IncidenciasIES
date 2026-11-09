import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/models/models.dart';
import 'package:incidencias_ies/settings/app_strings.dart';

void main() {
  test(
    'modelos cubren copias, mapas alternativos, igualdad y representación',
    () {
      const aula = Aula(id: 1, nombre: 'Aula', planta: 1);
      expect(aula.toMap(includeId: false), {'nombre': 'Aula', 'planta': 1});
      expect(
        aula.copyWith(id: 2, nombre: 'Nueva', planta: 2),
        isNot(equals(aula)),
      );
      expect(aula.toString(), contains('Aula(id: 1'));
      expect(aula.hashCode, isNotNull);
      expect(aula == const Aula(id: 9, nombre: 'Aula', planta: 1), isFalse);

      const equipo = Equipo(id: 2, aulaId: 1, tipo: 'PC', codigo: 'PC-1');
      expect(
        Equipo.fromMap({'id': 2, 'aulaId': 1, 'tipo': 'PC', 'codigo': 'PC-1'}),
        equipo,
      );
      expect(equipo.toMap(includeId: false), {
        'aula_id': 1,
        'tipo': 'PC',
        'codigo': 'PC-1',
      });
      expect(equipo.copyWith(aulaId: 3).aulaId, 3);
      expect(equipo.toString(), contains('Equipo(id: 2'));
      expect(equipo.hashCode, isNotNull);
      expect(
        equipo == const Equipo(id: 2, aulaId: 1, tipo: 'PC', codigo: 'PC-2'),
        isFalse,
      );

      final fecha = DateTime.utc(2026, 11, 9);
      final comentario = Comentario(
        id: 3,
        incidenciaId: 4,
        fecha: fecha,
        texto: 'Nota',
      );
      expect(
        Comentario.fromMap({
          'id': 3,
          'incidenciaId': 4,
          'fecha': fecha,
          'texto': 'Nota',
        }),
        comentario,
      );
      expect(
        comentario.copyWith(fecha: fecha.add(const Duration(hours: 1))).fecha,
        isNot(equals(fecha)),
      );
      expect(comentario.toString(), contains('Comentario(id: 3'));
      expect(comentario.hashCode, isNotNull);
      expect(comentario == comentario.copyWith(texto: 'Otra nota'), isFalse);

      final incidencia = Incidencia(
        id: 5,
        equipoId: 6,
        descripcion: 'Descripción',
        prioridad: Prioridad.alta,
        estado: Estado.enProceso,
        fecha: fecha,
      );
      expect(
        Incidencia.fromMap({
          'id': 5,
          'equipoId': 6,
          'descripcion': 'Descripción',
          'prioridad': Prioridad.alta,
          'estado': Estado.enProceso,
          'fecha': fecha,
        }),
        incidencia,
      );
      expect(
        incidencia.copyWith(
          id: 8,
          equipoId: 9,
          descripcion: 'Otra',
          prioridad: Prioridad.urgente,
          estado: Estado.cerrada,
          fecha: fecha.add(const Duration(days: 1)),
        ),
        isNot(equals(incidencia)),
      );
      expect(incidencia.toString(), contains('Incidencia(id: 5'));
      expect(incidencia.hashCode, isNotNull);
      expect(
        incidencia == incidencia.copyWith(descripcion: 'Otra descripción'),
        isFalse,
      );
    },
  );

  test('los enums usan sus valores por defecto ante entradas desconocidas', () {
    expect(Prioridad.fromString('desconocida'), Prioridad.media);
    expect(Estado.fromString('desconocido'), Estado.abierta);
    expect(Estado.fromString('en proceso'), Estado.enProceso);
  });

  test('IncidenciaDetalle admite mapas de API y conserva todos sus campos', () {
    final fecha = DateTime.utc(2026, 11, 9);
    final detalle = IncidenciaDetalle.fromMap({
      'id': 1,
      'equipoId': 2,
      'descripcion': 'Detalle',
      'prioridad': Prioridad.urgente,
      'estado': Estado.resuelta,
      'fecha': fecha,
      'equipoTipo': 'Proyector',
      'equipoCodigo': 'PROY-01',
      'aulaId': 3,
      'aulaNombre': 'Aula 204',
      'aulaPlanta': 2,
    });

    expect(detalle.toMap(), {
      'id': 1,
      'equipo_id': 2,
      'descripcion': 'Detalle',
      'prioridad': 'URGENTE',
      'estado': 'RESUELTA',
      'fecha': fecha.toIso8601String(),
      'equipo_tipo': 'Proyector',
      'equipo_codigo': 'PROY-01',
      'aula_id': 3,
      'aula_nombre': 'Aula 204',
      'aula_planta': 2,
    });
    expect(IncidenciaDetalle.fromMap(detalle.toMap()), detalle);
    expect(
      detalle.copyWith(
        id: 4,
        equipoId: 5,
        descripcion: 'Otro',
        prioridad: Prioridad.baja,
        estado: Estado.cerrada,
        fecha: fecha.add(const Duration(days: 1)),
        equipoTipo: 'PC',
        equipoCodigo: 'PC-02',
        aulaId: 6,
        aulaNombre: 'Taller',
        aulaPlanta: 0,
      ),
      isNot(equals(detalle)),
    );
    expect(detalle.toString(), contains('IncidenciaDetalle(id: 1'));
    expect(detalle.hashCode, isNotNull);
    expect(detalle == detalle.copyWith(equipoCodigo: 'OTRO'), isFalse);
    expect(detalle == detalle.copyWith(id: 99), isFalse);
  });

  testWidgets('AppStrings ofrece fallback en español para todas las claves', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            for (final key in const [
              'settings',
              'permissions',
              'camera',
              'microphone',
              'request',
              'granted',
              'denied',
              'language',
              'theme',
              'light',
              'dark',
              'spanish',
              'english',
              'permissionOnlyOnUse',
              'permissionUpdated',
              'permissionError',
            ]) {
              expect(AppStrings.text(context, key), isNotEmpty);
            }
            expect(AppStrings.text(context, 'unknown'), 'unknown');
            return const SizedBox();
          },
        ),
      ),
    );
  });
}
