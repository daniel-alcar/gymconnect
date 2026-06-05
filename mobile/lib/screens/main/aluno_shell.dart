import 'package:flutter/material.dart';

import '../../widgets/app_logo.dart';
import '../chat/chat_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../perfil/perfil_screen.dart';
import '../treinos/treinos_screen.dart';

/// Casca do perfil ALUNO com a NavigationBar inferior (4 abas).
class AlunoShell extends StatefulWidget {
  final int abaInicial;
  const AlunoShell({super.key, this.abaInicial = 0});

  @override
  State<AlunoShell> createState() => _AlunoShellState();
}

class _AlunoShellState extends State<AlunoShell> {
  late int _indice = widget.abaInicial;

  void _irParaAba(int i) => setState(() => _indice = i);

  @override
  Widget build(BuildContext context) {
    final telas = [
      DashboardScreen(onNavegar: _irParaAba),
      const TreinosScreen(),
      const PerfilScreen(),
      const ChatScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _indice, children: telas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: _irParaAba,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Treinos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
          // Mascote da GIA. A imagem tem muita margem transparente, entao o slot
          // fica do tamanho dos demais (24) e o OverflowBox amplia a arte para
          // que o desenho visivel fique do mesmo tamanho dos outros icones.
          NavigationDestination(
            icon: _IconeGia(),
            selectedIcon: _IconeGia(),
            label: 'GIA',
          ),
        ],
      ),
    );
  }
}

/// Icone da aba GIA: mantem o slot no tamanho dos demais (24) mas amplia a
/// arte (que tem margem transparente) para ~44 via OverflowBox, deixando o
/// desenho visivel do mesmo tamanho dos outros icones. A cor segue o
/// IconTheme da NavigationBar (selecionado/nao selecionado).
class _IconeGia extends StatelessWidget {
  const _IconeGia();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: OverflowBox(
          maxWidth: 44,
          maxHeight: 44,
          child: ImageIcon(AssetImage(AppLogoAssets.gia), size: 44),
        ),
      ),
    );
  }
}
