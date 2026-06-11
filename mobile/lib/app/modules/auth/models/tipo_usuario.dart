/// Perfil (role) do usuário, espelhando o enum `TipoUsuario` do backend.
enum TipoUsuario {
  cliente('CLIENTE'),
  aluno('ALUNO');

  final String value;
  const TipoUsuario(this.value);

  static TipoUsuario fromString(String? raw) {
    return TipoUsuario.values.firstWhere(
      (t) => t.value == raw,
      orElse: () => TipoUsuario.aluno,
    );
  }

  String get label => this == TipoUsuario.cliente ? 'Professor' : 'Aluno';
}
