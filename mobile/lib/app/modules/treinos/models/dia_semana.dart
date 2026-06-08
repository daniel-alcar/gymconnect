/// Dias da semana, espelhando o enum `DiaSemana` do backend.
enum DiaSemana {
  segunda('Segunda'),
  terca('Terca'),
  quarta('Quarta'),
  quinta('Quinta'),
  sexta('Sexta'),
  sabado('Sabado'),
  domingo('Domingo');

  final String value;
  const DiaSemana(this.value);

  static DiaSemana? fromString(String? raw) {
    if (raw == null) return null;
    for (final d in DiaSemana.values) {
      if (d.value == raw) return d;
    }
    return null;
  }

  /// Rótulo amigável (com acentuação) para exibição.
  String get label {
    switch (this) {
      case DiaSemana.terca:
        return 'Terça-feira';
      case DiaSemana.sabado:
        return 'Sábado';
      case DiaSemana.domingo:
        return 'Domingo';
      default:
        return '$value-feira';
    }
  }

  /// Ordem para ordenação semanal.
  int get ordem => index;
}
