import 'package:flutter_test/flutter_test.dart';
import 'package:gymconnect/app/modules/treinos/models/status_execucao.dart';

void main() {
  group('StatusExecucao.fromString', () {
    test('FEITO retorna feito', () {
      expect(StatusExecucao.fromString('FEITO'), StatusExecucao.feito);
    });

    test('NAO_FEITO retorna naoFeito', () {
      expect(StatusExecucao.fromString('NAO_FEITO'), StatusExecucao.naoFeito);
    });

    test('valor desconhecido retorna naoFeito (fallback seguro)', () {
      expect(StatusExecucao.fromString('PENDENTE'), StatusExecucao.naoFeito);
      expect(StatusExecucao.fromString('feito'), StatusExecucao.naoFeito);
      expect(StatusExecucao.fromString(''), StatusExecucao.naoFeito);
    });

    test('null retorna naoFeito', () {
      expect(StatusExecucao.fromString(null), StatusExecucao.naoFeito);
    });

    test('fromString(s.value) é identidade para todos os status', () {
      for (final s in StatusExecucao.values) {
        expect(StatusExecucao.fromString(s.value), s);
      }
    });
  });

  group('StatusExecucao.concluido', () {
    test('feito.concluido é true', () {
      expect(StatusExecucao.feito.concluido, isTrue);
    });

    test('naoFeito.concluido é false', () {
      expect(StatusExecucao.naoFeito.concluido, isFalse);
    });
  });
}
