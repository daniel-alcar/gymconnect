import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gymconnect/app/core/errors/app_exception.dart';
import 'package:gymconnect/app/modules/chat/models/chat_message.dart';
import 'package:gymconnect/app/modules/auth/models/usuario.dart';
import 'package:gymconnect/app/modules/treinos/models/dia_semana.dart';
import 'package:gymconnect/app/modules/treinos/models/cronograma_exercicio.dart';
import 'package:gymconnect/app/modules/treinos/providers/treino_provider.dart';
import 'package:gymconnect/app/modules/treinos/repositories/treino_repository.dart';
import 'package:gymconnect/app/core/storage/storage_service.dart';

// ---- Fakes ----

class _FakeTreinoRepository implements TreinoRepository {
  List<TreinoDia> treinoDias = [];
  bool fails = false;
  String erroMsg = 'Erro de rede';
  int chamadasMarcarFeito = 0;

  @override
  Future<List<TreinoDia>> carregarTreinos(int idAluno) async {
    if (fails) throw AppException(erroMsg);
    return treinoDias;
  }

  @override
  Future<void> marcarComoFeito({required int idCronograma}) async {
    chamadasMarcarFeito++;
  }
}

class _FakeStorageService implements StorageService {
  final Map<String, String> _store = {};

  @override
  Future<void> salvarToken(String token) async => _store['token'] = token;
  @override
  Future<String?> lerToken() async => _store['token'];
  @override
  Future<void> salvarUsuario(Usuario usuario) async {}
  @override
  Future<Usuario?> lerUsuario() async => null;
  @override
  Future<void> salvarThemeMode(ThemeMode modo) async {}
  @override
  Future<ThemeMode> lerThemeMode() async => ThemeMode.light;
  @override
  Future<void> salvarFotoPerfil(int idUsuario, String path) async {}
  @override
  Future<String?> lerFotoPerfil(int idUsuario) async => null;
  @override
  Future<void> removerFotoPerfil(int idUsuario) async {}
  @override
  Future<void> salvarAtividades(int idUsuario, String jsonList) async {}
  @override
  Future<String?> lerAtividades(int idUsuario) async => null;
  @override
  Future<void> salvarExerciciosFeitos(int idUsuario, String jsonList) async {
    _store['ex_$idUsuario'] = jsonList;
  }

  @override
  Future<String?> lerExerciciosFeitos(int idUsuario) async =>
      _store['ex_$idUsuario'];
  @override
  Future<void> salvarDiasConcluidos(int idUsuario, String jsonList) async {
    _store['dias_$idUsuario'] = jsonList;
  }

  @override
  Future<String?> lerDiasConcluidos(int idUsuario) async =>
      _store['dias_$idUsuario'];
  @override
  Future<void> salvarHistoricoChat(
      int idUsuario, List<ChatMessage> mensagens) async {}
  @override
  Future<List<ChatMessage>> lerHistoricoChat(int idUsuario) async => [];
  @override
  Future<void> limpar() async => _store.clear();
}

// ---- Helpers ----

TreinoDia _fakeDia(DiaSemana dia) => TreinoDia(
      dia: dia,
      exercicios: [
        CronogramaExercicio.fromJson(
          {'idCronogramaExercicio': dia.ordem + 1, 'diaSemana': dia.value, 'serie': 3, 'repeticao': 10},
          idCronograma: 100 + dia.ordem,
        ),
      ],
    );

// ---- Testes ----

