import 'package:flutter/foundation.dart';
import '../models/equipo.dart';
import '../repositories/equipo_repository.dart';

class EquiposController extends ChangeNotifier {
  final EquipoRepository _repository;

  List<Equipo> _equipos = [];
  int? _filtroAulaId;
  bool _isLoading = false;
  String? _errorMessage;

  EquiposController({EquipoRepository? repository})
      : _repository = repository ?? EquipoRepository();

  List<Equipo> get equipos => List.unmodifiable(_equipos);
  int? get filtroAulaId => _filtroAulaId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalEquipos => _equipos.length;

  /// Carga todos los equipos o los filtra por aula si se proporciona filtro.
  Future<void> loadEquipos([int? aulaId]) async {
    _isLoading = true;
    _errorMessage = null;
    if (aulaId != null) {
      _filtroAulaId = aulaId;
    }
    notifyListeners();

    try {
      if (_filtroAulaId != null) {
        _equipos = await _repository.getByAula(_filtroAulaId!);
      } else {
        _equipos = await _repository.getAll();
      }
    } catch (e) {
      _errorMessage = 'Error al cargar equipos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cambia el aula de filtro y recarga los equipos.
  Future<void> setFiltroAula(int? aulaId) async {
    _filtroAulaId = aulaId;
    await loadEquipos();
  }

  /// Crea un nuevo equipo y notifica a las vistas reactivas.
  Future<Equipo?> createEquipo(Equipo equipo) async {
    try {
      final nuevo = await _repository.create(equipo);
      _equipos = [..._equipos, nuevo]..sort((a, b) => a.codigo.compareTo(b.codigo));
      notifyListeners();
      return nuevo;
    } catch (e) {
      _errorMessage = 'Error al crear equipo: $e';
      notifyListeners();
      return null;
    }
  }

  /// Actualiza un equipo existente y notifica.
  Future<bool> updateEquipo(Equipo equipo) async {
    try {
      await _repository.update(equipo);
      final index = _equipos.indexWhere((e) => e.id == equipo.id);
      if (index != -1) {
        _equipos[index] = equipo;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar equipo: $e';
      notifyListeners();
      return false;
    }
  }

  /// Elimina un equipo y notifica a los oyentes.
  Future<bool> deleteEquipo(int id) async {
    try {
      await _repository.delete(id);
      _equipos.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar equipo: $e';
      notifyListeners();
      return false;
    }
  }
}
