import '../models/cronograma_exercicio.dart';
import '../models/dia_semana.dart';
import '../models/status_execucao.dart';
import '../services/execucao_service.dart';
import '../services/registro_service.dart';
import '../services/treino_service.dart';

/// Agrupamento de exercícios por dia da semana (para a UI de treinos).
class TreinoDia {
  final DiaSemana? dia;
  final List<CronogramaExercicio> exercicios;
  const TreinoDia({required this.dia, required this.exercicios});

  String get titulo => dia?.label ?? 'Sem dia definido';
}

/// Orquestra treinos: carrega cronogramas, agrupa por dia e registra conclusão.
class TreinoRepository {
  final TreinoService _treinoService;
  final ExecucaoService _execucaoService;
  final RegistroService _registroService;

  TreinoRepository(
    this._treinoService,
    this._execucaoService,
    this._registroService,
  );

  /// Carrega todos os exercícios do aluno agrupados por dia da semana.
  Future<List<TreinoDia>> carregarTreinos(int idAluno) async {
    final cronogramas = await _treinoService.listarCronogramasPorAluno(idAluno);

    final todos = <CronogramaExercicio>[
      for (final c in cronogramas) ...c.exercicios,
    ];

    // Agrupa por dia da semana.
    final mapa = <DiaSemana?, List<CronogramaExercicio>>{};
    for (final ex in todos) {
      mapa.putIfAbsent(ex.diaSemana, () => []).add(ex);
    }

    final dias = mapa.entries
        .map((e) => TreinoDia(dia: e.key, exercicios: e.value))
        .toList()
      ..sort((a, b) {
        final oa = a.dia?.ordem ?? 999;
        final ob = b.dia?.ordem ?? 999;
        return oa.compareTo(ob);
      });

    return dias;
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
