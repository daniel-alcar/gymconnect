/// Mensagem do chat com o coach IA — persistida localmente por usuário.
class ChatMessage {
  final String texto;
  final bool doUsuario; // true = usuário, false = IA
  final DateTime horario;
  final bool erro;

  ChatMessage({
    required this.texto,
    required this.doUsuario,
    DateTime? horario,
    this.erro = false,
  }) : horario = horario ?? DateTime.now();

  factory ChatMessage.usuario(String texto) =>
      ChatMessage(texto: texto, doUsuario: true);

  factory ChatMessage.ia(String texto, {bool erro = false}) =>
      ChatMessage(texto: texto, doUsuario: false, erro: erro);

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        texto: json['texto'] as String,
        doUsuario: json['doUsuario'] as bool,
        horario: DateTime.parse(json['horario'] as String),
        erro: json['erro'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'texto': texto,
        'doUsuario': doUsuario,
        'horario': horario.toIso8601String(),
        'erro': erro,
      };
}
