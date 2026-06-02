import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../routes/route_names.dart';
import '../../widgets/app_logo.dart';

/// TELA 1 – INICIAL. Apresenta o app e permite Entrar (Login) ou Cadastrar.
class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF111A2E), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const AppLogoMark(size: 84),
                const SizedBox(height: 20),
                const AppWordmark(fontSize: 36),
                const SizedBox(height: 12),
                const Text(
                  'Sua evolução começa aqui.\nConecte-se ao seu melhor desempenho.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const Spacer(flex: 2),
                const Row(
                  children: [
                    Expanded(
                      child: _FeatureChip(
                        icone: Icons.auto_awesome,
                        cor: AppColors.success,
                        titulo: 'Treino IA',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _FeatureChip(
                        icone: Icons.show_chart,
                        cor: AppColors.primary,
                        titulo: 'Progresso',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => context.push(RouteNames.login),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Entrar'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () => context.push(RouteNames.cadastro),
                  child: const Text('Cadastrar'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ao continuar, você concorda com nossos Termos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final String titulo;
  const _FeatureChip({
    required this.icone,
    required this.cor,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: cor, size: 24),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
