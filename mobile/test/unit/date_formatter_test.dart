import 'package:flutter_test/flutter_test.dart';
import 'package:gymconnect/app/shared/utils/date_formatter.dart';

void main() {
  group('DateFormatter.toIso', () {
    test('formata data no padrão ISO yyyy-MM-dd', () {
      expect(DateFormatter.toIso(DateTime(2000, 6, 15)), '2000-06-15');
      expect(DateFormatter.toIso(DateTime(1990, 1, 1)), '1990-01-01');
    });
  });

  group('DateFormatter.toBr', () {
    test('formata data no padrão brasileiro dd/MM/yyyy', () {
      expect(DateFormatter.toBr(DateTime(2000, 6, 15)), '15/06/2000');
      expect(DateFormatter.toBr(DateTime(1990, 1, 1)), '01/01/1990');
    });
  });

  group('DateFormatter.isoToBr', () {
    test('converte string ISO para formato brasileiro', () {
      expect(DateFormatter.isoToBr('2000-06-15'), '15/06/2000');
    });

    test('retorna null quando recebe null', () {
      expect(DateFormatter.isoToBr(null), isNull);
    });

    test('retorna null quando recebe string vazia', () {
      expect(DateFormatter.isoToBr(''), isNull);
    });

    test('retorna string original quando não é uma data válida', () {
      expect(DateFormatter.isoToBr('nao-e-data'), 'nao-e-data');
    });
  });

  group('DateFormatter.relativo', () {
    test('retorna "Agora" para menos de 1 minuto', () {
      final agora = DateTime.now().subtract(const Duration(seconds: 30));
      expect(DateFormatter.relativo(agora), 'Agora');
    });

    test('retorna minutos para menos de 1 hora', () {
      final ha10min = DateTime.now().subtract(const Duration(minutes: 10));
      expect(DateFormatter.relativo(ha10min), 'Há 10 min');
    });

    test('retorna horas para menos de 24 horas', () {
      final ha2h = DateTime.now().subtract(const Duration(hours: 2));
      expect(DateFormatter.relativo(ha2h), 'Há 2h');
    });

    test('retorna "Ontem" para exatamente 1 dia atrás', () {
      final ontem = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFormatter.relativo(ontem), 'Ontem');
    });
  });
}
