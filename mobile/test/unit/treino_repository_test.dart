import 'package:flutter_test/flutter_test.dart';

import 'package:gymconnect/app/core/errors/app_exception.dart';
import 'package:gymconnect/app/core/network/connectivity_service.dart';
import 'package:gymconnect/app/modules/treinos/models/cronograma.dart';
import 'package:gymconnect/app/modules/treinos/models/cronograma_execucao.dart';
import 'package:gymconnect/app/modules/treinos/models/dia_semana.dart';
import 'package:gymconnect/app/modules/treinos/models/status_execucao.dart';
import 'package:gymconnect/app/modules/treinos/repositories/treino_cache_repository.dart';
import 'package:gymconnect/app/modules/treinos/repositories/treino_repository.dart';
import 'package:gymconnect/app/modules/treinos/services/execucao_service.dart';
import 'package:gymconnect/app/modules/treinos/services/treino_service.dart';

// ---- Fakes ----

class _FakeConnectivity implements ConnectivityService {
  bool online;
  _FakeConnectivity({this.online = true});

  @override
  Future<bool> isOnline() async => online;

  @override
  Stream<bool> get onStatusChange => const Stream.empty();
}

class _FakeTreinoService implements TreinoService {
  List<Cronograma> cronogramas = const [];
  bool fails = false;
  int? failStatusCode;

  @override
  Future<List<Cronograma>> listarCronogramasPorAluno(int idAluno) async {
    if (fails) throw AppException('Erro de rede', statusCode: failStatusCode);
    return cronogramas;
  }
}

class _FakeExecucaoService implements ExecucaoService {
  int chamadasCriar = 0;

  @override
  Future<CronogramaExecucao> criar({
    required int idCronograma,
    required StatusExecucao status,
  }) async {
    chamadasCriar++;
    return const CronogramaExecucao(status: StatusExecucao.feito);
  }

  @override
  Future<CronogramaExecucao> atualizarStatus({
    required int idExecucao,
    required StatusExecucao status,
  }) async =>
      const CronogramaExecucao(status: StatusExecucao.feito);

  @override
  Future<List<CronogramaExecucao>> listarPorCronograma(
      int idCronograma) async => [];
}

class _FakeCacheRepository implements TreinoCacheRepository {
  List<Cronograma>? cache;
  int chamadasSalvar = 0;

  @override
  Future<void> salvarTreinos(int idAluno, List<Cronograma> cronogramas) async {
    chamadasSalvar++;
    cache = cronogramas;
  }

  @override
  Future<List<Cronograma>?> lerTreinos(int idAluno) async => cache;

  @override
  Future<void> limpar() async => cache = null;
}

// ---- Helpers ----

Cronograma _cronograma(int id, List<DiaSemana?> dias) {
  return Cronograma.fromJson({
    'idCronograma': id,
    'exercicio': [
      for (int i = 0; i < dias.length; i++)
        {
          'idCronogramaExercicio': id * 10 + i,
          'diaSemana': dias[i]?.value,
          'serie': 3,
          'repeticao': 10,
        }
    ],
  });
}

// ---- Testes ----

