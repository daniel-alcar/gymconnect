import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Singleton de acesso ao banco local SQLite (padrão da aula 12).
///
/// O DDL fica externo em `assets/sql/create_tables.sql` e é lido via
/// `rootBundle`, dividido por `;` e executado comando a comando no _onCreate.
class DbHelper {
  DbHelper._init();
  static final DbHelper instance = DbHelper._init();

  static Database? _database;

  static const String _dbName = 'gymconnect.db';
  static const int _dbVersion = 1;

  /// Acesso lazy: abre/cria o banco na primeira chamada.
  Future<Database> get database async {
    return _database ??= await _initDB();
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final caminho = p.join(dbPath, _dbName);
    return openDatabase(
      caminho,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final ddl = await rootBundle.loadString('assets/sql/create_tables.sql');
    // Remove linhas de comentario (--) antes de dividir, para que um ';'
    // dentro de um comentario nunca seja interpretado como fim de comando.
    final semComentarios = ddl
        .split('\n')
        .where((linha) => !linha.trimLeft().startsWith('--'))
        .join('\n');
    final comandos = semComentarios
        .split(';')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty);
    for (final comando in comandos) {
      await db.execute(comando);
    }
  }

  /// Fecha o banco (útil em testes/logout completo).
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
