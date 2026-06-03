import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../models/dia_semana.dart';
import '../models/exercicio.dart';
import '../models/exercicio_form.dart';
import '../models/usuario.dart';
import '../repositories/cliente_repository.dart';
import '../repositories/treino_repository.dart';

/// Estado do perfil CLIENTE: biblioteca de exercícios, alunos e criação de treinos.
class ClienteProvider extends ChangeNotifier {
  final ClienteRepository _repository;
  ClienteProvider(this._repository);

  // Exercícios
  bool _carregandoExercicios = false;
  String? _erroExercicios;
  List<Exercicio> _exercicios = [];

  bool get carregandoExercicios => _carregandoExercicios;
  String? get erroExercicios => _erroExercicios;
  List<Exercicio> get exercicios => _exercicios;

  // Alunos
  bool _carregandoAlunos = false;
  String? _erroAlunos;
  List<Usuario> _alunos = [];

  bool get carregandoAlunos => _carregandoAlunos;
  String? get erroAlunos => _erroAlunos;
  List<Usuario> get alunos => _alunos;

  bool _salvando = false;
  bool get salvando => _salvando;

  // Visualização de treinos de um aluno
  bool _carregandoTreinosAluno = false;
  String? _erroTreinosAluno;
  List<TreinoDia> _treinosAluno = [];
  int? _alunoSelecionado;

  bool get carregandoTreinosAluno => _carregandoTreinosAluno;
  String? get erroTreinosAluno => _erroTreinosAluno;
  List<TreinoDia> get treinosAluno => _treinosAluno;
  int? get alunoSelecionado => _alunoSelecionado;

  /// Edita um vínculo de treino e recarrega os treinos do aluno selecionado.
  Future<void> atualizarVinculo({
    required int idCronogramaExercicio,
    required int idCronograma,
    required int idExercicio,
    DiaSemana? diaSemana,
    int? serie,
    int? repeticao,
    int? carga,
  }) async {
    await _repository.atualizarVinculo(
      idCronogramaExercicio: idCronogramaExercicio,
      idCronograma: idCronograma,
      idExercicio: idExercicio,
      diaSemana: diaSemana,
      serie: serie,
      repeticao: repeticao,
      carga: carga,
    );
    if (_alunoSelecionado != null) {
      await carregarTreinosDoAluno(_alunoSelecionado!);
    }
  }

  /// Remove um vínculo de treino e recarrega os treinos do aluno selecionado.
  Future<void> removerVinculo(int idCronogramaExercicio) async {
    await _repository.removerVinculo(idCronogramaExercicio);
    if (_alunoSelecionado != null) {
      await carregarTreinosDoAluno(_alunoSelecionado!);
    }
  }

  Future<void> carregarTreinosDoAluno(int idAluno) async {
    _alunoSelecionado = idAluno;
    _carregandoTreinosAluno = true;
    _erroTreinosAluno = null;
    _treinosAluno = [];
    notifyListeners();
    try {
      _treinosAluno = await _repository.treinosDoAluno(idAluno);
    } on AppException catch (e) {
      _erroTreinosAluno = e.message;
    } catch (e) {
      _erroTreinosAluno = e.toString();
    } finally {
      _carregandoTreinosAluno = false;
      notifyListeners();
    }
  }

  // ---------- Exercícios ----------
  Future<void> carregarExercicios() async {
    _carregandoExercicios = true;
    _erroExercicios = null;
    notifyListeners();
    try {
      _exercicios = await _repository.listarExercicios();
    } on AppException catch (e) {
      _erroExercicios = e.message;
    } catch (e) {
      _erroExercicios = e.toString();
    } finally {
      _carregandoExercicios = false;
      notifyListeners();
    }
  }

  /// Lança [AppException] em falha (a UI mostra o erro).
  Future<void> cadastrarExercicio(String nome, String? link) async {
    _salvando = true;
    notifyListeners();
    try {
      final novo = await _repository.cadastrarExercicio(nome, link);
      _exercicios = [..._exercicios, novo];
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  Future<void> removerExercicio(int id) async {
    await _repository.removerExercicio(id);
    _exercicios = _exercicios.where((e) => e.idExercicio != id).toList();
    notifyListeners();
  }

  // ---------- Alunos ----------
  Future<void> carregarAlunos() async {
    _carregandoAlunos = true;
    _erroAlunos = null;
    notifyListeners();
    try {
      _alunos = await _repository.listarAlunos();
    } on AppException catch (e) {
      _erroAlunos = e.message;
    } catch (e) {
      _erroAlunos = e.toString();
    } finally {
      _carregandoAlunos = false;
      notifyListeners();
    }
  }

  Future<void> removerAluno(int id) async {
    await _repository.removerAluno(id);
    _alunos = _alunos.where((a) => a.idUsuario != id).toList();
    notifyListeners();
  }

  // ---------- Criar treino ----------
  Future<void> criarTreino({
    required int idAluno,
    required DiaSemana diaSemana,
    required List<ExercicioForm> exercicios,
  }) async {
    _salvando = true;
    notifyListeners();
    try {
      await _repository.criarTreino(
        idAluno: idAluno,
        diaSemana: diaSemana,
        exercicios: exercicios,
      );
      // Recarrega a biblioteca (pode ter ganho exercícios novos).
      _exercicios = await _repository.listarExercicios();
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }
}
