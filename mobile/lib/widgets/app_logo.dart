import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Logo do GymConnect: quadrado azul arredondado com halter + wordmark.
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
          AppWordmark(fontSize: size * 0.42),
        ],
      ],
    );
  }
}

/// Apenas o ícone (quadrado azul com halter).
class AppLogoMark extends StatelessWidget {
  final double size;
  const AppLogoMark({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Transform.rotate(
        angle: -0.785, // -45°, halter inclinado como no design
        child: Icon(
          Icons.fitness_center,
          size: size * 0.52,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Texto "GymConnect" estilizado.
class AppWordmark extends StatelessWidget {
  final double fontSize;
  const AppWordmark({super.key, this.fontSize = 28});

  @override
  Widget build(BuildContext context) {
    return Text(
      'GymConnect',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: AppColors.wordmark,
        letterSpacing: -0.5,
      ),
    );
  }
}
