/// Exceção de domínio da aplicação.
///
/// Padroniza as mensagens vindas do backend (`ResponseModel.mensagem`,
/// textos simples ou status HTTP) para exibição amigável na UI.
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  /// Indica falha de autenticação/autorização (dispara logout automático).
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  AppException copyWith(String message) =>
      AppException(message, statusCode: statusCode);

  @override
  String toString() => message;
}
