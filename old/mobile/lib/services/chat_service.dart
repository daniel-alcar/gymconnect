import 'dio_client.dart';

/// Service do chat com o coach IA (Gemini via backend) — `POST /chat/coach`.
class ChatService {
  final DioClient _client;
  ChatService(this._client);

  /// Envia a mensagem e retorna o texto de `reply`.
  Future<String> enviar(String mensagem) async {
    try {
      final res = await _client.dio.post(
        '/chat/coach',
        data: {'message': mensagem},
      );
      if (_client.isSucesso(res)) {
        final data = res.data as Map<String, dynamic>;
        return data['reply'] as String? ?? '';
      }
      throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }
}
