import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../models/cronograma_exercicio.dart';
import '../../providers/auth_provider.dart';
import '../../providers/treino_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import 'widgets/exercicio_card.dart';

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
        SnackbarHelper.sucesso(
          context,
          peso != null
              ? 'Treino concluído e peso registrado!'
              : 'Treino marcado como feito!',
        );
      }
    } on AppException catch (e) {
      if (mounted) SnackbarHelper.erro(context, e.message);
    } catch (_) {
      if (mounted) SnackbarHelper.erro(context, 'Erro ao registrar treino.');
    } finally {
      if (mounted) setState(() => _processandoId = null);
    }
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
                exercicio: ex,
                feito: provider.exercicioFeito(ex.idCronogramaExercicio),
                processando: _processandoId == ex.idCronogramaExercicio,
                onMarcarFeito: (peso) => _marcarFeito(ex, peso),
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
