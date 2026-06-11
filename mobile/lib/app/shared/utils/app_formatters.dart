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
}
