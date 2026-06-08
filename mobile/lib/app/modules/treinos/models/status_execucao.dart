/// Status de execução de um treino, espelhando o enum `StatusExecucao`.
enum StatusExecucao {
  feito('FEITO'),
  naoFeito('NAO_FEITO');

  final String value;
  const StatusExecucao(this.value);

  static StatusExecucao fromString(String? raw) {
    return StatusExecucao.values.firstWhere(
      (s) => s.value == raw,
      orElse: () => StatusExecucao.naoFeito,
    );
  }

  bool get concluido => this == StatusExecucao.feito;
}
