import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';

/// Estado do chat com o coach IA.
class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository;
  ChatProvider(this._repository);

  final List<ChatMessage> _mensagens = [];
  bool _enviando = false;

  List<ChatMessage> get mensagens => List.unmodifiable(_mensagens);
  bool get enviando => _enviando;
  bool get vazio => _mensagens.isEmpty;

  Future<void> enviar(String texto) async {
    final mensagem = texto.trim();
    if (mensagem.isEmpty || _enviando) return;

    _mensagens.add(ChatMessage.usuario(mensagem));
    _enviando = true;
    notifyListeners();

    try {
      final resposta = await _repository.enviar(mensagem);
      _mensagens.add(ChatMessage.ia(resposta));
    } on AppException catch (e) {
      _mensagens.add(ChatMessage.ia(e.message, erro: true));
    } catch (e) {
      _mensagens.add(ChatMessage.ia(e.toString(), erro: true));
    } finally {
      _enviando = false;
      notifyListeners();
    }
  }

  void limpar() {
    _mensagens.clear();
    notifyListeners();
  }
}
