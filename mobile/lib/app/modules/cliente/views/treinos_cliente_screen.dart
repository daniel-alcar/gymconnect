import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gymconnect/app/core/errors/app_exception.dart';
import 'package:gymconnect/app/core/theme/app_theme.dart';
import 'package:gymconnect/app/modules/treinos/models/cronograma_exercicio.dart';
import 'package:gymconnect/app/modules/auth/models/usuario.dart';
import 'package:gymconnect/app/modules/cliente/providers/cliente_provider.dart';
import 'package:gymconnect/app/shared/utils/snackbar_helper.dart';
import 'package:gymconnect/app/shared/widgets/app_logo.dart';
import 'package:gymconnect/app/shared/widgets/empty_state.dart';
import 'package:gymconnect/app/shared/widgets/loading_indicator.dart';
import 'package:gymconnect/app/modules/cliente/views/criar_treino_screen.dart';
import 'package:gymconnect/app/modules/cliente/views/editar_vinculo_screen.dart';

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
        heroTag: 'fab_treinos_cliente',
        onPressed: _abrirCriarTreino,
        icon: const Icon(Icons.add),
        label: const Text('Criar Treino'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            Text(
              'Visualizar treinos por aluno',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.c.textPrimary,
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
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Carregando alunos...',
              style: TextStyle(color: context.c.textSecondary)),
        ),
      );
    }
    if (provider.alunos.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Nenhum aluno cadastrado ainda.',
              style: TextStyle(color: context.c.textSecondary)),
        ),
      );
    }
    return DropdownButtonFormField<int>(
      initialValue: provider.alunoSelecionado,
      isExpanded: true,
      dropdownColor: context.c.surface,
      decoration: const InputDecoration(
        labelText: 'Aluno',
        prefixIcon: Icon(Icons.person_outline),
      ),
      hint: const Text('Selecione um aluno'),
      items: provider.alunos
          .map((Usuario a) => DropdownMenuItem(
                value: a.idUsuario,
                child: Text(a.nome,
                    style: TextStyle(color: context.c.textPrimary)),
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
                  color: AppColors.amareloPressed,
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
                  onTap: () => _abrirEdicaoVinculo(context, ex),
                  leading: const Icon(Icons.fitness_center,
                      color: AppColors.amareloPressed),
                  title: Text(ex.exercicio?.nome ?? 'Exercício',
                      style: TextStyle(
                          color: context.c.textPrimary,
                          fontWeight: FontWeight.w600)),
                  subtitle: detalhes.isEmpty
                      ? null
                      : Text(detalhes,
                          style: TextStyle(color: context.c.textSecondary)),
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Opções',
                    icon: Icon(Icons.more_vert, color: context.c.textSecondary),
                    color: context.c.surface,
                    onSelected: (opcao) {
                      if (opcao == 'editar') {
                        _abrirEdicaoVinculo(context, ex);
                      } else if (opcao == 'excluir') {
                        _confirmarRemoverVinculo(context, ex);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                                color: context.c.textPrimary, size: 20),
                            const SizedBox(width: 12),
                            Text('Editar',
                                style:
                                    TextStyle(color: context.c.textPrimary)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'excluir',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                color: AppColors.danger, size: 20),
                            SizedBox(width: 12),
                            Text('Excluir',
                                style: TextStyle(color: AppColors.danger)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }
}

/// Abre a tela de edição do vínculo de treino (PUT /cronogramaexercicio/{id}).
Future<void> _abrirEdicaoVinculo(
    BuildContext context, CronogramaExercicio ex) async {
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => EditarVinculoScreen(vinculo: ex)),
  );
}

/// Confirma e remove um vínculo de treino (DELETE /cronogramaexercicio/{id}).
Future<void> _confirmarRemoverVinculo(
    BuildContext context, CronogramaExercicio ex) async {
  if (ex.idCronogramaExercicio == null) return;
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: context.c.surface,
      title: const Text('Remover exercício'),
      content: Text(
          'Remover "${ex.exercicio?.nome ?? 'exercício'}" deste treino?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Remover'),
        ),
      ],
    ),
  );
  if (confirmar == true && context.mounted) {
    try {
      await context
          .read<ClienteProvider>()
          .removerVinculo(ex.idCronogramaExercicio!);
      if (context.mounted) {
        SnackbarHelper.sucesso(context, 'Exercício removido do treino.');
      }
    } on AppException catch (e) {
      if (context.mounted) SnackbarHelper.erro(context, e.message);
    } catch (_) {
      if (context.mounted) SnackbarHelper.erro(context, 'Erro ao remover.');
    }
  }
}
