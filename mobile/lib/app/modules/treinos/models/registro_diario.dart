/// Registro diário de peso vinculado a uma execução, `POST /registrodiario/me`.
class RegistroDiario {
  final int? idRegistro;
  final int? idExecucao;
  final double? peso;

  const RegistroDiario({this.idRegistro, this.idExecucao, this.peso});

  factory RegistroDiario.fromJson(Map<String, dynamic> json) {
    final execucao = json['execucao'] as Map<String, dynamic>?;
    return RegistroDiario(
      idRegistro: (json['idRegistro'] as num?)?.toInt(),
      idExecucao: (execucao?['idExecucao'] as num?)?.toInt(),
      peso: (json['peso'] as num?)?.toDouble(),
    );
  }

  /// Corpo para `POST /registrodiario/me`.
  static Map<String, dynamic> toCreateJson({
    required int idExecucao,
    double? peso,
  }) =>
      {
        'execucao': {'idExecucao': idExecucao},
        'peso': peso,
      };
}
