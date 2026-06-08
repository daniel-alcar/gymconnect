import 'package:gymconnect/app/modules/auth/models/tipo_usuario.dart';
import 'package:gymconnect/app/modules/auth/models/usuario.dart';

/// Sessão do usuário logado persistida localmente (SQLite) para login offline.
///
/// `isSync = 1` quando a sessão foi validada com o backend; `0` quando ainda
/// está pendente de revalidação (ex.: aberta offline).
class SessionModel {
  final int idUsuario;
  final String nome;
  final String email;
  final String tipo; // valor do backend (TipoUsuario.value)
  final String token;
  final bool isSync;
  final DateTime createdAt;

  const SessionModel({
    required this.idUsuario,
    required this.nome,
    required this.email,
    required this.tipo,
    required this.token,
    this.isSync = true,
    required this.createdAt,
  });

  /// Cria a sessão a partir do usuário autenticado + token.
  factory SessionModel.fromUsuario(
    Usuario usuario, {
    required String token,
    bool isSync = true,
  }) {
    return SessionModel(
      idUsuario: usuario.idUsuario,
      nome: usuario.nome,
      email: usuario.email,
      tipo: usuario.tipo.value,
      token: token,
      isSync: isSync,
      createdAt: DateTime.now(),
    );
  }

  /// Reconstrói o [Usuario] de domínio a partir da sessão local.
  Usuario toUsuario() => Usuario(
        idUsuario: idUsuario,
        nome: nome,
        email: email,
        tipo: TipoUsuario.fromString(tipo),
      );

  Map<String, dynamic> toMap() => {
        'id_usuario': idUsuario,
        'nome': nome,
        'email': email,
        'tipo': tipo,
        'token': token,
        'is_sync': isSync ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
      };

  factory SessionModel.fromMap(Map<String, dynamic> map) => SessionModel(
        idUsuario: (map['id_usuario'] as num).toInt(),
        nome: map['nome'] as String,
        email: map['email'] as String,
        tipo: map['tipo'] as String,
        token: map['token'] as String,
        isSync: (map['is_sync'] as num?)?.toInt() == 1,
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
}
