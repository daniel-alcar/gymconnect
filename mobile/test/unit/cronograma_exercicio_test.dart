import 'package:flutter_test/flutter_test.dart';
import 'package:gymconnect/app/modules/treinos/models/cronograma_exercicio.dart';
import 'package:gymconnect/app/modules/treinos/models/dia_semana.dart';

void main() {
  group('CronogramaExercicio.fromJson', () {
    test('desserializa todos os campos', () {
      final ex = CronogramaExercicio.fromJson(
        {
          'idCronogramaExercicio': 10,
          'exercicio': {'nome': 'Supino', 'idExercicio': 1},
          'diaSemana': 'Segunda',
          'serie': 3,
          'repeticao': 12,
          'carga': 80,
        },
        idCronograma: 42,
      );

      expect(ex.idCronogramaExercicio, 10);
      expect(ex.exercicio?.nome, 'Supino');
      expect(ex.diaSemana, DiaSemana.segunda);
      expect(ex.serie, 3);
      expect(ex.repeticao, 12);
      expect(ex.carga, 80);
      expect(ex.idCronograma, 42);
    });

    test('aceita exercicio null', () {
      final ex = CronogramaExercicio.fromJson({'diaSemana': 'Terca'});
      expect(ex.exercicio, isNull);
      expect(ex.diaSemana, DiaSemana.terca);
    });

    test('diaSemana desconhecido resulta em null', () {
      final ex = CronogramaExercicio.fromJson({'diaSemana': 'INVALIDO'});
      expect(ex.diaSemana, isNull);
    });

    test('diaSemana null resulta em null', () {
      final ex = CronogramaExercicio.fromJson({'diaSemana': null});
      expect(ex.diaSemana, isNull);
    });

    test('números como double são convertidos para int', () {
      final ex = CronogramaExercicio.fromJson({
        'idCronogramaExercicio': 5.0,
        'serie': 3.0,
        'repeticao': 10.0,
        'carga': 60.0,
      });
      expect(ex.idCronogramaExercicio, 5);
      expect(ex.serie, 3);
      expect(ex.repeticao, 10);
      expect(ex.carga, 60);
    });
  });

  group('CronogramaExercicio.toJson', () {
    test('omite idCronogramaExercicio quando null', () {
      final ex = CronogramaExercicio.fromJson({'diaSemana': 'Sexta', 'serie': 4});
      expect(ex.toJson().containsKey('idCronogramaExercicio'), isFalse);
    });

    test('serializa diaSemana como valor string do enum', () {
      final ex = CronogramaExercicio.fromJson({'diaSemana': 'Quarta'});
      expect(ex.toJson()['diaSemana'], 'Quarta');
    });

    test('diaSemana null serializa como null', () {
      final ex = CronogramaExercicio.fromJson({'diaSemana': null});
      expect(ex.toJson()['diaSemana'], isNull);
    });

    test('roundtrip fromJson → toJson → fromJson preserva campos', () {
      final original = CronogramaExercicio.fromJson(
        {
          'idCronogramaExercicio': 7,
          'exercicio': {'nome': 'Rosca', 'idExercicio': 3},
          'diaSemana': 'Quinta',
          'serie': 4,
          'repeticao': 8,
          'carga': 15,
        },
        idCronograma: 1,
      );
      final restaurado = CronogramaExercicio.fromJson(original.toJson());

      expect(restaurado.idCronogramaExercicio, 7);
      expect(restaurado.exercicio?.nome, 'Rosca');
      expect(restaurado.diaSemana, DiaSemana.quinta);
      expect(restaurado.serie, 4);
      expect(restaurado.repeticao, 8);
      expect(restaurado.carga, 15);
    });
  });

  group('CronogramaExercicio.copyWith', () {
    test('substitui idCronograma', () {
      final original = CronogramaExercicio.fromJson(
        {'diaSemana': 'Segunda'},
        idCronograma: 1,
      );
      final copy = original.copyWith(idCronograma: 99);

      expect(copy.idCronograma, 99);
      expect(copy.diaSemana, original.diaSemana);
    });

    test('mantém idCronograma quando não passado', () {
      final original = CronogramaExercicio.fromJson(
        {'diaSemana': 'Segunda'},
        idCronograma: 7,
      );
      final copy = original.copyWith();

      expect(copy.idCronograma, 7);
    });

    test('todos os outros campos são preservados', () {
      final original = CronogramaExercicio.fromJson(
        {
          'idCronogramaExercicio': 3,
          'exercicio': {'nome': 'Agachamento'},
          'diaSemana': 'Sexta',
          'serie': 5,
          'repeticao': 10,
          'carga': 100,
        },
        idCronograma: 1,
      );
      final copy = original.copyWith(idCronograma: 2);

      expect(copy.idCronogramaExercicio, 3);
      expect(copy.exercicio?.nome, 'Agachamento');
      expect(copy.serie, 5);
      expect(copy.carga, 100);
    });
  });
}
