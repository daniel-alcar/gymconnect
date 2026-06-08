import '../models/cronograma.dart';
import 'dio_client.dart';

/// Service de treinos — consome os cronogramas do aluno.
///
/// Usamos `GET /cronograma/{idAluno}` (e não o endpoint plano de
/// cronogramaexercicio) porque a resposta traz `idCronograma` + a lista
/// `exercicio[]` aninhada, necessária para registrar execuções.
class TreinoService {
  final DioClient _client;
  TreinoService(this._client);

  Future<List<Cronograma>> listarCronogramasPorAluno(int idAluno) async {
    try {
      final res = await _client.dio.get('/cronograma/$idAluno');
      if (_client.isSucesso(res)) {
        final data = res.data;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(Cronograma.fromJson)
              .toList();
        }
        return const [];
      }
      // 404 = aluno sem cronograma → lista vazia (empty state).
      if (res.statusCode == 404) return const [];
      throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }
}
