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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.amarelo.withValues(alpha: 0.18),
              context.c.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const AppLogo(height: 104),
                const SizedBox(height: 16),
                Text(
                  'Sua evolução começa aqui.\nConecte-se ao seu melhor desempenho.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.c.textSecondary,
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
                        titulo: 'Treino IA',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _FeatureChip(
                        icone: Icons.show_chart,
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
                Text(
                  'Ao continuar, você concorda com nossos Termos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.c.textSecondary, fontSize: 12),
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
  final String titulo;
  const _FeatureChip({required this.icone, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: AppColors.amareloPressed, size: 24),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: TextStyle(
              color: context.c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
