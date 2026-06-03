import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Logo do GymConnect: ícone de corredor sobre o amarelo + wordmark
/// "Gym"(amarelo) + "Connect"(cinza/claro), fiel à identidade original.
class AppLogo extends StatelessWidget {
  final double size;
  final bool mostrarNome;

  const AppLogo({super.key, this.size = 96, this.mostrarNome = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogoMark(size: size),
        if (mostrarNome) ...[
          SizedBox(height: size * 0.22),
          AppWordmark(fontSize: size * 0.40),
        ],
      ],
    );
  }
}

/// Ícone da marca (quadrado amarelo arredondado com o corredor).
class AppLogoMark extends StatelessWidget {
  final double size;
  const AppLogoMark({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.amarelo,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.amarelo.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(
        Icons.directions_run,
        size: size * 0.58,
        color: AppColors.onAmarelo,
      ),
    );
  }
}

/// Texto "GymConnect" — "Gym" amarelo escuro + "Connect" na cor de texto do tema.
class AppWordmark extends StatelessWidget {
  final double fontSize;
  const AppWordmark({super.key, this.fontSize = 28});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: 'Gym',
            style: TextStyle(color: AppColors.amareloPressed),
          ),
          TextSpan(
            text: 'Connect',
            style: TextStyle(color: context.c.textPrimary),
          ),
        ],
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
