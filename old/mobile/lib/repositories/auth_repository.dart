import '../models/session_model.dart';
import '../models/tipo_usuario.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'session_local_repository.dart';

/// Orquestra o fluxo de autenticação: login → token → /auth/me → persistência.
class AuthRepository {
  final AuthService _authService;
  final StorageService _storage;
  final SessionLocalRepository _sessionLocal;

  AuthRepository(this._authService, this._storage, this._sessionLocal);

  /// Faz login, persiste o token, busca o usuário e o persiste (storage + SQLite).
  Future<Usuario> login(String email, String senha) async {
    final loginResponse = await _authService.login(email, senha);
    await _storage.salvarToken(loginResponse.token);

    final usuario = await _authService.getCurrentUser();
    await _storage.salvarUsuario(usuario);
    // Cache local da sessão é best-effort: nunca deve bloquear o login.
    try {
      await _sessionLocal.saveSession(
        SessionModel.fromUsuario(usuario, token: loginResponse.token),
      );
    } catch (_) {/* segue logado mesmo se o cache local falhar */}
    return usuario;
  }

  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required TipoUsuario tipo,
  }) {
    return _authService.cadastrar(
      nome: nome,
      email: email,
      senha: senha,
      tipo: tipo,
    );
  }

  /// Revalida a sessão salva chamando `/auth/me` e atualiza os caches.
  Future<Usuario> revalidarSessao() async {
    final usuario = await _authService.getCurrentUser();
    await _storage.salvarUsuario(usuario);
    final token = await _storage.lerToken();
    if (token != null && token.isNotEmpty) {
      try {
        await _sessionLocal.saveSession(
          SessionModel.fromUsuario(usuario, token: token),
        );
      } catch (_) {/* best-effort */}
    }
    return usuario;
  }

  Future<Usuario?> usuarioSalvo() => _storage.lerUsuario();
  Future<String?> tokenSalvo() => _storage.lerToken();

  /// Sessão local (SQLite) para login offline.
  Future<SessionModel?> sessaoLocal() => _sessionLocal.getSession();

  Future<void> logout() async {
    await _storage.limpar();
    await _sessionLocal.clearSession();
  }
}
