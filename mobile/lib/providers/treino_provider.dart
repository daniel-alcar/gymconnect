import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../repositories/treino_repository.dart';

/// Estado da tela de Treinos.
class TreinoProvider extends ChangeNotifier {
  final TreinoRepository _repository;
  TreinoProvider(this._repository);

  bool _carregando = false;
  String? _erro;
  List<TreinoDia> _dias = [];

  /// IDs de cronogramas marcados como feitos nesta sessão (feedback visual).
  final Set<int> _exerciciosFeitos = {};

  bool get carregando => _carregando;
  String? get erro => _erro;
  List<TreinoDia> get dias => _dias;
  bool get vazio => !_carregando && _erro == null && _dias.isEmpty;

  bool exercicioFeito(int? idCronogramaExercicio) =>
      idCronogramaExercicio != null &&
      _exerciciosFeitos.contains(idCronogramaExercicio);

  Future<void> carregar(int idAluno) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      _dias = await _repository.carregarTreinos(idAluno);
    } on AppException catch (e) {
      _erro = e.message;
    } catch (e) {
      _erro = e.toString();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Marca exercício como feito. Lança [AppException] em falha (UI mostra erro).
  Future<void> marcarComoFeito({
    required int idCronogramaExercicio,
    required int idCronograma,
    double? peso,
  }) async {
    await _repository.marcarComoFeito(idCronograma: idCronograma, peso: peso);
    _exerciciosFeitos.add(idCronogramaExercicio);
    notifyListeners();
  }

  void limpar() {
    _dias = [];
    _erro = null;
    _exerciciosFeitos.clear();
  }
}
