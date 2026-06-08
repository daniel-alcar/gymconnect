import 'package:gymconnect/app/modules/treinos/models/dia_semana.dart';
import 'package:gymconnect/app/modules/treinos/models/exercicio.dart';

/// Vínculo entre um exercício e um dia/série do cronograma.
///
/// Conforme `GET /cronogramaexercicio/aluno/{id}` ou aninhado em `Cronograma`.
/// O campo `cronograma` não vem na resposta (`@JsonBackReference`); por isso
/// guardamos o `idCronograma` resolvido a partir do cronograma pai.
class CronogramaExercicio {
  final int? idCronogramaExercicio;
  final Exercicio? exercicio;
  final DiaSemana? diaSemana;
  final int? serie;
  final int? repeticao;
  final int? carga;

  /// Resolvido a partir do `Cronograma` que contém este exercício.
  final int? idCronograma;

  const CronogramaExercicio({
    this.idCronogramaExercicio,
    this.exercicio,
    this.diaSemana,
    this.serie,
    this.repeticao,
    this.carga,
    this.idCronograma,
  });

  factory CronogramaExercicio.fromJson(
    Map<String, dynamic> json, {
    int? idCronograma,
  }) {
    return CronogramaExercicio(
      idCronogramaExercicio:
          (json['idCronogramaExercicio'] as num?)?.toInt(),
      exercicio: json['exercicio'] != null
          ? Exercicio.fromJson(json['exercicio'] as Map<String, dynamic>)
          : null,
      diaSemana: DiaSemana.fromString(json['diaSemana'] as String?),
      serie: (json['serie'] as num?)?.toInt(),
      repeticao: (json['repeticao'] as num?)?.toInt(),
      carga: (json['carga'] as num?)?.toInt(),
      idCronograma: idCronograma,
    );
  }

  /// Serializa para o cache local (formato compatível com [fromJson]).
  Map<String, dynamic> toJson() => {
        if (idCronogramaExercicio != null)
          'idCronogramaExercicio': idCronogramaExercicio,
        if (exercicio != null) 'exercicio': exercicio!.toJson(),
        'diaSemana': diaSemana?.value,
        'serie': serie,
        'repeticao': repeticao,
        'carga': carga,
      };

  CronogramaExercicio copyWith({int? idCronograma}) {
    return CronogramaExercicio(
      idCronogramaExercicio: idCronogramaExercicio,
      exercicio: exercicio,
      diaSemana: diaSemana,
      serie: serie,
      repeticao: repeticao,
      carga: carga,
      idCronograma: idCronograma ?? this.idCronograma,
    );
  }
}
