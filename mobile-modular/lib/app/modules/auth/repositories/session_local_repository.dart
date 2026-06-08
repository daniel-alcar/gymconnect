import 'package:gymconnect/app/core/database/db_helper.dart';
import 'package:gymconnect/app/modules/auth/models/session_model.dart';

/// Repository (R) da sessão local em SQLite.
///
/// Mantém no máximo uma sessão (a do último login). Usado para login offline:
/// se o backend estiver inacessível, o app reaproveita a sessão salva.
class SessionLocalRepository {
  final DbHelper _dbHelper;
  SessionLocalRepository([DbHelper? dbHelper])
      : _dbHelper = dbHelper ?? DbHelper.instance;

  static const String _table = 'session';

  /// Salva a sessão (substitui a anterior — só uma sessão ativa por vez).
  Future<void> saveSession(SessionModel session) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete(_table);
      await txn.insert(_table, session.toMap());
    });
  }

  /// Retorna a sessão salva mais recente, ou `null` se não houver.
  Future<SessionModel?> getSession() async {
    final db = await _dbHelper.database;
    final linhas = await db.query(
      _table,
      orderBy: 'id DESC',
      limit: 1,
    );
    if (linhas.isEmpty) return null;
    return SessionModel.fromMap(linhas.first);
  }

  /// Remove a sessão local (logout).
  Future<void> clearSession() async {
    final db = await _dbHelper.database;
    await db.delete(_table);
  }
}
