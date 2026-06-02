import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/usuario.dart';
import '../../providers/cliente_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import 'criar_treino_screen.dart';

/// CLIENTE – Treinos: criar novo treino e visualizar treinos por aluno.
class TreinosClienteScreen extends StatefulWidget {
  const TreinosClienteScreen({super.key});

  @override
  State<TreinosClienteScreen> createState() => _TreinosClienteScreenState();
}

class _TreinosClienteScreenState extends State<TreinosClienteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ClienteProvider>().carregarAlunos(),
    );
  }

  Future<void> _abrirCriarTreino() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CriarTreinoScreen()),
    );
    // Ao voltar, recarrega os treinos do aluno selecionado, se houver.
    if (!mounted) return;
    final sel = context.read<ClienteProvider>().alunoSelecionado;
    if (sel != null) {
      context.read<ClienteProvider>().carregarTreinosDoAluno(sel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          children: [
            AppLogoMark(size: 30),
            SizedBox(width: 10),
            Text('Treinos',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCriarTreino,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Criar Treino'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            const Text(
              'Visualizar treinos por aluno',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _DropdownAluno(provider: provider),
            const SizedBox(height: 16),
            _Conteudo(provider: provider),
          ],
        ),
      ),
    );
  }
}

class _DropdownAluno extends StatelessWidget {
  final ClienteProvider provider;
  const _DropdownAluno({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.carregandoAlunos && provider.alunos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Carregando alunos...',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }
    if (provider.alunos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Nenhum aluno cadastrado ainda.',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }
    return DropdownButtonFormField<int>(
      initialValue: provider.alunoSelecionado,
      isExpanded: true,
      dropdownColor: AppColors.surface,
      decoration: const InputDecoration(
        labelText: 'Aluno',
        prefixIcon: Icon(Icons.person_outline),
      ),
      hint: const Text('Selecione um aluno'),
      items: provider.alunos
          .map((Usuario a) => DropdownMenuItem(
                value: a.idUsuario,
                child: Text(a.nome,
                    style: const TextStyle(color: AppColors.textPrimary)),
              ))
          .toList(),
      onChanged: (id) {
        if (id != null) {
          context.read<ClienteProvider>().carregarTreinosDoAluno(id);
        }
      },
    );
  }
}

class _Conteudo extends StatelessWidget {
  final ClienteProvider provider;
  const _Conteudo({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.alunoSelecionado == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: EmptyState(
          icone: Icons.assignment_outlined,
          titulo: 'Selecione um aluno',
          descricao: 'Escolha um aluno acima para ver os treinos dele.',
        ),
      );
    }
    if (provider.carregandoTreinosAluno) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: LoadingIndicator(mensagem: 'Carregando treinos...'),
      );
    }
    if (provider.erroTreinosAluno != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: EmptyState(
          icone: Icons.cloud_off,
          titulo: 'Erro ao carregar',
          descricao: provider.erroTreinosAluno,
        ),
      );
    }
    if (provider.treinosAluno.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: EmptyState(
          icone: Icons.event_busy,
          titulo: 'Nenhum treino para este aluno',
          descricao: 'Toque em "Criar Treino" para montar o primeiro.',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: provider.treinosAluno.map((dia) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                dia.titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.wordmark,
                ),
              ),
            ),
            ...dia.exercicios.map((ex) {
              final detalhes = <String>[
                if (ex.serie != null) '${ex.serie} séries',
                if (ex.repeticao != null) '${ex.repeticao} reps',
                if (ex.carga != null) '${ex.carga} kg',
              ].join('  •  ');
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.fitness_center,
                      color: AppColors.primary),
                  title: Text(ex.exercicio?.nome ?? 'Exercício',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600)),
                  subtitle: detalhes.isEmpty
                      ? null
                      : Text(detalhes,
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }
}
