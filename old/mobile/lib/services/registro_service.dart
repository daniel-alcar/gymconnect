import '../models/registro_diario.dart';
import 'dio_client.dart';

/// Service de registro diário de peso — `POST /registrodiario/me`.
class RegistroService {
  final DioClient _client;
  RegistroService(this._client);

  Future<RegistroDiario> registrarPeso({
    required int idExecucao,
    required double peso,
  }) async {
    try {
      final res = await _client.dio.post(
        '/registrodiario/me',
        data: RegistroDiario.toCreateJson(idExecucao: idExecucao, peso: peso),
      );
      if (_client.isSucesso(res)) {
        return RegistroDiario.fromJson(res.data as Map<String, dynamic>);
      }
      throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }
}
