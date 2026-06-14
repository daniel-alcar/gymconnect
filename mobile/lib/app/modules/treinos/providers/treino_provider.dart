import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:gymconnect/app/core/errors/app_exception.dart';
import 'package:gymconnect/app/modules/treinos/repositories/treino_repository.dart';
import 'package:gymconnect/app/core/storage/storage_service.dart';

/// Estado da tela de Treinos.
class TreinoProvider extends ChangeNotifier {
  final TreinoRepository _repository;
  final StorageService _storage;
  TreinoProvider(this._repository, this._storage);

  bool _carregando = false;
  String? _erro;
  List<TreinoDia> _dias = [];
  int? _idUsuario;

  /// IDs de cronogramaexercicio marcados como feitos (persistidos por usuário).
  final Set<int> _exerciciosFeitos = {};

  /// Títulos de dias de treino concluídos (persistidos por usuário).
  final Set<String> _diasConcluidos = {};

  bool get carregando => _carregando;
  String? get erro => _erro;
  List<TreinoDia> get dias => _dias;
  bool get vazio => !_carregando && _erro == null && _dias.isEmpty;

  bool exercicioFeito(int? idCronogramaExercicio) =>
      idCronogramaExercicio != null &&
      _exerciciosFeitos.contains(idCronogramaExercicio);

  bool diaConcluido(String titulo) => _diasConcluidos.contains(titulo);

  Future<void> carregar(int idAluno) async {
    _idUsuario = idAluno;
    _carregando = true;
    _erro = null;
    notifyListeners();
    // Restaura o estado de conclusão salvo localmente (sobrevive ao restart).
    await _carregarConclusoes(idAluno);
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

  /// Marca exercício como feito (chama o backend). Lança [AppException] em falha.
  Future<void> marcarComoFeito({
    required int idCronogramaExercicio,
    required int idCronograma,
  }) async {
    await _repository.marcarComoFeito(idCronograma: idCronograma);
    _exerciciosFeitos.add(idCronogramaExercicio);
    await _persistirExercicios();
    notifyListeners();
  }

  /// Desmarca um exercício concluído (apenas estado local).
  Future<void> desmarcarExercicio(int idCronogramaExercicio) async {
    _exerciciosFeitos.remove(idCronogramaExercicio);
    await _persistirExercicios();
    notifyListeners();
  }

  /// Marca um dia de treino como concluído (estado local persistido).
  Future<void> concluirDia(String titulo) async {
    _diasConcluidos.add(titulo);
    await _persistirDias();
    notifyListeners();
  }

  /// Desmarca um dia de treino concluído.
  Future<void> desmarcarDia(String titulo) async {
    _diasConcluidos.remove(titulo);
    await _persistirDias();
    notifyListeners();
  }

  Future<void> _carregarConclusoes(int idUsuario) async {
    _exerciciosFeitos.clear();
    _diasConcluidos.clear();
    try {
      final exRaw = await _storage.lerExerciciosFeitos(idUsuario);
      if (exRaw != null && exRaw.isNotEmpty) {
        _exerciciosFeitos.addAll(
          (jsonDecode(exRaw) as List).map((e) => (e as num).toInt()),
        );
      }
      final diasRaw = await _storage.lerDiasConcluidos(idUsuario);
      if (diasRaw != null && diasRaw.isNotEmpty) {
        _diasConcluidos.addAll(
          (jsonDecode(diasRaw) as List).map((e) => e.toString()),
        );
      }
    } catch (_) {/* estado de conclusão é best-effort */}
  }

  Future<void> _persistirExercicios() async {
    final id = _idUsuario;
    if (id == null) return;
    try {
      await _storage.salvarExerciciosFeitos(
          id, jsonEncode(_exerciciosFeitos.toList()));
    } catch (_) {/* best-effort */}
  }

  Future<void> _persistirDias() async {
    final id = _idUsuario;
    if (id == null) return;
    try {
      await _storage.salvarDiasConcluidos(
          id, jsonEncode(_diasConcluidos.toList()));
    } catch (_) {/* best-effort */}
  }

  void limpar() {
    _dias = [];
    _erro = null;
    _idUsuario = null;
    _exerciciosFeitos.clear();
    _diasConcluidos.clear();
  }
}
