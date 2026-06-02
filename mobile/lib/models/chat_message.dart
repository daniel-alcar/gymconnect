/// Mensagem do chat com o coach IA (local — o backend não persiste histórico).
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
}
