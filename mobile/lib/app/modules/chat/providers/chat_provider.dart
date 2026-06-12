import 'package:flutter/foundation.dart';

import 'package:gymconnect/app/core/errors/app_exception.dart';
import 'package:gymconnect/app/core/storage/storage_service.dart';
import 'package:gymconnect/app/modules/chat/models/chat_message.dart';
import 'package:gymconnect/app/modules/chat/repositories/chat_repository.dart';

/// Estado do chat com o coach IA.
/// O histórico é persistido localmente por usuário (SharedPreferences).
class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository;
  final StorageService _storage;

  ChatProvider(this._repository, this._storage);

  final List<ChatMessage> _mensagens = [];
  bool _enviando = false;
  int? _idUsuarioAtual;

  List<ChatMessage> get mensagens => List.unmodifiable(_mensagens);
  bool get enviando => _enviando;
  bool get vazio => _mensagens.isEmpty;

  /// Carrega o histórico do usuário ao fazer login. Idempotente para o mesmo usuário.
  Future<void> inicializar(int idUsuario) async {
    if (_idUsuarioAtual == idUsuario) return;
    _idUsuarioAtual = idUsuario;
    final historico = await _storage.lerHistoricoChat(idUsuario);
    _mensagens
      ..clear()
      ..addAll(historico);
    notifyListeners();
  }

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
      if (_idUsuarioAtual != null) {
        await _storage.salvarHistoricoChat(_idUsuarioAtual!, _mensagens);
      }
    }
  }

  void limpar() {
    _mensagens.clear();
    _idUsuarioAtual = null;
    notifyListeners();
  }
}
