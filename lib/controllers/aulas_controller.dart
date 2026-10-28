import 'package:flutter/foundation.dart';
import '../models/aula.dart';
import '../repositories/aula_repository.dart';

class AulasController extends ChangeNotifier {
  final AulaRepository _repository;

  List<Aula> _aulas = [];
  bool _isLoading = false;
  String? _errorMessage;

  AulasController({AulaRepository? repository})
      : _repository = repository ?? AulaRepository();

  List<Aula> get aulas => List.unmodifiable(_aulas);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalAulas => _aulas.length;

  /// Carga todas las aulas desde la base de datos y notifica a la vista.
  Future<void> loadAulas() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _aulas = await _repository.getAll();
    } catch (e) {
      _errorMessage = 'Error al cargar aulas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crea una nueva aula, actualiza la lista local y notifica reactivamente.
  Future<Aula?> createAula(Aula aula) async {
    try {
      final nueva = await _repository.create(aula);
      _aulas = [..._aulas, nueva]..sort((a, b) {
          final compPlanta = a.planta.compareTo(b.planta);
          if (compPlanta != 0) return compPlanta;
          return a.nombre.compareTo(b.nombre);
        });
      notifyListeners();
      return nueva;
    } catch (e) {
      _errorMessage = 'Error al crear aula: $e';
      notifyListeners();
      return null;
    }
  }

  /// Actualiza un aula existente y notifica a los oyentes.
  Future<bool> updateAula(Aula aula) async {
    try {
      await _repository.update(aula);
      final index = _aulas.indexWhere((a) => a.id == aula.id);
      if (index != -1) {
        _aulas[index] = aula;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar aula: $e';
      notifyListeners();
      return false;
    }
  }

  /// Elimina un aula y notifica a los oyentes.
  Future<bool> deleteAula(int id) async {
    try {
      await _repository.delete(id);
      _aulas.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar aula: $e';
      notifyListeners();
      return false;
    }
  }
}
