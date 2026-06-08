import 'package:gymconnect/app/modules/treinos/models/cronograma_exercicio.dart';

/// Plano de treino vinculado a um aluno, conforme `GET /cronograma/{idAluno}`.
///
/// A resposta traz a lista `exercicio[]` aninhada (`@JsonManagedReference`),
/// cada item já recebe o `idCronograma` deste cronograma.
class Cronograma {
  final int idCronograma;
  final int? diasTotais;
  final List<CronogramaExercicio> exercicios;

  const Cronograma({
    required this.idCronograma,
    this.diasTotais,
    this.exercicios = const [],
  });

  factory Cronograma.fromJson(Map<String, dynamic> json) {
    final id = (json['idCronograma'] as num).toInt();
    final rawExercicios = json['exercicio'] as List<dynamic>? ?? const [];
    return Cronograma(
      idCronograma: id,
      diasTotais: (json['diasTotais'] as num?)?.toInt(),
      exercicios: rawExercicios
          .whereType<Map<String, dynamic>>()
          .map((e) => CronogramaExercicio.fromJson(e, idCronograma: id))
          .toList(),
    );
  }

  /// Serializa para o cache local (formato compatível com [fromJson]).
  Map<String, dynamic> toJson() => {
        'idCronograma': idCronograma,
        'diasTotais': diasTotais,
        'exercicio': exercicios.map((e) => e.toJson()).toList(),
      };
}
