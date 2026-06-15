import 'package:flutter_test/flutter_test.dart';
import 'package:gymconnect/app/modules/auth/models/usuario.dart';
import 'package:gymconnect/app/modules/auth/models/tipo_usuario.dart';

void main() {
  group('Usuario.fromJson', () {
    test('desserializa usuário ALUNO corretamente', () {
      final usuario = Usuario.fromJson({
        'idUsuario': 1,
        'nome': 'Carlos Silva',
        'email': 'carlos@email.com',
        'tipo': 'ALUNO',
      });

      expect(usuario.idUsuario, 1);
      expect(usuario.nome, 'Carlos Silva');
      expect(usuario.email, 'carlos@email.com');
      expect(usuario.tipo, TipoUsuario.aluno);
      expect(usuario.isAluno, isTrue);
      expect(usuario.isCliente, isFalse);
    });

    test('desserializa usuário CLIENTE (professor) corretamente', () {
      final usuario = Usuario.fromJson({
        'idUsuario': 10,
        'nome': 'Ana Professora',
        'email': 'ana@email.com',
        'tipo': 'CLIENTE',
      });

      expect(usuario.isCliente, isTrue);
      expect(usuario.isAluno, isFalse);
    });

    test('converte idUsuario de num para int', () {
      final usuario = Usuario.fromJson({
        'idUsuario': 5.0,
        'nome': 'Teste',
        'email': 'teste@email.com',
        'tipo': 'ALUNO',
      });
      expect(usuario.idUsuario, isA<int>());
      expect(usuario.idUsuario, 5);
    });

    test('usa string vazia quando nome/email são nulos', () {
      final usuario = Usuario.fromJson({
        'idUsuario': 1,
        'nome': null,
        'email': null,
        'tipo': 'ALUNO',
      });
      expect(usuario.nome, '');
      expect(usuario.email, '');
    });
  });

  group('Usuario.toJson', () {
    test('serializa corretamente', () {
      const usuario = Usuario(
        idUsuario: 7,
        nome: 'João',
        email: 'joao@email.com',
        tipo: TipoUsuario.aluno,
      );
      final json = usuario.toJson();

      expect(json['idUsuario'], 7);
      expect(json['nome'], 'João');
      expect(json['email'], 'joao@email.com');
    });
  });
}
