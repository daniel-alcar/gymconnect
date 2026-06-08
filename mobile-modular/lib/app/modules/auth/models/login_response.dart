/// Resposta de `POST /auth/login`: `{ "token": "..." }`.
class LoginResponse {
  final String token;

  const LoginResponse({required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(token: json['token'] as String);
  }
}
