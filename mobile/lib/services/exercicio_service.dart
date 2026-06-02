import '../models/exercicio.dart';
import 'dio_client.dart';

/// Service da biblioteca de exercícios — perfil CLIENTE (`/exercicios`).
class ExercicioService {
  final DioClient _client;
  ExercicioService(this._client);

  /// `GET /exercicios`.
  Future<List<Exercicio>> listar() async {
    try {
      final res = await _client.dio.get('/exercicios');
      if (_client.isSucesso(res)) {
        final data = res.data;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(Exercicio.fromJson)
              .toList();
        }
        return const [];
      }
      throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }

  /// `POST /exercicios` → exercício salvo (com idExercicio).
  Future<Exercicio> cadastrar({
    required String nome,
    required String linkYoutube,
  }) async {
    try {
      final res = await _client.dio.post(
        '/exercicios',
        data: {'nome': nome, 'linkYoutube': linkYoutube},
      );
      if (_client.isSucesso(res)) {
        return Exercicio.fromJson(res.data as Map<String, dynamic>);
      }
      throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }

  /// `DELETE /exercicios/{id}`.
  Future<void> remover(int idExercicio) async {
    try {
      final res = await _client.dio.delete('/exercicios/$idExercicio');
      if (!_client.isSucesso(res)) throw _client.tratarResposta(res);
    } on Object catch (e) {
      throw _client.normalize(e);
    }
  }
}
