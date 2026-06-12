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

  /// Permite apenas letras (incluindo acentos) e espaços — ideal para nome completo.
  static final TextInputFormatter apenasLetras = FilteringTextInputFormatter.allow(
    RegExp(r'[\p{L}\s]', unicode: true),
  );

  /// Máscara de altura em metros: digitar "175" exibe "1,75".
  ///
  /// Aceita até 3 dígitos (máx. "2,20") e insere a vírgula automaticamente.
  static final TextInputFormatter alturaMask = _AlturaMaskFormatter();

  /// Máscara de data no formato dd/mm/aaaa.
  ///
  /// As barras são inseridas automaticamente ao digitar:
  /// "1506" → "15/06" | "15062000" → "15/06/2000".
  static final TextInputFormatter dataMask = _DataMaskFormatter();
}

class _DataMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final d = digits.length > 8 ? digits.substring(0, 8) : digits;

    final buf = StringBuffer();
    for (int i = 0; i < d.length; i++) {
      if (i == 2 || i == 4) buf.write('/');
      buf.write(d[i]);
    }

    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
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
