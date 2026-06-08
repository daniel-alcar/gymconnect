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

  /// Tempo relativo amigável (ex.: "Agora", "Há 2h", "Ontem", "12/06 14:30").
  static String relativo(DateTime data) {
    final agora = DateTime.now();
    final diff = agora.difference(data);
    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return 'Há ${diff.inDays} dias';
    return DateFormat('dd/MM HH:mm').format(data);
  }
}
