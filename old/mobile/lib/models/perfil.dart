/// Perfil do aluno, conforme `POST /perfil/me`.
///
/// O backend só expõe criação (POST). Os campos são todos opcionais na UI,
/// mas a regra de negócio do backend exige os três no cadastro.
class Perfil {
  final int? idPerfil;
  final String? dataNascimento; // ISO YYYY-MM-DD
  final double? altura;
  final String? objetivo;

  const Perfil({
    this.idPerfil,
    this.dataNascimento,
    this.altura,
    this.objetivo,
  });

  factory Perfil.fromJson(Map<String, dynamic> json) {
    return Perfil(
      idPerfil: (json['idPerfil'] as num?)?.toInt(),
      dataNascimento: json['dataNascimento'] as String?,
      altura: (json['altura'] as num?)?.toDouble(),
      objetivo: json['objetivo'] as String?,
    );
  }

  /// Corpo para `POST /perfil/me` (não envia `usuario` nem `idPerfil`).
  Map<String, dynamic> toCreateJson() => {
        'dataNascimento': dataNascimento,
        'altura': altura,
        'objetivo': objetivo,
      };
}
