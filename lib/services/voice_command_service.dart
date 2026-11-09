import '../models/estado.dart';
import '../models/aula.dart';
import '../models/equipo.dart';
import '../repositories/aula_repository.dart';
import '../repositories/equipo_repository.dart';
import '../repositories/incidencia_repository.dart';

class VoiceCommandResult {
  final bool handled;
  final bool successful;
  final String message;

  const VoiceCommandResult({
    required this.handled,
    required this.successful,
    required this.message,
  });
}

class VoiceCommandService {
  final IncidenciaRepository _incidenciaRepository;
  final AulaRepository _aulaRepository;
  final EquipoRepository _equipoRepository;

  VoiceCommandService({
    IncidenciaRepository? incidenciaRepository,
    AulaRepository? aulaRepository,
    EquipoRepository? equipoRepository,
  })  : _incidenciaRepository =
            incidenciaRepository ?? IncidenciaRepository(),
        _aulaRepository = aulaRepository ?? AulaRepository(),
        _equipoRepository = equipoRepository ?? EquipoRepository();

  Future<VoiceCommandResult> execute(String command) async {
    final normalized = _normalize(command);
    if (_isOpenCountCommand(normalized)) {
      final count = await _incidenciaRepository.countByStates(
        [Estado.abierta, Estado.enProceso],
      );
      return VoiceCommandResult(
        handled: true,
        successful: true,
        message: 'Hay $count incidencias abiertas.',
      );
    }

    final closeMatch = RegExp(
      r'^(?:por favor )?(?:cierra|cerrar|cierre|marca como cerrada|marcar como cerrada)'
      r'(?: la incidencia)? del? (.+?) del? aula ([\w\s-]+)$',
    ).firstMatch(normalized);
    if (closeMatch == null) {
      return const VoiceCommandResult(
        handled: false,
        successful: false,
        message: 'No he entendido la orden.',
      );
    }

    final equipmentText = closeMatch.group(1)!.trim();
    final aulaText = closeMatch.group(2)!.trim();
    final aulas = await _aulaRepository.getAll();
    Aula? aula;
    for (final candidate in aulas) {
      if (_matches(candidate.nombre, aulaText)) {
        aula = candidate;
        break;
      }
    }
    if (aula == null || aula.id == null) {
      return VoiceCommandResult(
        handled: true,
        successful: false,
        message: 'No he encontrado el aula $aulaText.',
      );
    }

    final equipos = await _equipoRepository.getByAula(aula.id!);
    Equipo? equipo;
    for (final candidate in equipos) {
      if (_matches(candidate.tipo, equipmentText) ||
          _matches(candidate.codigo, equipmentText)) {
        equipo = candidate;
        break;
      }
    }
    if (equipo == null || equipo.id == null) {
      return VoiceCommandResult(
        handled: true,
        successful: false,
        message:
            'No he encontrado el equipo $equipmentText en el aula $aulaText.',
      );
    }

    final incidencias = await _incidenciaRepository.getByEquipo(equipo.id!);
    final abiertas = incidencias
        .where(
          (incidencia) =>
              incidencia.estado == Estado.abierta ||
              incidencia.estado == Estado.enProceso,
        )
        .toList();
    if (abiertas.isEmpty) {
      return VoiceCommandResult(
        handled: true,
        successful: false,
        message:
            'No hay incidencias abiertas para $equipmentText en el aula $aulaText.',
      );
    }

    await _incidenciaRepository.update(
      abiertas.first.copyWith(estado: Estado.cerrada),
    );
    return VoiceCommandResult(
      handled: true,
      successful: true,
      message:
          'He cerrado la incidencia del $equipmentText del aula $aulaText.',
    );
  }

  bool _isOpenCountCommand(String command) {
    return command.contains('cuantas incidencias abiertas hay') ||
        command.contains('cuantas incidencias hay abiertas') ||
        command.contains('numero de incidencias abiertas');
  }

  bool _matches(String value, String query) {
    final normalizedValue = _normalize(value);
    final normalizedQuery = _normalize(query);
    return normalizedValue == normalizedQuery ||
        normalizedValue.contains(normalizedQuery) ||
        normalizedQuery.contains(normalizedValue);
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
