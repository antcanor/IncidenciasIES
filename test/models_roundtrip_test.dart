import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/models/models.dart';

void main() {
  group('Pruebas unitarias de ida y vuelta (Objeto -> Mapa -> Objeto)', () {
    test('Aula: ida y vuelta completa (objeto -> toMap -> fromMap)', () {
      const original = Aula(
        id: 1,
        nombre: 'Aula 101 - Informática',
        planta: 1,
      );

      final map = original.toMap();
      final reconstruido = Aula.fromMap(map);

      expect(map['id'], equals(1));
      expect(map['nombre'], equals('Aula 101 - Informática'));
      expect(map['planta'], equals(1));

      expect(reconstruido, equals(original));
      expect(reconstruido.id, equals(original.id));
      expect(reconstruido.nombre, equals(original.nombre));
      expect(reconstruido.planta, equals(original.planta));
    });

    test('Equipo: ida y vuelta completa (objeto -> toMap -> fromMap)', () {
      const original = Equipo(
        id: 10,
        aulaId: 1,
        tipo: 'PC Sobremesa',
        codigo: 'PC-A101-05',
      );

      final map = original.toMap();
      final reconstruido = Equipo.fromMap(map);

      expect(map['id'], equals(10));
      expect(map['aula_id'], equals(1));
      expect(map['tipo'], equals('PC Sobremesa'));
      expect(map['codigo'], equals('PC-A101-05'));

      expect(reconstruido, equals(original));
      expect(reconstruido.id, equals(original.id));
      expect(reconstruido.aulaId, equals(original.aulaId));
      expect(reconstruido.tipo, equals(original.tipo));
      expect(reconstruido.codigo, equals(original.codigo));
    });

    test('Incidencia: ida y vuelta completa con enums Prioridad y Estado (objeto -> toMap -> fromMap)', () {
      final fecha = DateTime.parse('2026-10-27T16:40:00.000Z');
      final original = Incidencia(
        id: 100,
        equipoId: 10,
        descripcion: 'La pantalla no enciende tras pulsar botón de encendido',
        prioridad: Prioridad.urgente,
        estado: Estado.enProceso,
        fecha: fecha,
      );

      final map = original.toMap();
      final reconstruido = Incidencia.fromMap(map);

      expect(map['id'], equals(100));
      expect(map['equipo_id'], equals(10));
      expect(map['descripcion'], equals('La pantalla no enciende tras pulsar botón de encendido'));
      expect(map['prioridad'], equals('URGENTE'));
      expect(map['estado'], equals('EN_PROCESO'));
      expect(map['fecha'], equals(fecha.toIso8601String()));

      expect(reconstruido, equals(original));
      expect(reconstruido.id, equals(original.id));
      expect(reconstruido.equipoId, equals(original.equipoId));
      expect(reconstruido.descripcion, equals(original.descripcion));
      expect(reconstruido.prioridad, equals(Prioridad.urgente));
      expect(reconstruido.estado, equals(Estado.enProceso));
      expect(reconstruido.fecha.isAtSameMomentAs(fecha), isTrue);
    });

    test('Comentario: ida y vuelta completa (objeto -> toMap -> fromMap)', () {
      final fecha = DateTime.parse('2026-10-27T16:45:00.000Z');
      final original = Comentario(
        id: 500,
        incidenciaId: 100,
        fecha: fecha,
        texto: 'Se revisó la fuente de alimentación; pendiente de sustitución de cable HDMI.',
      );

      final map = original.toMap();
      final reconstruido = Comentario.fromMap(map);

      expect(map['id'], equals(500));
      expect(map['incidencia_id'], equals(100));
      expect(map['fecha'], equals(fecha.toIso8601String()));
      expect(map['texto'], equals('Se revisó la fuente de alimentación; pendiente de sustitución de cable HDMI.'));

      expect(reconstruido, equals(original));
      expect(reconstruido.id, equals(original.id));
      expect(reconstruido.incidenciaId, equals(original.incidenciaId));
      expect(reconstruido.fecha.isAtSameMomentAs(fecha), isTrue);
      expect(reconstruido.texto, equals(original.texto));
    });

    test('Manejo de ID nulo al insertar antes de autoincrement', () {
      const aulaNueva = Aula(nombre: 'Taller Robótica', planta: 0);
      final mapAula = aulaNueva.toMap(includeId: false);
      expect(mapAula.containsKey('id'), isFalse);
      expect(mapAula['nombre'], equals('Taller Robótica'));

      const equipoNuevo = Equipo(aulaId: 2, tipo: 'Impresora 3D', codigo: 'IMP3D-01');
      final mapEquipo = equipoNuevo.toMap(includeId: false);
      expect(mapEquipo.containsKey('id'), isFalse);
      expect(mapEquipo['codigo'], equals('IMP3D-01'));
    });
  });
}
