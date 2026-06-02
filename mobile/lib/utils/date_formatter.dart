import 'package:intl/intl.dart';

/// Utilitários de data para a API (ISO `YYYY-MM-DD`) e exibição (pt-BR).
class DateFormatter {
  DateFormatter._();

  static final DateFormat _iso = DateFormat('yyyy-MM-dd');
  static final DateFormat _br = DateFormat('dd/MM/yyyy');

  static String toIso(DateTime date) => _iso.format(date);

  static String toBr(DateTime date) => _br.format(date);

  /// Converte uma string ISO do backend para exibição pt-BR (ou retorna cru).
  static String? isoToBr(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final parsed = DateTime.tryParse(iso);
    return parsed != null ? _br.format(parsed) : iso;
  }
}
