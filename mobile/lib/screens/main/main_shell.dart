import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../cliente/cliente_shell.dart';
import 'aluno_shell.dart';

/// Decide a navegação conforme o perfil do usuário logado.
///
/// - CLIENTE (academia/professor): área de gestão (Exercícios, Treinos, Alunos).
/// - ALUNO: Dashboard, Treinos, Perfil, Chat IA.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final isCliente = context.watch<AuthProvider>().isCliente;
    return isCliente ? const ClienteShell() : const AlunoShell();
  }
}
