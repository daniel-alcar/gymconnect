import 'package:flutter/material.dart';

import 'package:gymconnect/app/modules/perfil/views/perfil_screen.dart';
import 'package:gymconnect/app/modules/cliente/views/alunos_screen.dart';
import 'package:gymconnect/app/modules/cliente/views/exercicios_screen.dart';
import 'package:gymconnect/app/modules/cliente/views/treinos_cliente_screen.dart';

/// Casca do perfil CLIENTE com a NavigationBar inferior (gestão).
class ClienteShell extends StatefulWidget {
  const ClienteShell({super.key});

  @override
  State<ClienteShell> createState() => _ClienteShellState();
}

class _ClienteShellState extends State<ClienteShell> {
  int _indice = 0;

  void _irParaAba(int i) => setState(() => _indice = i);

  @override
  Widget build(BuildContext context) {
    const telas = [
      ExerciciosScreen(),
      TreinosClienteScreen(),
      AlunosScreen(),
      PerfilScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _indice, children: telas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: _irParaAba,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Exercícios',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Treinos',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Alunos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
