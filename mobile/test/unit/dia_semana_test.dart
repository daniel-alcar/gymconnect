import 'package:flutter_test/flutter_test.dart';
import 'package:gymconnect/app/modules/treinos/models/dia_semana.dart';

void main() {
  group('DiaSemana.fromString', () {
    test('reconhece todos os 7 dias pelo value do backend', () {
      expect(DiaSemana.fromString('Segunda'), DiaSemana.segunda);
      expect(DiaSemana.fromString('Terca'), DiaSemana.terca);
      expect(DiaSemana.fromString('Quarta'), DiaSemana.quarta);
      expect(DiaSemana.fromString('Quinta'), DiaSemana.quinta);
      expect(DiaSemana.fromString('Sexta'), DiaSemana.sexta);
      expect(DiaSemana.fromString('Sabado'), DiaSemana.sabado);
      expect(DiaSemana.fromString('Domingo'), DiaSemana.domingo);
    });

    test('é case-sensitive (backend envia capitalizado)', () {
      expect(DiaSemana.fromString('SEGUNDA'), isNull);
      expect(DiaSemana.fromString('segunda'), isNull);
    });

    test('string desconhecida retorna null', () {
      expect(DiaSemana.fromString('Monday'), isNull);
      expect(DiaSemana.fromString(''), isNull);
    });

    test('null retorna null', () {
      expect(DiaSemana.fromString(null), isNull);
    });
  });

  group('DiaSemana.label', () {
    test('Terça com acento correto', () {
      expect(DiaSemana.terca.label, 'Terça-feira');
    });

    test('Sábado com acento correto', () {
      expect(DiaSemana.sabado.label, 'Sábado');
    });

    test('Domingo sem sufixo -feira', () {
      expect(DiaSemana.domingo.label, 'Domingo');
    });

    test('demais dias recebem sufixo -feira', () {
      expect(DiaSemana.segunda.label, 'Segunda-feira');
      expect(DiaSemana.quarta.label, 'Quarta-feira');
      expect(DiaSemana.quinta.label, 'Quinta-feira');
      expect(DiaSemana.sexta.label, 'Sexta-feira');
    });
  });

  group('DiaSemana.ordem', () {
    test('segunda é 0, domingo é 6', () {
      expect(DiaSemana.segunda.ordem, 0);
      expect(DiaSemana.domingo.ordem, 6);
    });

    test('ordem cresce da segunda ao domingo', () {
      final ordens = DiaSemana.values.map((d) => d.ordem).toList();
      for (int i = 0; i < ordens.length - 1; i++) {
        expect(ordens[i], lessThan(ordens[i + 1]));
      }
    });

    test('ordenar lista desordenada produz semana correta', () {
      final dias = [DiaSemana.domingo, DiaSemana.segunda, DiaSemana.sexta, DiaSemana.terca];
      dias.sort((a, b) => a.ordem.compareTo(b.ordem));

      expect(dias, [DiaSemana.segunda, DiaSemana.terca, DiaSemana.sexta, DiaSemana.domingo]);
    });
  });

  group('DiaSemana.value', () {
    test('value corresponde ao string esperado pelo backend', () {
      expect(DiaSemana.segunda.value, 'Segunda');
      expect(DiaSemana.terca.value, 'Terca');
      expect(DiaSemana.sabado.value, 'Sabado');
    });

    test('fromString(d.value) é identidade para todos os dias', () {
      for (final d in DiaSemana.values) {
        expect(DiaSemana.fromString(d.value), d);
      }
    });
  });
}
