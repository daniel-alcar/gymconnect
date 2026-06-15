import 'package:flutter_test/flutter_test.dart';
import 'package:gymconnect/app/modules/treinos/models/cronograma.dart';
import 'package:gymconnect/app/modules/treinos/models/dia_semana.dart';

void main() {
  group('Cronograma.fromJson', () {
    test('desserializa id e diasTotais', () {
      final c = Cronograma.fromJson({
        'idCronograma': 1,
        'diasTotais': 5,
        'exercicio': [],
      });
      expect(c.idCronograma, 1);
      expect(c.diasTotais, 5);
    });

    test('exercicio ausente resulta em lista vazia', () {
      final c = Cronograma.fromJson({'idCronograma': 1});
      expect(c.exercicios, isEmpty);
    });

    test('exercicio: null resulta em lista vazia', () {
      final c = Cronograma.fromJson({'idCronograma': 1, 'exercicio': null});
      expect(c.exercicios, isEmpty);
    });

    test('propaga idCronograma para todos os exercícios filhos', () {
      final c = Cronograma.fromJson({
        'idCronograma': 42,
        'exercicio': [
          {'diaSemana': 'Segunda', 'serie': 3, 'repeticao': 10},
          {'diaSemana': 'Terca', 'serie': 4, 'repeticao': 8},
          {'diaSemana': 'Quarta', 'serie': 2, 'repeticao': 15},
        ],
      });

      expect(c.exercicios.length, 3);
      for (final ex in c.exercicios) {
        expect(ex.idCronograma, 42);
      }
    });

    test('parse correto do diaSemana dos filhos', () {
      final c = Cronograma.fromJson({
        'idCronograma': 1,
        'exercicio': [
          {'diaSemana': 'Sabado'},
          {'diaSemana': 'Domingo'},
        ],
      });

      expect(c.exercicios[0].diaSemana, DiaSemana.sabado);
      expect(c.exercicios[1].diaSemana, DiaSemana.domingo);
    });

    test('ignora entradas não-Map no array de exercícios', () {
      final c = Cronograma.fromJson({
        'idCronograma': 1,
        'exercicio': [
          {'diaSemana': 'Segunda'},
          'invalido',
          42,
          null,
        ],
      });

      expect(c.exercicios.length, 1);
    });
  });

  group('Cronograma.toJson', () {
    test('roundtrip fromJson → toJson → fromJson preserva campos', () {
      final original = Cronograma.fromJson({
        'idCronograma': 7,
        'diasTotais': 3,
        'exercicio': [
          {'diaSemana': 'Sexta', 'serie': 3, 'repeticao': 12, 'carga': 60},
        ],
      });
      final restaurado = Cronograma.fromJson(original.toJson());

      expect(restaurado.idCronograma, 7);
      expect(restaurado.diasTotais, 3);
      expect(restaurado.exercicios.length, 1);
      // idCronograma é propagado corretamente no roundtrip
      expect(restaurado.exercicios.first.idCronograma, 7);
    });

    test('lista vazia de exercícios serializa como array vazio', () {
      final c = Cronograma.fromJson({'idCronograma': 1});
      expect(c.toJson()['exercicio'], isEmpty);
    });
  });
}
