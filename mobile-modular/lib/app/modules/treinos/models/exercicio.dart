/// Exercício da biblioteca, conforme `GET /exercicios`.
class Exercicio {
  final int? idExercicio;
  final String nome;
  final String? linkYoutube;

  const Exercicio({
    this.idExercicio,
    required this.nome,
    this.linkYoutube,
  });

  factory Exercicio.fromJson(Map<String, dynamic> json) {
    return Exercicio(
      idExercicio: (json['idExercicio'] as num?)?.toInt(),
      nome: json['nome'] as String? ?? 'Exercício sem nome',
      linkYoutube: json['linkYoutube'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (idExercicio != null) 'idExercicio': idExercicio,
        'nome': nome,
        'linkYoutube': linkYoutube,
      };

  bool get temVideo => linkYoutube != null && linkYoutube!.trim().isNotEmpty;
}
