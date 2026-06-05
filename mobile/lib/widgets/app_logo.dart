import 'package:flutter/material.dart';

/// Caminhos dos assets das 3 variações da logo oficial do GymConnect.
class AppLogoAssets {
  AppLogoAssets._();
  static const String full = 'assets/images/gymconnect_logo.png'; // texto, fundo claro
  static const String fullWhite =
      'assets/images/gymconnect_logo_white.png'; // texto, fundo escuro
  static const String mark = 'assets/images/gymconnect_mark.png'; // só imagem
  static const String gia = 'assets/images/gia.png'; // mascote da GIA
}

/// Logo COMPLETA (corredor + "GymConnect"), adaptando-se ao tema:
/// versão colorida no claro e versão branca no escuro.
class AppLogo extends StatelessWidget {
  final double height;
  const AppLogo({super.key, this.height = 40});

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      escuro ? AppLogoAssets.fullWhite : AppLogoAssets.full,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// Apenas a IMAGEM da marca (corredor), sem texto.
class AppLogoMark extends StatelessWidget {
  final double size;
  const AppLogoMark({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppLogoAssets.mark,
      height: size,
      width: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}
