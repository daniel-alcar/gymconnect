import 'package:flutter/material.dart';

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
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'AI Chat',
          ),
        ],
      ),
    );
  }
}
