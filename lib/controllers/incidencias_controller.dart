import 'package:flutter/foundation.dart';
import '../models/estado.dart';
import '../models/incidencia.dart';
import '../models/incidencia_detalle.dart';
import '../models/prioridad.dart';
import '../repositories/incidencia_repository.dart';

class IncidenciasController extends ChangeNotifier {
  final IncidenciaRepository _repository;

  List<IncidenciaDetalle> _incidencias = [];
  Map<Estado, int> _conteoEstado = {};
  Map<Prioridad, int> _conteoPrioridad = {};
  List<Map<String, dynamic>> _conteoPorAula = [];
  int? _filtroAulaId;

  bool _isLoading = false;
  String? _errorMessage;

  IncidenciasController({IncidenciaRepository? repository})
      : _repository = repository ?? IncidenciaRepository();

  List<IncidenciaDetalle> get incidencias => List.unmodifiable(_incidencias);
  Map<Estado, int> get conteoEstado => Map.unmodifiable(_conteoEstado);
  Map<Prioridad, int> get conteoPrioridad => Map.unmodifiable(_conteoPrioridad);
  List<Map<String, dynamic>> get conteoPorAula => List.unmodifiable(_conteoPorAula);
  int? get filtroAulaId => _filtroAulaId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalIncidencias => _incidencias.length;

  /// Carga incidencias (con JOIN doble a equipo y aula) y los recuentos del panel.
  Future<void> loadIncidencias() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _refreshData();
    } catch (e) {
      _errorMessage = 'Error al cargar incidencias: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Aplica filtro por aula y actualiza la lista.
  Future<void> setFiltroAula(int? aulaId) async {
    _filtroAulaId = aulaId;
    _isLoading = true;
    notifyListeners();

    try {
      await _refreshData();
    } catch (e) {
      _errorMessage = 'Error al filtrar incidencias: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crea una nueva incidencia en SQLite y refresca la lista y métricas.
  Future<Incidencia?> createIncidencia(Incidencia incidencia) async {
    try {
      final nueva = await _repository.create(incidencia);
      await _refreshData();
      notifyListeners();
      return nueva;
    } catch (e) {
      _errorMessage = 'Error al crear incidencia: $e';
      notifyListeners();
      return null;
    }
  }

  /// Cierra una incidencia cambiando su estado a [Estado.cerrada] y refresca la vista.
  Future<bool> cerrarIncidencia(int id) async {
    try {
      final existente = await _repository.getById(id);
      if (existente == null) {
        _errorMessage = 'No se encontró la incidencia con ID $id';
        notifyListeners();
        return false;
      }

      final modificada = existente.copyWith(estado: Estado.cerrada);
      await _repository.update(modificada);

      // Actualizar inmediatamente en memoria para reactividad instantánea
      final index = _incidencias.indexWhere((i) => i.id == id);
      if (index != -1) {
        _incidencias[index] = _incidencias[index].copyWith(estado: Estado.cerrada);
      }

      await _refreshData();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al cerrar incidencia: $e';
      notifyListeners();
      return false;
    }
  }

  /// Cambia el estado de una incidencia a cualquier valor del enum [Estado].
  Future<bool> cambiarEstado(int id, Estado nuevoEstado) async {
    try {
      final existente = await _repository.getById(id);
      if (existente == null) return false;

      final modificada = existente.copyWith(estado: nuevoEstado);
      await _repository.update(modificada);

      // Actualizar inmediatamente en memoria
      final index = _incidencias.indexWhere((i) => i.id == id);
      if (index != -1) {
        _incidencias[index] = _incidencias[index].copyWith(estado: nuevoEstado);
      }

      await _refreshData();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al cambiar estado: $e';
      notifyListeners();
      return false;
    }
  }

  /// Obtiene los datos enriquecidos de una incidencia con JOIN doble (equipo y aula).
  Future<IncidenciaDetalle?> getIncidenciaDetalle(int id) async {
    try {
      return await _repository.getIncidenciaConDetalleById(id);
    } catch (e) {
      _errorMessage = 'Error al obtener detalle de la incidencia: $e';
      return null;
    }
  }

  /// Cambia la prioridad de una incidencia, persiste el cambio en SQLite y refresca métricas (RA1.g).
  Future<bool> cambiarPrioridad(int id, Prioridad nuevaPrioridad) async {
    try {
      final existente = await _repository.getById(id);
      if (existente == null) {
        _errorMessage = 'No se encontró la incidencia con ID $id';
        notifyListeners();
        return false;
      }

      final modificada = existente.copyWith(prioridad: nuevaPrioridad);
      await _repository.update(modificada);

      // Actualizar inmediatamente en memoria para respuesta instantánea (RA1.g)
      final index = _incidencias.indexWhere((i) => i.id == id);
      if (index != -1) {
        _incidencias[index] = _incidencias[index].copyWith(prioridad: nuevaPrioridad);
      }

      await _refreshData();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al cambiar prioridad: $e';
      notifyListeners();
      return false;
    }
  }

  /// Elimina una incidencia y actualiza la lista y recuentos del panel.
  Future<bool> deleteIncidencia(int id) async {
    try {
      await _repository.delete(id);
      await _refreshData();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar incidencia: $e';
      notifyListeners();
      return false;
    }
  }

  /// Método interno para sincronizar lista con JOIN doble y agregaciones.
  Future<void> _refreshData() async {
    if (_filtroAulaId != null) {
      _incidencias = await _repository.getIncidenciasPorAula(_filtroAulaId!);
    } else {
      _incidencias = await _repository.getIncidenciasConDetalle();
    }
    _conteoEstado = await _repository.countByEstado();
    _conteoPrioridad = await _repository.countByPrioridad();
    _conteoPorAula = await _repository.countPorAula();
  }
}
