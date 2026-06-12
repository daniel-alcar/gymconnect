import 'package:flutter/services.dart';

/// Formatadores de input reutilizáveis em toda a aplicação.
class AppFormatters {
  AppFormatters._();

  /// Bloqueia emojis e caracteres especiais Unicode em campos de texto.
  static final TextInputFormatter noEmoji = FilteringTextInputFormatter.deny(
    RegExp(
      '['
      '\u{1F600}-\u{1F64F}' // Emoticons
      '\u{1F300}-\u{1F5FF}' // Misc Symbols and Pictographs
      '\u{1F680}-\u{1F6FF}' // Transport and Map
      '\u{1F700}-\u{1F7FF}' // Alchemical / Geometric Extended
      '\u{1F800}-\u{1F8FF}' // Supplemental Arrows-C
      '\u{1F900}-\u{1F9FF}' // Supplemental Symbols
      '\u{1FA00}-\u{1FA6F}' // Chess Symbols
      '\u{1FA70}-\u{1FAFF}' // Symbols Extended-A
      '\u{2600}-\u{26FF}'   // Misc Symbols
      '\u{2700}-\u{27BF}'   // Dingbats
      '\u{FE00}-\u{FE0F}'   // Variation Selectors
      '\u{1F1E0}-\u{1F1FF}' // Flags
      '\u{200D}'            // Zero Width Joiner
      '\u{20E3}'            // Combining Enclosing Keycap
      ']',
      unicode: true,
    ),
  );

  /// Máscara de altura em metros: digitar "175" exibe "1,75".
  ///
  /// Aceita até 3 dígitos (máx. "2,20") e insere a vírgula automaticamente.
  /// O valor bruto do controller já usa vírgula como separador decimal;
  /// o validator/parser substitui por ponto antes de chamar [double.tryParse].
  static final TextInputFormatter alturaMask = _AlturaMaskFormatter();
}

class _AlturaMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extrai apenas os dígitos digitados.
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limita a 3 dígitos (representam no máximo "2,20" → 2.20 m).
    final d = digits.length > 3 ? digits.substring(0, 3) : digits;

    final String formatted;
    if (d.isEmpty) {
      formatted = '';
    } else if (d.length == 1) {
      formatted = d; // "1"
    } else {
      // Ex.: "17" → "1,7" | "175" → "1,75"
      formatted = '${d[0]},${d.substring(1)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
