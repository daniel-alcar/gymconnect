/// Exercício da biblioteca, conforme `GET /exercicios`.
class Exercicio {
  final int? idExercicio;
  final String nome;
  final String? linkYoutube;
  final String? descricao;

  const Exercicio({
    this.idExercicio,
    required this.nome,
    this.linkYoutube,
    this.descricao,
  });

  factory Exercicio.fromJson(Map<String, dynamic> json) {
    return Exercicio(
      idExercicio: (json['idExercicio'] as num?)?.toInt(),
      nome: json['nome'] as String? ?? 'Exercício sem nome',
      linkYoutube: json['linkYoutube'] as String?,
      descricao: json['descricao'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (idExercicio != null) 'idExercicio': idExercicio,
        'nome': nome,
        'linkYoutube': linkYoutube,
        'descricao': descricao,
      };

  bool get temVideo => linkYoutube != null && linkYoutube!.trim().isNotEmpty;
  bool get temDescricao => descricao != null && descricao!.trim().isNotEmpty;
}
