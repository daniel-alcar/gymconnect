import 'package:flutter_test/flutter_test.dart';

import 'package:gymconnect/app/core/errors/app_exception.dart';
import 'package:gymconnect/app/modules/auth/models/tipo_usuario.dart';
import 'package:gymconnect/app/modules/auth/models/usuario.dart';
import 'package:gymconnect/app/modules/cliente/providers/cliente_provider.dart';
import 'package:gymconnect/app/modules/cliente/repositories/cliente_repository.dart';
import 'package:gymconnect/app/modules/treinos/models/dia_semana.dart';
import 'package:gymconnect/app/modules/treinos/models/exercicio.dart';
import 'package:gymconnect/app/modules/treinos/models/exercicio_form.dart';
import 'package:gymconnect/app/modules/treinos/repositories/treino_repository.dart';

// ---- Fakes ----

class _FakeClienteRepository implements ClienteRepository {
  List<Usuario> alunos = [];
  List<Exercicio> exercicios = [];
  bool fails = false;
  String erroMsg = 'Erro de rede';

  // Exercício retornado por cadastrar/atualizar
  Exercicio exercicioRetornado = const Exercicio(nome: 'Cadastrado');

  @override
  Future<List<Usuario>> listarAlunos() async {
    if (fails) throw AppException(erroMsg);
    return List.of(alunos);
  }

  @override
  Future<void> removerAluno(int id) async {
    alunos.removeWhere((a) => a.idUsuario == id);
  }

  @override
  Future<List<TreinoDia>> treinosDoAluno(int idAluno) async => [];

  @override
  Future<void> atualizarVinculo({
    required int idCronogramaExercicio,
    required int idCronograma,
    required int idExercicio,
    DiaSemana? diaSemana,
    int? serie,
    int? repeticao,
    int? carga,
  }) async {}

  @override
  Future<void> removerVinculo(int idCronogramaExercicio) async {}

  @override
  Future<List<Exercicio>> listarExercicios() async {
    if (fails) throw AppException(erroMsg);
    return List.of(exercicios);
  }

  @override
  Future<Exercicio> cadastrarExercicio(String nome, String? link,
      [String? descricao]) async {
    if (fails) throw AppException(erroMsg);
    return exercicioRetornado;
  }

  @override
  Future<Exercicio> atualizarExercicio(
      int idExercicio, String nome, String? link, String? descricao) async {
    return Exercicio(
      idExercicio: idExercicio,
      nome: nome,
      linkYoutube: link,
      descricao: descricao,
    );
  }

  @override
  Future<void> removerExercicio(int id) async {
    exercicios.removeWhere((e) => e.idExercicio == id);
  }

  @override
  Future<void> criarTreino({
    required int idAluno,
    required DiaSemana diaSemana,
    required List<ExercicioForm> exercicios,
  }) async {}
}

// ---- Fixtures ----

Usuario _aluno(int id) => Usuario(
      idUsuario: id,
      nome: 'Aluno $id',
      email: 'aluno$id@test.com',
      tipo: TipoUsuario.aluno,
    );

Exercicio _exercicio(int id) => Exercicio(
      idExercicio: id,
      nome: 'Exercício $id',
    );

// ---- Testes ----

