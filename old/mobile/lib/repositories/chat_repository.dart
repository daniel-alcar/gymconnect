import '../services/chat_service.dart';

/// Orquestra o envio de mensagens ao coach IA.
class ChatRepository {
  final ChatService _chatService;
  ChatRepository(this._chatService);

  Future<String> enviar(String mensagem) => _chatService.enviar(mensagem);
}
