import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gymconnect/app/core/errors/app_exception.dart';
import 'package:gymconnect/app/core/theme/app_theme.dart';
import 'package:gymconnect/app/modules/auth/models/usuario.dart';
import 'package:gymconnect/app/modules/cliente/providers/cliente_provider.dart';
import 'package:gymconnect/app/shared/utils/snackbar_helper.dart';
import 'package:gymconnect/app/shared/widgets/app_logo.dart';
import 'package:gymconnect/app/shared/widgets/empty_state.dart';
import 'package:gymconnect/app/shared/widgets/loading_indicator.dart';

/// CLIENTE – Alunos: listar e remover.
class AlunosScreen extends StatefulWidget {
  const AlunosScreen({super.key});

  @override
  State<AlunosScreen> createState() => _AlunosScreenState();
}

class _AlunosScreenState extends State<AlunosScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.toLowerCase().trim()),
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ClienteProvider>().carregarAlunos(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregar() => context.read<ClienteProvider>().carregarAlunos();

  List<Usuario> _filtrados(List<Usuario> todos) => _query.isEmpty
      ? todos
      : todos
          .where((a) =>
              a.nome.toLowerCase().contains(_query) ||
              a.email.toLowerCase().contains(_query))
          .toList();

  Widget _searchBar() => TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar aluno...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          isDense: true,
        ),
      );

  Future<void> _confirmarRemover(Usuario aluno) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.c.surface,
        title: const Text('Remover aluno'),
        content: Text(
            'Deseja remover "${aluno.nome}"? Esta ação não pode ser desfeita.'),
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
    if (confirmar == true) {
      if (!mounted) return;
      try {
        await context.read<ClienteProvider>().removerAluno(aluno.idUsuario);
        if (mounted) SnackbarHelper.sucesso(context, 'Aluno removido.');
      } on AppException catch (e) {
        if (mounted) SnackbarHelper.erro(context, e.message);
      } catch (_) {
        if (mounted) SnackbarHelper.erro(context, 'Erro ao remover aluno.');
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
            Text('Alunos',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
          ],
        ),
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
    if (provider.carregandoAlunos && provider.alunos.isEmpty) {
      return const LoadingIndicator(mensagem: 'Carregando alunos...');
    }
    if (provider.erroAlunos != null && provider.alunos.isEmpty) {
      return ListView(children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        EmptyState(
          icone: Icons.cloud_off,
          titulo: 'Não foi possível carregar',
          descricao: provider.erroAlunos,
          acao: FilledButton.icon(
            onPressed: _carregar,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ),
      ]);
    }
    if (provider.alunos.isEmpty) {
      return ListView(children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.16),
        const EmptyState(
          icone: Icons.groups,
          titulo: 'Nenhum aluno cadastrado',
          descricao:
              'Os alunos aparecem aqui quando criam conta como "Aluno".',
        ),
      ]);
    }

    final filtrados = _filtrados(provider.alunos);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: _searchBar(),
        ),
        Expanded(
          child: filtrados.isEmpty
              ? ListView(children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.16),
                  EmptyState(
                    icone: Icons.search_off,
                    titulo: 'Nenhum resultado',
                    descricao: 'Nenhum aluno encontrado para "$_query".',
                  ),
                ])
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: filtrados.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final aluno = filtrados[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.amarelo,
                          child: Text(
                            aluno.nome.isNotEmpty
                                ? aluno.nome[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: AppColors.onAmarelo,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text(aluno.nome,
                            style: TextStyle(
                                color: context.c.textPrimary,
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(aluno.email,
                            style:
                                TextStyle(color: context.c.textSecondary)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.danger),
                          onPressed: () => _confirmarRemover(aluno),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