void main() {
  late _FakeTreinoRepository fakeRepo;
  late _FakeStorageService fakeStorage;
  late TreinoProvider provider;

  setUp(() {
    fakeRepo = _FakeTreinoRepository();
    fakeStorage = _FakeStorageService();
    provider = TreinoProvider(fakeRepo, fakeStorage);
  });

  group('estado inicial', () {
    test('não está carregando, sem erro, sem dias', () {
      expect(provider.carregando, isFalse);
      expect(provider.erro, isNull);
      expect(provider.dias, isEmpty);
      expect(provider.vazio, isTrue);
    });
  });

  group('carregar', () {
    test('carrega lista de dias com sucesso', () async {
      fakeRepo.treinoDias = [_fakeDia(DiaSemana.segunda), _fakeDia(DiaSemana.quarta)];

      await provider.carregar(1);

      expect(provider.carregando, isFalse);
      expect(provider.erro, isNull);
      expect(provider.dias.length, 2);
      expect(provider.vazio, isFalse);
    });

    test('falha de rede → erro é preenchido, dias ficam vazios', () async {
      fakeRepo.fails = true;
      fakeRepo.erroMsg = 'Sem conexão';

      await provider.carregar(1);

      expect(provider.carregando, isFalse);
      expect(provider.erro, 'Sem conexão');
      expect(provider.dias, isEmpty);
    });

    test('lista vazia de dias → vazio=true', () async {
      fakeRepo.treinoDias = [];
      await provider.carregar(1);

      expect(provider.vazio, isTrue);
    });
  });

  group('marcarComoFeito', () {
    test('adiciona exercício ao set de feitos', () async {
      await provider.carregar(1);

      await provider.marcarComoFeito(
        idCronogramaExercicio: 42,
        idCronograma: 100,
      );

      expect(provider.exercicioFeito(42), isTrue);
      expect(fakeRepo.chamadasMarcarFeito, 1);
    });

    test('persiste no storage após marcar', () async {
      await provider.carregar(1);
      await provider.marcarComoFeito(
        idCronogramaExercicio: 10,
        idCronograma: 5,
      );

      final salvo = await fakeStorage.lerExerciciosFeitos(1);
      expect(salvo, contains('10'));
    });
  });

  group('desmarcarExercicio', () {
    test('remove exercício do set de feitos', () async {
      await provider.carregar(1);
      await provider.marcarComoFeito(
          idCronogramaExercicio: 7, idCronograma: 3);
      expect(provider.exercicioFeito(7), isTrue);

      await provider.desmarcarExercicio(7);

      expect(provider.exercicioFeito(7), isFalse);
    });

    test('não interfere em outros exercícios marcados', () async {
      await provider.carregar(1);
      await provider.marcarComoFeito(idCronogramaExercicio: 1, idCronograma: 1);
      await provider.marcarComoFeito(idCronogramaExercicio: 2, idCronograma: 2);

      await provider.desmarcarExercicio(1);

      expect(provider.exercicioFeito(1), isFalse);
      expect(provider.exercicioFeito(2), isTrue);
    });
  });

  group('exercicioFeito', () {
    test('null retorna false (sem crash)', () {
      expect(provider.exercicioFeito(null), isFalse);
    });

    test('id não marcado retorna false', () {
      expect(provider.exercicioFeito(999), isFalse);
    });
  });

  group('concluirDia / desmarcarDia', () {
    test('concluirDia → diaConcluido retorna true', () async {
      await provider.carregar(1);
      await provider.concluirDia('Segunda-feira');

      expect(provider.diaConcluido('Segunda-feira'), isTrue);
    });

    test('diaConcluido false para dia não concluído', () {
      expect(provider.diaConcluido('Sexta-feira'), isFalse);
    });

    test('desmarcarDia remove a conclusão', () async {
      await provider.carregar(1);
      await provider.concluirDia('Terça-feira');
      expect(provider.diaConcluido('Terça-feira'), isTrue);

      await provider.desmarcarDia('Terça-feira');

      expect(provider.diaConcluido('Terça-feira'), isFalse);
    });

    test('concluirDia persiste no storage', () async {
      await provider.carregar(1);
      await provider.concluirDia('Quarta-feira');

      final salvo = await fakeStorage.lerDiasConcluidos(1);
      expect(salvo, contains('Quarta-feira'));
    });
  });

  group('persistência entre recargas', () {
    test('exercícios marcados são restaurados ao recarregar', () async {
      await provider.carregar(1);
      await provider.marcarComoFeito(idCronogramaExercicio: 55, idCronograma: 10);

      // Simula reinício: novo provider com o mesmo storage
      final provider2 = TreinoProvider(fakeRepo, fakeStorage);
      await provider2.carregar(1);

      expect(provider2.exercicioFeito(55), isTrue);
    });

    test('dias concluídos são restaurados ao recarregar', () async {
      await provider.carregar(1);
      await provider.concluirDia('Domingo');

      final provider2 = TreinoProvider(fakeRepo, fakeStorage);
      await provider2.carregar(1);

      expect(provider2.diaConcluido('Domingo'), isTrue);
    });
  });

  group('limpar', () {
    test('reseta todos os campos de estado', () async {
      fakeRepo.treinoDias = [_fakeDia(DiaSemana.sexta)];
      await provider.carregar(1);
      await provider.marcarComoFeito(idCronogramaExercicio: 1, idCronograma: 1);
      await provider.concluirDia('Sexta-feira');

      provider.limpar();

      expect(provider.dias, isEmpty);
      expect(provider.erro, isNull);
      expect(provider.exercicioFeito(1), isFalse);
      expect(provider.diaConcluido('Sexta-feira'), isFalse);
    });
  });
}
