-- DDL do banco local (Offline-First). Lido via rootBundle pelo DbHelper.
-- Cada comando é separado por ';' e executado individualmente no _onCreate.

-- Sessão do usuário logado (cache local para login offline).
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

-- Cache dos treinos (cronogramas) por aluno. O conteúdo dos cronogramas
-- é guardado como JSON em 'payload' (lista de Cronograma serializada).
CREATE TABLE IF NOT EXISTS treinos_cache (
  id_aluno INTEGER PRIMARY KEY,
  payload TEXT NOT NULL,
  is_sync INTEGER NOT NULL DEFAULT 1,
  updated_at TEXT NOT NULL
);
