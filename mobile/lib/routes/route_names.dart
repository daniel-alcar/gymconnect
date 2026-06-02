/// Nomes e caminhos das rotas do app.
class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String inicial = '/inicio';
  static const String login = '/login';
  static const String cadastro = '/cadastro';

  /// Casca principal com a navigation bar (Dashboard/Treinos/Perfil/Chat).
  static const String app = '/app';

  /// Rotas acessíveis sem autenticação.
  static const Set<String> publicas = {splash, inicial, login, cadastro};
}
