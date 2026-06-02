import '../models/tipo_usuario.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

/// Orquestra o fluxo de autenticação: login → token → /auth/me → persistência.
class AuthRepository {
  final AuthService _authService;
  final StorageService _storage;

  AuthRepository(this._authService, this._storage);

  /// Faz login, persiste o token, busca o usuário e o persiste.
  Future<Usuario> login(String email, String senha) async {
    final loginResponse = await _authService.login(email, senha);
    await _storage.salvarToken(loginResponse.token);

    final usuario = await _authService.getCurrentUser();
    await _storage.salvarUsuario(usuario);
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

  /// Revalida a sessão salva chamando `/auth/me`.
  Future<Usuario> revalidarSessao() async {
    final usuario = await _authService.getCurrentUser();
    await _storage.salvarUsuario(usuario);
    return usuario;
  }

  Future<Usuario?> usuarioSalvo() => _storage.lerUsuario();
  Future<String?> tokenSalvo() => _storage.lerToken();

  Future<void> logout() => _storage.limpar();
}
