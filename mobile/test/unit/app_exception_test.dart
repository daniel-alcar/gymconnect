import 'package:flutter_test/flutter_test.dart';
import 'package:gymconnect/app/core/errors/app_exception.dart';

void main() {
  group('AppException.isAuthError', () {
    test('401 é erro de autenticação', () {
      expect(const AppException('Não autorizado', statusCode: 401).isAuthError, isTrue);
    });

    test('403 é erro de autorização', () {
      expect(const AppException('Proibido', statusCode: 403).isAuthError, isTrue);
    });

    test('400 não é erro de auth', () {
      expect(const AppException('Bad request', statusCode: 400).isAuthError, isFalse);
    });

    test('404 não é erro de auth', () {
      expect(const AppException('Não encontrado', statusCode: 404).isAuthError, isFalse);
    });

    test('500 não é erro de auth', () {
      expect(const AppException('Servidor', statusCode: 500).isAuthError, isFalse);
    });

    test('sem statusCode não é erro de auth (falha de rede)', () {
      expect(const AppException('Sem internet').isAuthError, isFalse);
    });
  });

  group('AppException.copyWith', () {
    test('altera message e preserva statusCode', () {
      const original = AppException('Original', statusCode: 404);
      final copia = original.copyWith('Nova mensagem');

      expect(copia.message, 'Nova mensagem');
      expect(copia.statusCode, 404);
    });

    test('preserva ausência de statusCode', () {
      const original = AppException('Sem código');
      final copia = original.copyWith('Outro texto');

      expect(copia.statusCode, isNull);
    });
  });

  group('AppException.toString', () {
    test('retorna a message', () {
      const e = AppException('Erro de rede');
      expect(e.toString(), 'Erro de rede');
    });

    test('toString com statusCode retorna só a message', () {
      const e = AppException('Proibido', statusCode: 403);
      expect(e.toString(), 'Proibido');
    });
  });
}
