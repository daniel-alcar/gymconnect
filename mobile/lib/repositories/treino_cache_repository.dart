import 'dart:convert';

import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import '../database/db_helper.dart';
import '../models/cronograma.dart';

/// Repository (R) do cache local de treinos (cronogramas) por aluno.
///
/// Guarda a lista de [Cronograma] serializada em JSON na coluna `payload`,
/// permitindo exibir os treinos mesmo sem internet (Offline-First).
class TreinoCacheRepository {
  final DbHelper _dbHelper;
  TreinoCacheRepository([DbHelper? dbHelper])
      : _dbHelper = dbHelper ?? DbHelper.instance;

  static const String _table = 'treinos_cache';

  /// Salva (upsert) os cronogramas do aluno.
  Future<void> salvarTreinos(int idAluno, List<Cronograma> cronogramas) async {
    final db = await _dbHelper.database;
    final payload =
        jsonEncode(cronogramas.map((c) => c.toJson()).toList());
    await db.insert(
      _table,
      {
        'id_aluno': idAluno,
        'payload': payload,
        'is_sync': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Lê os cronogramas do aluno do cache local, ou `null` se não houver.
  Future<List<Cronograma>?> lerTreinos(int idAluno) async {
    final db = await _dbHelper.database;
    final linhas = await db.query(
      _table,
      where: 'id_aluno = ?',
      whereArgs: [idAluno],
      limit: 1,
    );
    if (linhas.isEmpty) return null;
    final payload = linhas.first['payload'] as String?;
    if (payload == null || payload.isEmpty) return null;
    final lista = jsonDecode(payload) as List<dynamic>;
    return lista
        .whereType<Map<String, dynamic>>()
        .map(Cronograma.fromJson)
        .toList();
  }

  Future<void> limpar() async {
    final db = await _dbHelper.database;
    await db.delete(_table);
  }
}
