import 'package:flutter_test/flutter_test.dart';
import 'package:gymconnect/app/shared/utils/validators.dart';

void main() {
  group('Validators.obrigatorio', () {
    test('retorna erro quando vazio', () {
      expect(Validators.obrigatorio(''), isNotNull);
      expect(Validators.obrigatorio('   '), isNotNull);
      expect(Validators.obrigatorio(null), isNotNull);
    });

    test('retorna null quando preenchido', () {
      expect(Validators.obrigatorio('João'), isNull);
    });

    test('usa nome do campo na mensagem', () {
      final msg = Validators.obrigatorio('', campo: 'Objetivo');
      expect(msg, contains('Objetivo'));
    });
  });

  group('Validators.email', () {
    test('aceita e-mails válidos', () {
      expect(Validators.email('user@email.com'), isNull);
      expect(Validators.email('user.name+tag@sub.domain.com'), isNull);
    });

    test('rejeita e-mails inválidos', () {
      expect(Validators.email('semArroba'), isNotNull);
      expect(Validators.email('@semLocal.com'), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });
  });

  group('Validators.senha', () {
    test('aceita senha com letra e número, mín. 8 chars', () {
      expect(Validators.senha('Abc12345'), isNull);
      expect(Validators.senha('senha123'), isNull);
    });

    test('rejeita senha curta', () {
      expect(Validators.senha('Ab1'), isNotNull);
    });

    test('rejeita senha só com letras', () {
      expect(Validators.senha('abcdefgh'), isNotNull);
    });

    test('rejeita senha só com números', () {
      expect(Validators.senha('12345678'), isNotNull);
    });

    test('rejeita vazio', () {
      expect(Validators.senha(''), isNotNull);
      expect(Validators.senha(null), isNotNull);
    });
  });

  group('Validators.confirmarSenha', () {
    test('aceita quando senhas são iguais', () {
      expect(Validators.confirmarSenha('Abc123', 'Abc123'), isNull);
    });

    test('rejeita quando senhas diferem', () {
      expect(Validators.confirmarSenha('Abc123', 'Abc124'), isNotNull);
    });

    test('rejeita vazio', () {
      expect(Validators.confirmarSenha('', 'Abc123'), isNotNull);
    });
  });

  group('Validators.altura', () {
    test('aceita alturas válidas', () {
      expect(Validators.altura('1,75'), isNull);
      expect(Validators.altura('1.75'), isNull);
      expect(Validators.altura('2,20'), isNull);
      expect(Validators.altura('0,50'), isNull);
    });

    test('rejeita altura acima de 2,20', () {
      expect(Validators.altura('2,21'), isNotNull);
      expect(Validators.altura('3,00'), isNotNull);
    });

    test('rejeita zero e negativo', () {
      expect(Validators.altura('0'), isNotNull);
      expect(Validators.altura('-1'), isNotNull);
    });

    test('rejeita texto inválido e vazio', () {
      expect(Validators.altura('abc'), isNotNull);
      expect(Validators.altura(''), isNotNull);
      expect(Validators.altura(null), isNotNull);
    });
  });

  group('Validators.pesoOpcional', () {
    test('aceita vazio (campo opcional)', () {
      expect(Validators.pesoOpcional(''), isNull);
      expect(Validators.pesoOpcional(null), isNull);
    });

    test('aceita peso válido', () {
      expect(Validators.pesoOpcional('72.5'), isNull);
      expect(Validators.pesoOpcional('100'), isNull);
    });

    test('rejeita peso inválido quando preenchido', () {
      expect(Validators.pesoOpcional('0'), isNotNull);
      expect(Validators.pesoOpcional('-5'), isNotNull);
      expect(Validators.pesoOpcional('abc'), isNotNull);
    });
  });
}
