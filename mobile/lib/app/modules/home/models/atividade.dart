/// Tipo de atividade registrada no histórico do aluno.
enum AtividadeTipo {
  exercicio('exercicio'),
  treino('treino');

  final String value;
  const AtividadeTipo(this.value);

  static AtividadeTipo fromString(String? raw) =>
      AtividadeTipo.values.firstWhere(
        (t) => t.value == raw,
        orElse: () => AtividadeTipo.exercicio,
      );
}

/// Uma entrada de "Atividade Recente" (histórico local do usuário).
class Atividade {
  final String titulo;
  final String? subtitulo;
  final DateTime data;
  final AtividadeTipo tipo;

  Atividade({
    required this.titulo,
    this.subtitulo,
    required this.tipo,
    DateTime? data,
  }) : data = data ?? DateTime.now();

  factory Atividade.exercicio(String nome) => Atividade(
        tipo: AtividadeTipo.exercicio,
        titulo: nome,
        subtitulo: 'Exercício concluído',
      );

  factory Atividade.treino(String dia) => Atividade(
        tipo: AtividadeTipo.treino,
        titulo: 'Treino concluído',
        subtitulo: dia,
      );

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'subtitulo': subtitulo,
        'data': data.toIso8601String(),
        'tipo': tipo.value,
      };

  factory Atividade.fromJson(Map<String, dynamic> json) => Atividade(
        titulo: json['titulo'] as String? ?? '',
        subtitulo: json['subtitulo'] as String?,
        data: DateTime.tryParse(json['data'] as String? ?? '') ?? DateTime.now(),
        tipo: AtividadeTipo.fromString(json['tipo'] as String?),
      );
}
