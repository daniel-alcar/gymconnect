import 'package:flutter/material.dart';

import 'package:gymconnect/app/shared/widgets/app_logo.dart';
import 'package:gymconnect/app/modules/chat/views/chat_screen.dart';
import 'package:gymconnect/app/modules/home/views/dashboard_screen.dart';
import 'package:gymconnect/app/modules/perfil/views/perfil_screen.dart';
import 'package:gymconnect/app/modules/treinos/views/treinos_screen.dart';

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

/// Icone da aba GIA: usa a imagem do robo ja recortada (sem o texto "GIA" e
/// sem margens), entao centraliza e dimensiona como um icone normal. A cor
/// segue o IconTheme da NavigationBar (selecionado/nao selecionado).
class _IconeGia extends StatelessWidget {
  const _IconeGia();

  @override
  Widget build(BuildContext context) {
    return const ImageIcon(AssetImage(AppLogoAssets.giaIcon), size: 28);
  }
}
