import 'package:gymconnect/app/modules/perfil/models/perfil.dart';
import 'package:gymconnect/app/core/client/dio_client.dart';

/// Service de perfil do aluno — `POST /perfil/me`.
class PerfilService {
  final DioClient _client;
  PerfilService(this._client);

  Future<Perfil> salvar(Perfil perfil) async {
    try {
      final res = await _client.dio.post(
        '/perfil/me',
        data: perfil.toCreateJson(),
      );
      if (_client.isSucesso(res)) {
        return Perfil.fromJson(res.data as Map<String, dynamic>);
      }
      throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }
}
