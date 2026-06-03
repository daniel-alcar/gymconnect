import 'package:flutter/material.dart';

/// Cores de **marca** do GymConnect (constantes — iguais em ambos os temas).
///
/// Extraídas da identidade original (React/CSS + logo):
/// amarelo institucional `#FFC300`, cinza escuro `#333` do "CONNECT".
class AppColors {
  AppColors._();

  static const Color amarelo = Color(0xFFFFC300); // primária da marca
  static const Color amareloPressed = Color(0xFFE6AC00);
  static const Color cinza = Color(0xFF333333); // "CONNECT" / texto forte
  static const Color onAmarelo = Color(0xFF1A1A1A); // texto sobre o amarelo
  static const Color success = Color(0xFF2E9E5B);
  static const Color danger = Color(0xFFD93838);
}

/// Paleta de superfícies/textos resolvida conforme o tema (claro/escuro).
class AppPalette {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });
}

/// Tema CLARO — identidade principal (fundo claro, cards brancos).
const AppPalette kLightPalette = AppPalette(
  background: Color(0xFFF4F5F2),
  surface: Color(0xFFFFFFFF),
  surfaceAlt: Color(0xFFEFF1ED),
  border: Color(0xFFE3E5E0),
  textPrimary: Color(0xFF22241F),
  textSecondary: Color(0xFF6B7280),
);

/// Tema ESCURO — adaptação da identidade (mantém o amarelo da marca).
const AppPalette kDarkPalette = AppPalette(
  background: Color(0xFF131410),
  surface: Color(0xFF1D1E18),
  surfaceAlt: Color(0xFF26271F),
  border: Color(0xFF34362B),
  textPrimary: Color(0xFFF3F4EE),
  textSecondary: Color(0xFF9AA08E),
);

/// Acesso à paleta correta a partir do `BuildContext`: `context.c.surface`, etc.
extension AppPaletteX on BuildContext {
  AppPalette get c => Theme.of(this).brightness == Brightness.dark
      ? kDarkPalette
      : kLightPalette;
}
