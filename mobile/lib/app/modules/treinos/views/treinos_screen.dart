import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gymconnect/app/core/errors/app_exception.dart';
import 'package:gymconnect/app/core/theme/app_theme.dart';
import 'package:gymconnect/app/modules/home/models/atividade.dart';
import 'package:gymconnect/app/modules/treinos/models/cronograma_exercicio.dart';
import 'package:gymconnect/app/modules/home/providers/atividade_provider.dart';
import 'package:gymconnect/app/modules/auth/providers/auth_provider.dart';
import 'package:gymconnect/app/modules/treinos/providers/treino_provider.dart';
import 'package:gymconnect/app/shared/utils/snackbar_helper.dart';
import 'package:gymconnect/app/shared/widgets/app_logo.dart';
import 'package:gymconnect/app/shared/widgets/empty_state.dart';
import 'package:gymconnect/app/shared/widgets/loading_indicator.dart';
import 'package:gymconnect/app/modules/treinos/views/widgets/exercicio_card.dart';

/// TELA 5 – TREINOS. Lista os treinos do aluno agrupados por dia da semana.
class TreinosScreen extends StatefulWidget {
  const TreinosScreen({super.key});

  @override
  State<TreinosScreen> createState() => _TreinosScreenState();
}

class _TreinosScreenState extends State<TreinosScreen> {
  int? _processandoId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    final id = context.read<AuthProvider>().usuario?.idUsuario;
    if (id != null) {
      await context.read<TreinoProvider>().carregar(id);
    }
  }

  Future<void> _marcarFeito(CronogramaExercicio ex, double? peso) async {
    if (ex.idCronograma == null || ex.idCronogramaExercicio == null) {
      SnackbarHelper.erro(context, 'Treino sem cronograma associado.');
      return;
    }
    setState(() => _processandoId = ex.idCronogramaExercicio);
    try {
      await context.read<TreinoProvider>().marcarComoFeito(
            idCronogramaExercicio: ex.idCronogramaExercicio!,
            idCronograma: ex.idCronograma!,
            peso: peso,
          );
      if (mounted) {
        // Registra no histórico "Atividade Recente".
        final id = context.read<AuthProvider>().usuario?.idUsuario;
        if (id != null) {
          context.read<AtividadeProvider>().registrar(
                id,
                Atividade.exercicio(
                  ex.exercicio?.nome ?? 'Exercício',
                  peso: peso,
                ),
              );
        }
        SnackbarHelper.sucesso(
          context,
          peso != null
              ? 'Exercício concluído e peso registrado!'
              : 'Exercício marcado como feito!',
        );
      }
    } on AppException catch (e) {
      if (mounted) SnackbarHelper.erro(context, e.message);
    } catch (_) {
      if (mounted) SnackbarHelper.erro(context, 'Erro ao registrar exercício.');
    } finally {
      if (mounted) setState(() => _processandoId = null);
    }
  }

  Future<void> _concluirTreino(String diaTitulo) async {
    final id = context.read<AuthProvider>().usuario?.idUsuario;
    final atividadeProv = context.read<AtividadeProvider>();
    final treinoProv = context.read<TreinoProvider>();
    if (id != null) {
      await atividadeProv.registrar(id, Atividade.treino(diaTitulo));
    }
    await treinoProv.concluirDia(diaTitulo);
    if (mounted) {
      SnackbarHelper.sucesso(context, 'Treino "$diaTitulo" concluído! 💪');
    }
  }

  Future<void> _desmarcarTreino(String diaTitulo) async {
    await context.read<TreinoProvider>().desmarcarDia(diaTitulo);
  }

  Future<void> _desmarcarExercicio(CronogramaExercicio ex) async {
    if (ex.idCronogramaExercicio == null) return;
    await context
        .read<TreinoProvider>()
        .desmarcarExercicio(ex.idCronogramaExercicio!);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TreinoProvider>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const AppLogo(height: 30),
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

  Widget _buildBody(TreinoProvider provider) {
    if (provider.carregando && provider.dias.isEmpty) {
      return const LoadingIndicator(mensagem: 'Carregando treinos...');
    }

    if (provider.erro != null && provider.dias.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          EmptyState(
            icone: Icons.cloud_off,
            titulo: 'Não foi possível carregar',
            descricao: provider.erro,
            acao: FilledButton.icon(
              onPressed: _carregar,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ),
        ],
      );
    }

    if (provider.vazio) {
      return ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          const EmptyState(
            icone: Icons.fitness_center,
            titulo: 'Nenhum treino cadastrado',
            descricao:
                'Quando seu personal montar seu cronograma, ele aparecerá aqui.',
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: provider.dias.length,
      itemBuilder: (context, index) {
        final dia = provider.dias[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'TREINO DO DIA',
                style: TextStyle(
                  color: AppColors.amareloPressed,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                dia.titulo,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: context.c.textPrimary,
                ),
              ),
            ),
            ...dia.exercicios.map(
              (ex) => ExercicioCard(
                key: ValueKey(ex.idCronogramaExercicio ?? ex.exercicio?.idExercicio),
                exercicio: ex,
                feito: provider.exercicioFeito(ex.idCronogramaExercicio),
                processando: _processandoId == ex.idCronogramaExercicio,
                onMarcarFeito: (peso) => _marcarFeito(ex, peso),
                onDesmarcar: () => _desmarcarExercicio(ex),
              ),
            ),
            const SizedBox(height: 4),
            _BotaoConcluirTreino(
              concluido: provider.diaConcluido(dia.titulo),
              onConcluir: () => _concluirTreino(dia.titulo),
              onDesmarcar: () => _desmarcarTreino(dia.titulo),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

/// Botão de "Concluir treino" do dia (vira selo quando concluído).
class _BotaoConcluirTreino extends StatelessWidget {
  final bool concluido;
  final VoidCallback onConcluir;
  final VoidCallback onDesmarcar;

  const _BotaoConcluirTreino({
    required this.concluido,
    required this.onConcluir,
    required this.onDesmarcar,
  });

  @override
  Widget build(BuildContext context) {
    if (concluido) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.success.withValues(alpha: 0.5)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, color: AppColors.success, size: 20),
                SizedBox(width: 8),
                Text('Treino concluído',
                    style: TextStyle(
                        color: AppColors.success, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onDesmarcar,
            icon: const Icon(Icons.undo, size: 18),
            label: const Text('Desmarcar treino'),
          ),
        ],
      );
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onConcluir,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Concluir treino'),
      ),
    );
  }
}
