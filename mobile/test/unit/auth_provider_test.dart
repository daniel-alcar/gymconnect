import 'package:flutter_test/flutter_test.dart';

import 'package:gymconnect/app/core/errors/app_exception.dart';
import 'package:gymconnect/app/modules/auth/models/session_model.dart';
import 'package:gymconnect/app/modules/auth/models/tipo_usuario.dart';
import 'package:gymconnect/app/modules/auth/models/usuario.dart';
import 'package:gymconnect/app/modules/auth/providers/auth_provider.dart';
import 'package:gymconnect/app/modules/auth/repositories/auth_repository.dart';

// ---- Fake ----

const _alunoFixture = Usuario(
  idUsuario: 1,
  nome: 'Aluno Teste',
  email: 'aluno@test.com',
  tipo: TipoUsuario.aluno,
);

const _profFixture = Usuario(
  idUsuario: 2,
  nome: 'Prof Teste',
  email: 'prof@test.com',
  tipo: TipoUsuario.cliente,
);

class _FakeAuthRepository implements AuthRepository {
  Usuario? savedUser;
  String? savedToken;

  Usuario loginResult = _alunoFixture;
  bool loginFails = false;

  bool revalidaFails = false;
  int? revalidaStatusCode;

  @override
  Future<Usuario> login(String email, String senha) async {
    if (loginFails) {
      throw const AppException('E-mail ou senha incorretos', statusCode: 401);
    }
    savedToken = 'token-fake';
    savedUser = loginResult;
    return loginResult;
  }

  @override
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required TipoUsuario tipo,
  }) async {}

  @override
  Future<Usuario> revalidarSessao() async {
    if (revalidaFails) {
      throw AppException('Erro de revalidação', statusCode: revalidaStatusCode);
    }
    return savedUser!;
  }

  @override
  Future<Usuario?> usuarioSalvo() async => savedUser;

  @override
  Future<String?> tokenSalvo() async => savedToken;

  @override
  Future<SessionModel?> sessaoLocal() async => null;

  @override
  Future<void> logout() async {
    savedUser = null;
    savedToken = null;
  }
}

// ---- Testes ----

void main() {
  late _FakeAuthRepository fakeRepo;
  late AuthProvider provider;

  setUp(() {
    fakeRepo = _FakeAuthRepository();
    provider = AuthProvider(fakeRepo);
  });

  group('estado inicial', () {
    test('status começa como desconhecido', () {
      expect(provider.status, AuthStatus.desconhecido);
      expect(provider.usuario, isNull);
      expect(provider.autenticado, isFalse);
    });
  });

  group('carregarSessao', () {
    test('sem token salvo → naoAutenticado', () async {
      await provider.carregarSessao();

      expect(provider.status, AuthStatus.naoAutenticado);
      expect(provider.usuario, isNull);
      expect(provider.autenticado, isFalse);
    });

    test('com token + revalidação ok → autenticado com usuário', () async {
      fakeRepo.savedToken = 'tok';
      fakeRepo.savedUser = _alunoFixture;

      await provider.carregarSessao();

      expect(provider.status, AuthStatus.autenticado);
      expect(provider.usuario?.idUsuario, 1);
      expect(provider.autenticado, isTrue);
    });

    test('revalidação retorna 401 → desloga (naoAutenticado)', () async {
      fakeRepo.savedToken = 'tok';
      fakeRepo.savedUser = _alunoFixture;
      fakeRepo.revalidaFails = true;
      fakeRepo.revalidaStatusCode = 401;

      await provider.carregarSessao();

      expect(provider.status, AuthStatus.naoAutenticado);
      expect(provider.usuario, isNull);
    });

    test('revalidação retorna 403 → desloga (naoAutenticado)', () async {
      fakeRepo.savedToken = 'tok';
      fakeRepo.savedUser = _alunoFixture;
      fakeRepo.revalidaFails = true;
      fakeRepo.revalidaStatusCode = 403;

      await provider.carregarSessao();

      expect(provider.status, AuthStatus.naoAutenticado);
    });

    test('revalidação falha por rede (sem statusCode) → mantém sessão offline', () async {
      fakeRepo.savedToken = 'tok';
      fakeRepo.savedUser = _alunoFixture;
      fakeRepo.revalidaFails = true;
      fakeRepo.revalidaStatusCode = null; // sem código = erro de rede

      await provider.carregarSessao();

      // Offline-First: não desloga em falha de rede
      expect(provider.status, AuthStatus.autenticado);
      expect(provider.usuario, isNotNull);
    });
  });

  group('login', () {
    test('login com sucesso → autenticado', () async {
      await provider.login('aluno@test.com', '123456');

      expect(provider.status, AuthStatus.autenticado);
      expect(provider.usuario?.nome, 'Aluno Teste');
      expect(provider.autenticado, isTrue);
    });

    test('login como aluno → isAluno true, isCliente false', () async {
      fakeRepo.loginResult = _alunoFixture;
      await provider.login('aluno@test.com', '123');

      expect(provider.isAluno, isTrue);
      expect(provider.isCliente, isFalse);
    });

    test('login como professor → isCliente true, isAluno false', () async {
      fakeRepo.loginResult = _profFixture;
      await provider.login('prof@test.com', '123');

      expect(provider.isCliente, isTrue);
      expect(provider.isAluno, isFalse);
    });

    test('login falha → AppException propagada, carregando=false', () async {
      fakeRepo.loginFails = true;

      await expectLater(
        provider.login('x@x.com', 'errado'),
        throwsA(isA<AppException>()),
      );

      expect(provider.carregando, isFalse);
    });
  });

  group('logout', () {
    test('logout → naoAutenticado, usuario null', () async {
      fakeRepo.savedToken = 'tok';
      fakeRepo.savedUser = _alunoFixture;
      await provider.carregarSessao();
      expect(provider.autenticado, isTrue);

      await provider.logout();

      expect(provider.status, AuthStatus.naoAutenticado);
      expect(provider.usuario, isNull);
      expect(provider.autenticado, isFalse);
    });
  });

  group('sessaoExpirada', () {
    test('desloga imediatamente (chamada síncrona pelo Dio interceptor)', () async {
      fakeRepo.savedToken = 'tok';
      fakeRepo.savedUser = _alunoFixture;
      await provider.carregarSessao();
      expect(provider.autenticado, isTrue);

      provider.sessaoExpirada();

      expect(provider.status, AuthStatus.naoAutenticado);
      expect(provider.usuario, isNull);
    });
  });

  group('isCliente / isAluno sem usuário', () {
    test('retornam false quando não há usuário', () {
      expect(provider.isCliente, isFalse);
      expect(provider.isAluno, isFalse);
    });
  });
}
