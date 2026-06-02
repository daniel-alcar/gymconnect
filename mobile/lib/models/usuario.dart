import 'tipo_usuario.dart';

/// Usuário autenticado, conforme retornado por `GET /auth/me`.
class Usuario {
  final int idUsuario;
  final String nome;
  final String email;
  final TipoUsuario tipo;

  const Usuario({
    required this.idUsuario,
    required this.nome,
    required this.email,
    required this.tipo,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: (json['idUsuario'] as num).toInt(),
      nome: json['nome'] as String? ?? '',
      email: json['email'] as String? ?? '',
      tipo: TipoUsuario.fromString(json['tipo'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'idUsuario': idUsuario,
        'nome': nome,
        'email': email,
        'tipo': tipo.value,
      };

  bool get isCliente => tipo == TipoUsuario.cliente;
  bool get isAluno => tipo == TipoUsuario.aluno;
}
