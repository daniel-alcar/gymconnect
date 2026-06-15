import 'package:flutter_test/flutter_test.dart';
import 'package:gymconnect/app/modules/auth/models/tipo_usuario.dart';
import 'package:gymconnect/app/modules/auth/models/usuario.dart';

void main() {
  group('TipoUsuario.fromString', () {
    test('CLIENTE retorna cliente', () {
      expect(TipoUsuario.fromString('CLIENTE'), TipoUsuario.cliente);
    });

    test('ALUNO retorna aluno', () {
      expect(TipoUsuario.fromString('ALUNO'), TipoUsuario.aluno);
    });

    test('valor desconhecido retorna aluno (fallback seguro)', () {
      expect(TipoUsuario.fromString('ADMIN'), TipoUsuario.aluno);
      expect(TipoUsuario.fromString('cliente'), TipoUsuario.aluno);
      expect(TipoUsuario.fromString(''), TipoUsuario.aluno);
    });

    test('null retorna aluno', () {
      expect(TipoUsuario.fromString(null), TipoUsuario.aluno);
    });

    test('fromString(tipo.value) é identidade para todos os tipos', () {
      for (final t in TipoUsuario.values) {
        expect(TipoUsuario.fromString(t.value), t);
      }
    });
  });

  group('TipoUsuario.label', () {
    test('CLIENTE exibe Professor', () {
      expect(TipoUsuario.cliente.label, 'Professor');
    });

    test('ALUNO exibe Aluno', () {
      expect(TipoUsuario.aluno.label, 'Aluno');
    });
  });

  group('Usuario.isCliente / isAluno', () {
    const prof = Usuario(
      idUsuario: 1,
      nome: 'Prof',
      email: 'prof@test.com',
      tipo: TipoUsuario.cliente,
    );
    const aluno = Usuario(
      idUsuario: 2,
      nome: 'Aluno',
      email: 'aluno@test.com',
      tipo: TipoUsuario.aluno,
    );

    test('isCliente verdadeiro apenas para CLIENTE', () {
      expect(prof.isCliente, isTrue);
      expect(prof.isAluno, isFalse);
    });

    test('isAluno verdadeiro apenas para ALUNO', () {
      expect(aluno.isAluno, isTrue);
      expect(aluno.isCliente, isFalse);
    });

    test('roundtrip toJson/fromJson preserva tipo', () {
      final restaurado = Usuario.fromJson(prof.toJson());
      expect(restaurado.tipo, TipoUsuario.cliente);
      expect(restaurado.isCliente, isTrue);
    });
  });

  group('Usuario.fromJson', () {
    test('nome null assume string vazia', () {
      final u = Usuario.fromJson({
        'idUsuario': 1,
        'nome': null,
        'email': 'a@b.com',
        'tipo': 'ALUNO',
      });
      expect(u.nome, '');
    });

    test('email null assume string vazia', () {
      final u = Usuario.fromJson({
        'idUsuario': 1,
        'nome': 'Ana',
        'email': null,
        'tipo': 'ALUNO',
      });
      expect(u.email, '');
    });
  });
}
