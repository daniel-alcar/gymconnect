import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../routes/route_names.dart';
import '../../widgets/app_logo.dart';
import '../configuracoes/configuracoes_screen.dart';

/// TELA 4 – DASHBOARD (aba inicial da navigation bar do aluno).
class DashboardScreen extends StatelessWidget {
  /// Navega para outra aba (0=Dash,1=Treinos,2=Perfil,3=Chat).
  final void Function(int aba)? onNavegar;

  const DashboardScreen({super.key, this.onNavegar});

  Future<void> _confirmarLogout(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente encerrar a sessão?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sair')),
        ],
      ),
    );
    if (confirmar == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;
    final primeiroNome = (usuario?.nome ?? 'Atleta').split(' ').first;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const AppLogo(height: 30),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const ConfiguracoesScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmarLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              'Olá, $primeiroNome',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: context.c.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pronto para o treino de hoje?',
              style: TextStyle(color: context.c.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 20),
            _HeroCard(onTap: () => onNavegar?.call(1)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MenuCard(
                    icone: Icons.person_outline,
                    titulo: 'Perfil',
                    subtitulo: 'Seus dados',
                    onTap: () => onNavegar?.call(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MenuCard(
                    icone: Icons.smart_toy_outlined,
                    titulo: 'AI Chat',
                    subtitulo: 'Tire suas dúvidas',
                    destaque: true,
                    onTap: () => onNavegar?.call(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Atividade Recente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.c.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const _AtividadeVazia(),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onTap;
  const _HeroCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 150,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.amarelo, Color(0xFFFFB000)],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.onAmarelo.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fitness_center,
                    color: AppColors.onAmarelo),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Treinos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onAmarelo,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Veja o treino do dia e marque como feito',
                    style: TextStyle(color: Color(0xCC1A1A1A), fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final bool destaque;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
    this.destaque = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: destaque ? AppColors.amarelo : context.c.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icone,
                  color: destaque
                      ? AppColors.onAmarelo
                      : context.c.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.c.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                style: TextStyle(color: context.c.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AtividadeVazia extends StatelessWidget {
  const _AtividadeVazia();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Column(
          children: [
            Icon(Icons.history, color: context.c.textSecondary, size: 40),
            const SizedBox(height: 12),
            Text(
              'Nenhuma atividade recente ainda',
              style: TextStyle(
                color: context.c.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Conclua treinos para acompanhar seu histórico aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.c.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
