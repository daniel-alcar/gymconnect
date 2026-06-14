import 'package:gymconnect/app/core/errors/app_exception.dart';
import 'package:gymconnect/app/modules/treinos/models/cronograma.dart';
import 'package:gymconnect/app/modules/treinos/models/cronograma_exercicio.dart';
import 'package:gymconnect/app/modules/treinos/models/dia_semana.dart';
import 'package:gymconnect/app/modules/treinos/models/status_execucao.dart';
import 'package:gymconnect/app/core/network/connectivity_service.dart';
import 'package:gymconnect/app/modules/treinos/services/execucao_service.dart';
import 'package:gymconnect/app/modules/treinos/services/treino_service.dart';
import 'package:gymconnect/app/modules/treinos/repositories/treino_cache_repository.dart';

/// Agrupamento de exercícios por dia da semana (para a UI de treinos).
class TreinoDia {
  final DiaSemana? dia;
  final List<CronogramaExercicio> exercicios;
  const TreinoDia({required this.dia, required this.exercicios});

  String get titulo => dia?.label ?? 'Sem dia definido';
}

/// Orquestra treinos: carrega cronogramas, agrupa por dia e registra conclusão.
///
/// Offline-First: quando online, busca no backend e atualiza o cache local;
/// quando offline (ou em falha de rede), serve os treinos do cache SQLite.
class TreinoRepository {
  final TreinoService _treinoService;
  final ExecucaoService _execucaoService;
  final TreinoCacheRepository _cache;
  final ConnectivityService _connectivity;

  TreinoRepository(
    this._treinoService,
    this._execucaoService,
    this._cache, [
    ConnectivityService? connectivity,
  ]) : _connectivity = connectivity ?? ConnectivityService();

  /// Carrega todos os exercícios do aluno agrupados por dia da semana.
  Future<List<TreinoDia>> carregarTreinos(int idAluno) async {
    final online = await _connectivity.isOnline();

    if (online) {
      try {
        final cronogramas =
            await _treinoService.listarCronogramasPorAluno(idAluno);
        // Atualiza o cache local (best-effort: não derruba o fluxo online).
        try {
          await _cache.salvarTreinos(idAluno, cronogramas);
        } catch (_) {/* ignora falha de cache local */}
        return _agruparPorDia(cronogramas);
      } on AppException catch (e) {
        // Erro de autenticação propaga (logout). Falha de rede tenta o cache.
        if (e.isAuthError) rethrow;
        final cache = await _lerCacheSeguro(idAluno);
        if (cache != null) return _agruparPorDia(cache);
        rethrow;
      }
    }

    // Offline: serve o cache local.
    final cache = await _lerCacheSeguro(idAluno);
    if (cache != null) return _agruparPorDia(cache);
    throw const AppException(
      'Você está offline e ainda não há treinos salvos neste dispositivo.',
    );
  }

  /// Lê o cache local ignorando falhas (retorna null se indisponível).
  Future<List<Cronograma>?> _lerCacheSeguro(int idAluno) async {
    try {
      return await _cache.lerTreinos(idAluno);
    } catch (_) {
      return null;
    }
  }

  /// Agrupa os exercícios de todos os cronogramas por dia da semana.
  List<TreinoDia> _agruparPorDia(List<Cronograma> cronogramas) {
    final todos = <CronogramaExercicio>[
      for (final c in cronogramas) ...c.exercicios,
    ];

    final mapa = <DiaSemana?, List<CronogramaExercicio>>{};
    for (final ex in todos) {
      mapa.putIfAbsent(ex.diaSemana, () => []).add(ex);
    }

    return mapa.entries
        .map((e) => TreinoDia(dia: e.key, exercicios: e.value))
        .toList()
      ..sort((a, b) {
        final oa = a.dia?.ordem ?? 999;
        final ob = b.dia?.ordem ?? 999;
        return oa.compareTo(ob);
      });
  }

  /// Marca um exercício/treino como feito criando uma execução `FEITO`.
  Future<void> marcarComoFeito({required int idCronograma}) async {
    await _execucaoService.criar(
      idCronograma: idCronograma,
      status: StatusExecucao.feito,
    );
  }
}
