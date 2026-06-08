import '../core/errors/app_exception.dart';
import '../models/cronograma.dart';
import '../models/cronograma_exercicio.dart';
import '../models/dia_semana.dart';
import '../models/status_execucao.dart';
import '../services/connectivity_service.dart';
import '../services/execucao_service.dart';
import '../services/registro_service.dart';
import '../services/treino_service.dart';
import 'treino_cache_repository.dart';

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
  final RegistroService _registroService;
  final TreinoCacheRepository _cache;
  final ConnectivityService _connectivity;

  TreinoRepository(
    this._treinoService,
    this._execucaoService,
    this._registroService,
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
        await _cache.salvarTreinos(idAluno, cronogramas);
        return _agruparPorDia(cronogramas);
      } on AppException catch (e) {
        // Erro de autenticação propaga (logout). Falha de rede tenta o cache.
        if (e.isAuthError) rethrow;
        final cache = await _cache.lerTreinos(idAluno);
        if (cache != null) return _agruparPorDia(cache);
        rethrow;
      }
    }

    // Offline: serve o cache local.
    final cache = await _cache.lerTreinos(idAluno);
    if (cache != null) return _agruparPorDia(cache);
    throw const AppException(
      'Você está offline e ainda não há treinos salvos neste dispositivo.',
    );
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

  /// Marca um exercício/treino como feito.
  ///
  /// Regra (alinhada à API): cria uma execução `FEITO` para o cronograma do
  /// exercício e, se houver peso informado, grava o registro diário.
  Future<void> marcarComoFeito({
    required int idCronograma,
    double? peso,
  }) async {
    final execucao = await _execucaoService.criar(
      idCronograma: idCronograma,
      status: StatusExecucao.feito,
    );

    if (peso != null && execucao.idExecucao != null) {
      await _registroService.registrarPeso(
        idExecucao: execucao.idExecucao!,
        peso: peso,
      );
    }
  }
}
