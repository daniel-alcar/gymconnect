import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../models/exercicio.dart';
import '../../providers/cliente_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/validators.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';

/// CLIENTE – Biblioteca de exercícios (listar, cadastrar, remover).
class ExerciciosScreen extends StatefulWidget {
  const ExerciciosScreen({super.key});

  @override
  State<ExerciciosScreen> createState() => _ExerciciosScreenState();
}

class _ExerciciosScreenState extends State<ExerciciosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ClienteProvider>().carregarExercicios(),
    );
  }

  Future<void> _carregar() =>
      context.read<ClienteProvider>().carregarExercicios();

  /// Abre o formulário para criar (existente == null) ou editar um exercício.
  Future<void> _abrirFormulario([Exercicio? existente]) async {
    final editando = existente != null;
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController(text: existente?.nome ?? '');
    final linkController =
        TextEditingController(text: existente?.linkYoutube ?? '');
    final descricaoController =
        TextEditingController(text: existente?.descricao ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    editando ? 'Editar exercício' : 'Novo exercício',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nomeController,
                    validator: (v) => Validators.obrigatorio(v, campo: 'Nome'),
                    decoration: const InputDecoration(
                      labelText: 'Nome do exercício',
                      prefixIcon: Icon(Icons.fitness_center),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: linkController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Link do YouTube (opcional)',
                      hintText: 'https://youtube.com/watch?v=...',
                      prefixIcon: Icon(Icons.ondemand_video),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: descricaoController,
                    minLines: 3,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      labelText: 'Descrição / execução (opcional)',
                      hintText: 'Ex.: Mantenha a coluna neutra, desça '
                          'controlando o movimento...',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Consumer<ClienteProvider>(
                    builder: (_, p, __) => FilledButton(
                      onPressed: p.salvando
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              try {
                                final prov = context.read<ClienteProvider>();
                                if (editando) {
                                  await prov.atualizarExercicio(
                                    existente.idExercicio!,
                                    nomeController.text,
                                    linkController.text,
                                    descricaoController.text,
                                  );
                                } else {
                                  await prov.cadastrarExercicio(
                                    nomeController.text,
                                    linkController.text,
                                    descricaoController.text,
                                  );
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) {
                                  SnackbarHelper.sucesso(
                                    context,
                                    editando
                                        ? 'Exercício atualizado!'
                                        : 'Exercício cadastrado!',
                                  );
                                }
                              } on AppException catch (e) {
                                if (ctx.mounted) {
                                  SnackbarHelper.erro(ctx, e.message);
                                }
                              } catch (_) {
                                if (ctx.mounted) {
                                  SnackbarHelper.erro(
                                      ctx, 'Erro ao salvar exercício.');
                                }
                              }
                            },
                      child: p.salvando
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: AppColors.onAmarelo),
                            )
                          : Text(editando ? 'Salvar' : 'Cadastrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmarRemover(Exercicio ex) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.c.surface,
        title: const Text('Remover exercício'),
        content: Text('Deseja remover "${ex.nome}" da biblioteca?'),
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
    if (confirmar == true && ex.idExercicio != null) {
      if (!mounted) return;
      try {
        await context.read<ClienteProvider>().removerExercicio(ex.idExercicio!);
        if (mounted) SnackbarHelper.sucesso(context, 'Exercício removido.');
      } on AppException catch (e) {
        if (mounted) SnackbarHelper.erro(context, e.message);
      } catch (_) {
        if (mounted) SnackbarHelper.erro(context, 'Erro ao remover.');
      }
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
            Text('Exercícios',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_exercicios',
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _carregar,
          child: _buildBody(provider),
        ),
      ),
    );
  }

  Widget _buildBody(ClienteProvider provider) {
    if (provider.carregandoExercicios && provider.exercicios.isEmpty) {
      return const LoadingIndicator(mensagem: 'Carregando exercícios...');
    }
    if (provider.erroExercicios != null && provider.exercicios.isEmpty) {
      return ListView(children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        EmptyState(
          icone: Icons.cloud_off,
          titulo: 'Não foi possível carregar',
          descricao: provider.erroExercicios,
          acao: FilledButton.icon(
            onPressed: _carregar,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ),
      ]);
    }
    if (provider.exercicios.isEmpty) {
      return ListView(children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.16),
        const EmptyState(
          icone: Icons.list_alt,
          titulo: 'Nenhum exercício cadastrado',
          descricao: 'Toque em "Novo" para adicionar à biblioteca.',
        ),
      ]);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: provider.exercicios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final ex = provider.exercicios[i];
        final infos = <String>[
          ex.temVideo ? 'Com vídeo' : 'Sem vídeo',
          if (ex.temDescricao) 'Com descrição',
        ].join('  •  ');
        return Card(
          child: ListTile(
            onTap: () => _abrirFormulario(ex),
            leading: CircleAvatar(
              backgroundColor: context.c.surfaceAlt,
              child: const Icon(Icons.fitness_center,
                  color: AppColors.amareloPressed),
            ),
            title: Text(ex.nome,
                style: TextStyle(
                    color: context.c.textPrimary,
                    fontWeight: FontWeight.w600)),
            subtitle: Text(infos,
                style: TextStyle(color: context.c.textSecondary)),
            trailing: PopupMenuButton<String>(
              tooltip: 'Opções',
              icon: Icon(Icons.more_vert, color: context.c.textSecondary),
              color: context.c.surface,
              onSelected: (op) {
                if (op == 'editar') {
                  _abrirFormulario(ex);
                } else if (op == 'excluir') {
                  _confirmarRemover(ex);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'editar',
                  child: Row(children: [
                    Icon(Icons.edit_outlined,
                        color: context.c.textPrimary, size: 20),
                    const SizedBox(width: 12),
                    Text('Editar', style: TextStyle(color: context.c.textPrimary)),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'excluir',
                  child: Row(children: [
                    Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                    SizedBox(width: 12),
                    Text('Excluir', style: TextStyle(color: AppColors.danger)),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
