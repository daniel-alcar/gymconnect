import 'package:gymconnect/app/modules/auth/models/login_response.dart';
import 'package:gymconnect/app/modules/auth/models/tipo_usuario.dart';
import 'package:gymconnect/app/modules/auth/models/usuario.dart';
import 'package:gymconnect/app/core/client/dio_client.dart';

/// Service de autenticação — consome `/auth/*`.
class AuthService {
  final DioClient _client;
  AuthService(this._client);

  /// `POST /auth/login` → `{ token }`.
  Future<LoginResponse> login(String email, String senha) async {
    try {
      final res = await _client.dio.post(
        '/auth/login',
        data: {'email': email, 'senha': senha},
      );
      if (_client.isSucesso(res)) {
        return LoginResponse.fromJson(res.data as Map<String, dynamic>);
      }
      // Login inválido tipicamente retorna 401/403.
      throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }

  /// `POST /auth/cadastrar` (público). 200 vazio em sucesso; 400 e-mail já existe.
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required TipoUsuario tipo,
  }) async {
    try {
      final res = await _client.dio.post(
        '/auth/cadastrar',
        data: {
          'nome': nome,
          'email': email,
          'senha': senha,
          'tipo': tipo.value,
        },
      );
      if (!_client.isSucesso(res)) {
        // 400 sem corpo geralmente significa e-mail já cadastrado.
        final base = _client.tratarResposta(res);
        throw base.statusCode == 400 && base.message.startsWith('Requisição')
            ? base.copyWith('E-mail já cadastrado.')
            : base;
      }
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }

  /// `GET /auth/me` → usuário logado.
  Future<Usuario> getCurrentUser() async {
    try {
      final res = await _client.dio.get('/auth/me');
      if (_client.isSucesso(res)) {
        return Usuario.fromJson(res.data as Map<String, dynamic>);
      }
      throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }
}
