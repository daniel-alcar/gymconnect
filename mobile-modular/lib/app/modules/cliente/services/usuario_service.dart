import 'package:gymconnect/app/modules/auth/models/tipo_usuario.dart';
import 'package:gymconnect/app/modules/auth/models/usuario.dart';
import 'package:gymconnect/app/core/client/dio_client.dart';

/// Service de usuários — exclusivo do perfil CLIENTE (`/usuarios`).
class UsuarioService {
  final DioClient _client;
  UsuarioService(this._client);

  /// `GET /usuarios` → todos os usuários (CLIENTE). Filtramos os ALUNOS.
  Future<List<Usuario>> listar() async {
    try {
      final res = await _client.dio.get('/usuarios');
      if (_client.isSucesso(res)) {
        final data = res.data;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(Usuario.fromJson)
              .toList();
        }
        return const [];
      }
      throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }

  Future<List<Usuario>> listarAlunos() async {
    final todos = await listar();
    return todos.where((u) => u.tipo == TipoUsuario.aluno).toList();
  }

  /// `DELETE /usuarios/{id}`.
  Future<void> remover(int idUsuario) async {
    try {
      final res = await _client.dio.delete('/usuarios/$idUsuario');
      if (!_client.isSucesso(res)) throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }
}
