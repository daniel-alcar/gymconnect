import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../models/tipo_usuario.dart';
import '../models/usuario.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { desconhecido, autenticado, naoAutenticado }

/// Estado global de autenticação. Equivalente ao `AuthContext` do React.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository);

  AuthStatus _status = AuthStatus.desconhecido;
  Usuario? _usuario;
  bool _carregando = false;

  AuthStatus get status => _status;
  Usuario? get usuario => _usuario;
  bool get carregando => _carregando;
  bool get autenticado => _status == AuthStatus.autenticado;
  bool get isCliente => _usuario?.isCliente ?? false;
  bool get isAluno => _usuario?.isAluno ?? false;

  /// Carrega a sessão salva ao abrir o app e revalida via `/auth/me`.
  Future<void> carregarSessao() async {
    final token = await _repository.tokenSalvo();
    final salvo = await _repository.usuarioSalvo();

    if (token == null || salvo == null) {
      _definirNaoAutenticado();
      return;
    }

    // Mostra o usuário salvo imediatamente e revalida em segundo plano.
    _usuario = salvo;
    _status = AuthStatus.autenticado;
    notifyListeners();

    try {
      _usuario = await _repository.revalidarSessao();
      _status = AuthStatus.autenticado;
    } on AppException catch (e) {
      // Offline-First: só desloga se o token for inválido/expirado (401/403).
      // Em falha de rede (sem statusCode), mantém a sessão salva e segue offline.
      if (e.isAuthError) {
        await _repository.logout();
        _definirNaoAutenticado();
        return;
      }
      // Mantém autenticado com os dados locais (modo offline).
    }
    notifyListeners();
  }

  Future<void> login(String email, String senha) async {
    _setCarregando(true);
    try {
      _usuario = await _repository.login(email.trim(), senha);
      _status = AuthStatus.autenticado;
    } finally {
      _setCarregando(false);
    }
  }

  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required TipoUsuario tipo,
  }) async {
    _setCarregando(true);
    try {
      await _repository.cadastrar(
        nome: nome.trim(),
        email: email.trim(),
        senha: senha,
        tipo: tipo,
      );
      // Após cadastrar, autentica automaticamente (igual ao fluxo React).
      _usuario = await _repository.login(email.trim(), senha);
      _status = AuthStatus.autenticado;
    } finally {
      _setCarregando(false);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _definirNaoAutenticado();
  }

  /// Chamado pelo interceptor do Dio em 401/403 (logout automático).
  void sessaoExpirada() {
    _repository.logout();
    _definirNaoAutenticado();
  }

  void _definirNaoAutenticado() {
    _usuario = null;
    _status = AuthStatus.naoAutenticado;
    notifyListeners();
  }

  void _setCarregando(bool v) {
    _carregando = v;
    notifyListeners();
  }
}
