import 'package:gymconnect/app/modules/treinos/models/dia_semana.dart';
import 'package:gymconnect/app/modules/treinos/models/exercicio.dart';
import 'package:gymconnect/app/modules/treinos/models/exercicio_form.dart';
import 'package:gymconnect/app/modules/auth/models/usuario.dart';
import 'package:gymconnect/app/modules/cliente/services/exercicio_service.dart';
import 'package:gymconnect/app/modules/cliente/services/gestao_service.dart';
import 'package:gymconnect/app/modules/cliente/services/usuario_service.dart';
import 'package:gymconnect/app/modules/treinos/repositories/treino_repository.dart';

/// Orquestra as operações do perfil CLIENTE (alunos, exercícios e treinos).
class ClienteRepository {
  final UsuarioService _usuarioService;
  final ExercicioService _exercicioService;
  final GestaoService _gestaoService;
  final TreinoRepository _treinoRepository;

  ClienteRepository(
    this._usuarioService,
    this._exercicioService,
    this._gestaoService,
    this._treinoRepository,
  );

  // ----- Alunos -----
  Future<List<Usuario>> listarAlunos() => _usuarioService.listarAlunos();
  Future<void> removerAluno(int id) => _usuarioService.remover(id);

  // ----- Treinos de um aluno (visualização) -----
  Future<List<TreinoDia>> treinosDoAluno(int idAluno) =>
      _treinoRepository.carregarTreinos(idAluno);

  /// Edita um vínculo de treino (PUT /cronogramaexercicio/{id}).
  Future<void> atualizarVinculo({
    required int idCronogramaExercicio,
    required int idCronograma,
    required int idExercicio,
    DiaSemana? diaSemana,
    int? serie,
    int? repeticao,
    int? carga,
  }) =>
      _gestaoService.atualizarVinculo(
        idCronogramaExercicio: idCronogramaExercicio,
        idCronograma: idCronograma,
        idExercicio: idExercicio,
        diaSemana: diaSemana,
        serie: serie,
        repeticao: repeticao,
        carga: carga,
      );

  /// Remove um vínculo de treino (DELETE /cronogramaexercicio/{id}).
  Future<void> removerVinculo(int idCronogramaExercicio) =>
      _gestaoService.removerVinculo(idCronogramaExercicio);

  // ----- Exercícios (biblioteca) -----
  Future<List<Exercicio>> listarExercicios() => _exercicioService.listar();

  Future<Exercicio> cadastrarExercicio(String nome, String? link) {
    final linkFinal = (link == null || link.trim().isEmpty)
        ? 'https://youtube.com'
        : link.trim();
    return _exercicioService.cadastrar(nome: nome.trim(), linkYoutube: linkFinal);
  }

  Future<void> removerExercicio(int id) => _exercicioService.remover(id);

  // ----- Criar treino para um aluno -----
  ///
  /// Fluxo (igual ao React): garante os exercícios na biblioteca → cria o
  /// cronograma do aluno → vincula cada exercício com dia/série/rep/carga.
  Future<void> criarTreino({
    required int idAluno,
    required DiaSemana diaSemana,
    required List<ExercicioForm> exercicios,
  }) async {
    final biblioteca = await _exercicioService.listar();

    // 1) Resolve/garante o id de cada exercício na biblioteca.
    final idsExercicio = <int>[];
    for (final ex in exercicios) {
      final existente = biblioteca.where(
        (e) => e.nome.toLowerCase() == ex.nome.trim().toLowerCase(),
      );
      if (existente.isNotEmpty && existente.first.idExercicio != null) {
        idsExercicio.add(existente.first.idExercicio!);
      } else {
        final novo = await cadastrarExercicio(ex.nome, ex.video);
        idsExercicio.add(novo.idExercicio!);
        biblioteca.add(novo);
      }
    }

    // 2) Cria o cronograma do aluno.
    final cronograma = await _gestaoService.criarCronograma(idAluno: idAluno);

    // 3) Vincula cada exercício ao cronograma.
    for (var i = 0; i < exercicios.length; i++) {
      final ex = exercicios[i];
      await _gestaoService.vincularExercicio(
        idCronograma: cronograma.idCronograma,
        idExercicio: idsExercicio[i],
        diaSemana: diaSemana,
        serie: ex.serieInt,
        repeticao: ex.repeticaoInt,
        carga: ex.cargaInt,
      );
    }
  }
}
