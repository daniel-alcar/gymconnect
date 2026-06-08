import 'package:gymconnect/app/modules/treinos/models/cronograma_execucao.dart';
import 'package:gymconnect/app/modules/treinos/models/status_execucao.dart';
import 'package:gymconnect/app/core/client/dio_client.dart';

/// Service de execução de cronograma — `/cronogramaexecucao/me`.
class ExecucaoService {
  final DioClient _client;
  ExecucaoService(this._client);

  /// `POST /cronogramaexecucao/me` → cria execução para o usuário logado.
  Future<CronogramaExecucao> criar({
    required int idCronograma,
    required StatusExecucao status,
  }) async {
    try {
      final res = await _client.dio.post(
        '/cronogramaexecucao/me',
        data: CronogramaExecucao.toCreateJson(
          idCronograma: idCronograma,
          status: status,
        ),
      );
      if (_client.isSucesso(res)) {
        return CronogramaExecucao.fromJson(res.data as Map<String, dynamic>);
      }
      throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }

  /// `PUT /cronogramaexecucao/me/{idExecucao}` → atualiza status.
  Future<CronogramaExecucao> atualizarStatus({
    required int idExecucao,
    required StatusExecucao status,
  }) async {
    try {
      final res = await _client.dio.put(
        '/cronogramaexecucao/me/$idExecucao',
        data: CronogramaExecucao.toUpdateJson(status),
      );
      if (_client.isSucesso(res)) {
        return CronogramaExecucao.fromJson(res.data as Map<String, dynamic>);
      }
      throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }

  /// `GET /cronogramaexecucao/me/cronograma/{idCronograma}`.
  Future<List<CronogramaExecucao>> listarPorCronograma(int idCronograma) async {
    try {
      final res = await _client.dio
          .get('/cronogramaexecucao/me/cronograma/$idCronograma');
      if (_client.isSucesso(res)) {
        final data = res.data;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(CronogramaExecucao.fromJson)
              .toList();
        }
        return const [];
      }
      throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }
}
