-- DDL do banco local (Offline-First). Lido via rootBundle pelo DbHelper.
-- Cada comando termina em ponto e virgula e e executado individualmente.

CREATE TABLE IF NOT EXISTS session (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  id_usuario INTEGER NOT NULL,
  nome TEXT NOT NULL,
  email TEXT NOT NULL,
  tipo TEXT NOT NULL,
  token TEXT NOT NULL,
  is_sync INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS treinos_cache (
  id_aluno INTEGER PRIMARY KEY,
  payload TEXT NOT NULL,
  is_sync INTEGER NOT NULL DEFAULT 1,
  updated_at TEXT NOT NULL
);