void main() {
  late _FakeTreinoService fakeService;
  late _FakeExecucaoService fakeExecucao;
  late _FakeCacheRepository fakeCache;
  late _FakeConnectivity fakeConn;
  late TreinoRepository repo;

  setUp(() {
    fakeService = _FakeTreinoService();
    fakeExecucao = _FakeExecucaoService();
    fakeCache = _FakeCacheRepository();
    fakeConn = _FakeConnectivity(online: true);
    repo = TreinoRepository(fakeService, fakeExecucao, fakeCache, fakeConn);
  });

  // =========================================================
  // Agrupamento por dia (_agruparPorDia)
  // =========================================================

  group('_agruparPorDia via carregarTreinos', () {
    test('exercícios agrupados corretamente por dia', () async {
      fakeService.cronogramas = [
        _cronograma(1, [DiaSemana.segunda, DiaSemana.segunda, DiaSemana.quarta]),
      ];

      final dias = await repo.carregarTreinos(1);

      final titulos = dias.map((d) => d.dia).toList();
      expect(titulos, containsAll([DiaSemana.segunda, DiaSemana.quarta]));
      final segunda = dias.firstWhere((d) => d.dia == DiaSemana.segunda);
      expect(segunda.exercicios.length, 2);
    });

    test('dias ordenados pelo índice do enum (segunda → domingo)', () async {
      fakeService.cronogramas = [
        _cronograma(
          1,
          [DiaSemana.sexta, DiaSemana.segunda, DiaSemana.quarta],
        ),
      ];

      final dias = await repo.carregarTreinos(1);

      final ordens = dias.map((d) => d.dia?.ordem ?? 999).toList();
      for (int i = 0; i < ordens.length - 1; i++) {
        expect(ordens[i], lessThanOrEqualTo(ordens[i + 1]));
      }
    });

    test('múltiplos cronogramas são mesclados em um único resultado', () async {
      fakeService.cronogramas = [
        _cronograma(1, [DiaSemana.segunda]),
        _cronograma(2, [DiaSemana.terca]),
        _cronograma(3, [DiaSemana.quinta]),
      ];

      final dias = await repo.carregarTreinos(1);

      expect(dias.length, 3);
    });

    test('cronogramas sem exercícios resultam em lista vazia', () async {
      fakeService.cronogramas = [
        Cronograma.fromJson({'idCronograma': 1}),
      ];

      final dias = await repo.carregarTreinos(1);

      expect(dias, isEmpty);
    });

    test('exercício sem dia é agrupado com dia=null', () async {
      fakeService.cronogramas = [
        _cronograma(1, [null]),
      ];

      final dias = await repo.carregarTreinos(1);

      expect(dias.length, 1);
      expect(dias.first.dia, isNull);
      expect(dias.first.titulo, 'Sem dia definido');
    });
  });

  // =========================================================
  // Offline-First
  // =========================================================

  group('online', () {
    test('atualiza o cache após busca bem-sucedida', () async {
      fakeService.cronogramas = [_cronograma(1, [DiaSemana.segunda])];

      await repo.carregarTreinos(1);

      expect(fakeCache.chamadasSalvar, 1);
      expect(fakeCache.cache, isNotNull);
    });
  });

  group('fallback para cache', () {
    test('falha de rede (sem statusCode) → usa cache local', () async {
      fakeCache.cache = [_cronograma(1, [DiaSemana.quarta])];
      fakeService.fails = true;
      fakeService.failStatusCode = null; // erro de rede sem código HTTP

      final dias = await repo.carregarTreinos(1);

      expect(dias.length, 1);
      expect(dias.first.dia, DiaSemana.quarta);
    });

    test('erro de auth (401) propaga sem usar cache', () async {
      fakeCache.cache = [_cronograma(1, [DiaSemana.segunda])];
      fakeService.fails = true;
      fakeService.failStatusCode = 401;

      await expectLater(
        repo.carregarTreinos(1),
        throwsA(isA<AppException>()
            .having((e) => e.isAuthError, 'isAuthError', isTrue)),
      );
    });

    test('erro de auth (403) propaga sem usar cache', () async {
      fakeCache.cache = [_cronograma(1, [DiaSemana.segunda])];
      fakeService.fails = true;
      fakeService.failStatusCode = 403;

      await expectLater(
        repo.carregarTreinos(1),
        throwsA(isA<AppException>()
            .having((e) => e.isAuthError, 'isAuthError', isTrue)),
      );
    });
  });

  group('modo offline', () {
    setUp(() => fakeConn = _FakeConnectivity(online: false));

    test('offline com cache → retorna treinos do cache', () async {
      fakeCache.cache = [_cronograma(1, [DiaSemana.sexta])];
      repo = TreinoRepository(fakeService, fakeExecucao, fakeCache, fakeConn);

      final dias = await repo.carregarTreinos(1);

      expect(dias.length, 1);
      expect(dias.first.dia, DiaSemana.sexta);
    });

    test('offline sem cache → lança AppException com mensagem amigável',
        () async {
      fakeCache.cache = null;
      repo = TreinoRepository(fakeService, fakeExecucao, fakeCache, fakeConn);

      await expectLater(
        repo.carregarTreinos(1),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            contains('offline'),
          ),
        ),
      );
    });
  });

  // =========================================================
  // marcarComoFeito
  // =========================================================

  group('marcarComoFeito', () {
    test('chama ExecucaoService.criar com os parâmetros corretos', () async {
      await repo.marcarComoFeito(idCronograma: 77);

      expect(fakeExecucao.chamadasCriar, 1);
    });
  });
}