void main() {
  late _FakeClienteRepository fakeRepo;
  late ClienteProvider provider;

  setUp(() {
    fakeRepo = _FakeClienteRepository();
    provider = ClienteProvider(fakeRepo);
  });

  // =========================================================
  // Exercícios
  // =========================================================

  group('carregarExercicios', () {
    test('preenche lista ao carregar com sucesso', () async {
      fakeRepo.exercicios = [_exercicio(1), _exercicio(2)];
      await provider.carregarExercicios();

      expect(provider.exercicios.length, 2);
      expect(provider.erroExercicios, isNull);
      expect(provider.carregandoExercicios, isFalse);
    });

    test('falha → erroExercicios preenchido, lista vazia', () async {
      fakeRepo.fails = true;
      fakeRepo.erroMsg = 'Sem conexão';
      await provider.carregarExercicios();

      expect(provider.erroExercicios, 'Sem conexão');
      expect(provider.exercicios, isEmpty);
    });
  });

  group('cadastrarExercicio', () {
    test('novo exercício é adicionado à lista existente', () async {
      fakeRepo.exercicios = [_exercicio(1)];
      await provider.carregarExercicios();

      fakeRepo.exercicioRetornado = _exercicio(99);
      await provider.cadastrarExercicio('Novo', null);

      expect(provider.exercicios.length, 2);
      expect(provider.exercicios.last.idExercicio, 99);
      expect(provider.salvando, isFalse);
    });
  });

  group('atualizarExercicio', () {
    test('substitui exercício correto na lista', () async {
      fakeRepo.exercicios = [_exercicio(1), _exercicio(2), _exercicio(3)];
      await provider.carregarExercicios();

      await provider.atualizarExercicio(2, 'Nome Atualizado', null, null);

      final atualizado = provider.exercicios.firstWhere((e) => e.idExercicio == 2);
      expect(atualizado.nome, 'Nome Atualizado');
      // Os outros permanecem intactos
      expect(provider.exercicios.length, 3);
      expect(provider.exercicios.firstWhere((e) => e.idExercicio == 1).nome,
          'Exercício 1');
    });
  });

  group('removerExercicio', () {
    test('remove exercício da lista pelo id', () async {
      fakeRepo.exercicios = [_exercicio(1), _exercicio(2)];
      await provider.carregarExercicios();

      await provider.removerExercicio(1);

      expect(provider.exercicios.length, 1);
      expect(provider.exercicios.first.idExercicio, 2);
    });
  });

  // =========================================================
  // Alunos
  // =========================================================

  group('carregarAlunos', () {
    test('preenche lista ao carregar com sucesso', () async {
      fakeRepo.alunos = [_aluno(10), _aluno(20)];
      await provider.carregarAlunos();

      expect(provider.alunos.length, 2);
      expect(provider.erroAlunos, isNull);
    });

    test('falha → erroAlunos preenchido', () async {
      fakeRepo.fails = true;
      fakeRepo.erroMsg = 'Timeout';
      await provider.carregarAlunos();

      expect(provider.erroAlunos, 'Timeout');
      expect(provider.alunos, isEmpty);
    });

    test(
        'alunoSelecionado removido da lista → limpa seleção (anti-crash dropdown)',
        () async {
      fakeRepo.alunos = [_aluno(10), _aluno(20)];
      await provider.carregarAlunos();

      // Seleciona o aluno 10 carregando treinos
      await provider.carregarTreinosDoAluno(10);
      expect(provider.alunoSelecionado, 10);

      // Recarrega lista sem o aluno 10
      fakeRepo.alunos = [_aluno(20)];
      await provider.carregarAlunos();

      // Seleção deve ser limpa para não causar crash no dropdown
      expect(provider.alunoSelecionado, isNull);
      expect(provider.treinosAluno, isEmpty);
    });

    test('alunoSelecionado ainda na lista → seleção mantida', () async {
      fakeRepo.alunos = [_aluno(10), _aluno(20)];
      await provider.carregarAlunos();
      await provider.carregarTreinosDoAluno(10);

      // Recarrega com o aluno 10 ainda presente
      fakeRepo.alunos = [_aluno(10), _aluno(20)];
      await provider.carregarAlunos();

      expect(provider.alunoSelecionado, 10);
    });
  });

  group('removerAluno', () {
    test('remove aluno da lista', () async {
      fakeRepo.alunos = [_aluno(1), _aluno(2)];
      await provider.carregarAlunos();

      await provider.removerAluno(1);

      expect(provider.alunos.length, 1);
      expect(provider.alunos.first.idUsuario, 2);
    });

    test('remover o alunoSelecionado limpa a seleção e treinos (anti-crash)',
        () async {
      fakeRepo.alunos = [_aluno(1), _aluno(2)];
      await provider.carregarAlunos();
      await provider.carregarTreinosDoAluno(1);
      expect(provider.alunoSelecionado, 1);

      await provider.removerAluno(1);

      expect(provider.alunoSelecionado, isNull);
      expect(provider.treinosAluno, isEmpty);
      expect(provider.erroTreinosAluno, isNull);
    });

    test('remover aluno NÃO selecionado não afeta a seleção', () async {
      fakeRepo.alunos = [_aluno(1), _aluno(2)];
      await provider.carregarAlunos();
      await provider.carregarTreinosDoAluno(1);

      await provider.removerAluno(2);

      expect(provider.alunoSelecionado, 1);
    });
  });
}
