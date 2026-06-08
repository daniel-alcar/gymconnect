import 'package:gymconnect/app/modules/treinos/models/cronograma.dart';
import 'package:gymconnect/app/modules/treinos/models/dia_semana.dart';
import 'package:gymconnect/app/core/client/dio_client.dart';

/// Service de gestão de cronogramas/treinos — perfil CLIENTE.
class GestaoService {
  final DioClient _client;
  GestaoService(this._client);

  /// `POST /cronograma` → cria o cronograma do aluno e retorna o salvo.
  Future<Cronograma> criarCronograma({
    required int idAluno,
    int? diasTotais,
  }) async {
    try {
      final res = await _client.dio.post(
        '/cronograma',
        data: {
          'aluno': {'idUsuario': idAluno},
          'diasTotais': diasTotais,
        },
      );
      if (_client.isSucesso(res)) {
        return Cronograma.fromJson(res.data as Map<String, dynamic>);
      }
      throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }

  /// `POST /cronogramaexercicio` → vincula um exercício ao cronograma.
  Future<void> vincularExercicio({
    required int idCronograma,
    required int idExercicio,
    DiaSemana? diaSemana,
    int? serie,
    int? repeticao,
    int? carga,
  }) async {
    try {
      final res = await _client.dio.post(
        '/cronogramaexercicio',
        data: {
          'cronograma': {'idCronograma': idCronograma},
          'exercicio': {'idExercicio': idExercicio},
          'diaSemana': diaSemana?.value,
          'serie': serie,
          'repeticao': repeticao,
          'carga': carga,
        },
      );
      if (!_client.isSucesso(res)) throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }

  /// `PUT /cronogramaexercicio/{id}` → atualiza o vínculo (exercício + dia/série/rep/carga).
  Future<void> atualizarVinculo({
    required int idCronogramaExercicio,
    required int idCronograma,
    required int idExercicio,
    DiaSemana? diaSemana,
    int? serie,
    int? repeticao,
    int? carga,
  }) async {
    try {
      final res = await _client.dio.put(
        '/cronogramaexercicio/$idCronogramaExercicio',
        data: {
          'cronograma': {'idCronograma': idCronograma},
          'exercicio': {'idExercicio': idExercicio},
          'diaSemana': diaSemana?.value,
          'serie': serie,
          'repeticao': repeticao,
          'carga': carga,
        },
      );
      if (!_client.isSucesso(res)) throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }

  /// `DELETE /cronogramaexercicio/{id}` → remove um vínculo do treino.
  Future<void> removerVinculo(int idCronogramaExercicio) async {
    try {
      final res =
          await _client.dio.delete('/cronogramaexercicio/$idCronogramaExercicio');
      if (!_client.isSucesso(res)) throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }

  /// `DELETE /cronograma/{id}`.
  Future<void> removerCronograma(int idCronograma) async {
    try {
      final res = await _client.dio.delete('/cronograma/$idCronograma');
      if (!_client.isSucesso(res)) throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }
}
