import 'package:gymconnect/app/modules/treinos/models/status_execucao.dart';

/// Execução (sessão) de um cronograma, conforme `/cronogramaexecucao/me`.
class CronogramaExecucao {
  final int? idExecucao;
  final int? idCronograma;
  final StatusExecucao status;
  final String? dataExecucao; // ISO YYYY-MM-DD ou null

  const CronogramaExecucao({
    this.idExecucao,
    this.idCronograma,
    required this.status,
    this.dataExecucao,
  });

  factory CronogramaExecucao.fromJson(Map<String, dynamic> json) {
    final cronograma = json['cronograma'] as Map<String, dynamic>?;
    final rawDate = json['dataExecucao'];
    return CronogramaExecucao(
      idExecucao: (json['idExecucao'] as num?)?.toInt(),
      idCronograma: (cronograma?['idCronograma'] as num?)?.toInt(),
      status: StatusExecucao.fromString(json['status'] as String?),
      dataExecucao: rawDate is String ? rawDate : null,
    );
  }

  /// Corpo para `POST /cronogramaexecucao/me`.
  static Map<String, dynamic> toCreateJson({
    required int idCronograma,
    required StatusExecucao status,
  }) =>
      {
        'cronograma': {'idCronograma': idCronograma},
        'status': status.value,
      };

  /// Corpo para `PUT /cronogramaexecucao/me/{idExecucao}`.
  static Map<String, dynamic> toUpdateJson(StatusExecucao status) =>
      {'status': status.value};
}
