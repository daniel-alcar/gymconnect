/// Validadores reutilizáveis para os formulários.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final RegExp _letraRegex = RegExp(r'[a-zA-Z]');
  static final RegExp _numeroRegex = RegExp(r'\d');

  static String? obrigatorio(String? value, {String campo = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$campo é obrigatório';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail é obrigatório';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Informe um e-mail válido';
    }
    return null;
  }

  static String? senha(String? value) {
    if (value == null || value.isEmpty) return 'Senha é obrigatória';
    if (value.length < 8) return 'A senha deve ter ao menos 8 caracteres';
    if (!_letraRegex.hasMatch(value)) return 'A senha deve conter ao menos uma letra';
    if (!_numeroRegex.hasMatch(value)) return 'A senha deve conter ao menos um número';
    return null;
  }

  static String? confirmarSenha(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirme a senha';
    if (value != original) return 'As senhas não conferem';
    return null;
  }

  /// Altura obrigatória: número entre 0 e 2,20 m.
  static String? altura(String? value) {
    if (value == null || value.trim().isEmpty) return 'Altura é obrigatória';
    final v = double.tryParse(value.replaceAll(',', '.'));
    if (v == null || v <= 0) return 'Altura inválida (ex.: 1,75)';
    if (v > 2.20) return 'Altura deve ser menor que 2,20 m';
    return null;
  }

  /// Peso opcional, mas se preenchido deve ser número > 0.
  static String? pesoOpcional(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final v = double.tryParse(value.replaceAll(',', '.'));
    if (v == null || v <= 0) return 'Peso inválido (ex.: 72.5)';
    return null;
  }
}
