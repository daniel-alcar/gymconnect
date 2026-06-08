import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';

/// Tela de Configurações — preferências do app (tema claro/escuro/sistema).
class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Aparência',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.c.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.palette_outlined,
                            color: AppColors.amareloPressed),
                        const SizedBox(width: 12),
                        Text(
                          'Tema do aplicativo',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: context.c.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Claro'),
                          icon: Icon(Icons.light_mode),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Escuro'),
                          icon: Icon(Icons.dark_mode),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('Sistema'),
                          icon: Icon(Icons.settings_suggest_outlined),
                        ),
                      ],
                      selected: {tema.modo},
                      onSelectionChanged: (s) =>
                          context.read<ThemeProvider>().definir(s.first),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _descricao(tema.modo),
                      style: TextStyle(
                          color: context.c.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sobre',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.c.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline,
                    color: AppColors.amareloPressed),
                title: Text('GymConnect',
                    style: TextStyle(color: context.c.textPrimary)),
                subtitle: Text('Versão 1.0.0',
                    style: TextStyle(color: context.c.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _descricao(ThemeMode modo) {
    switch (modo) {
      case ThemeMode.light:
        return 'Tema claro (identidade oficial do GymConnect).';
      case ThemeMode.dark:
        return 'Tema escuro ativado.';
      case ThemeMode.system:
        return 'Acompanha o tema do sistema (Android).';
    }
  }
}
