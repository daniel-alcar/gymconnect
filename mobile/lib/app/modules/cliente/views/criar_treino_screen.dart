import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gymconnect/app/core/errors/app_exception.dart';
import 'package:gymconnect/app/core/theme/app_theme.dart';
import 'package:gymconnect/app/modules/treinos/models/dia_semana.dart';
import 'package:gymconnect/app/modules/treinos/models/exercicio.dart';
import 'package:gymconnect/app/modules/treinos/models/exercicio_form.dart';
import 'package:gymconnect/app/modules/auth/models/usuario.dart';
import 'package:gymconnect/app/modules/cliente/providers/cliente_provider.dart';
import 'package:gymconnect/app/shared/utils/snackbar_helper.dart';

/// CLIENTE – Formulário de criação de treino para um aluno.
class CriarTreinoScreen extends StatefulWidget {
  const CriarTreinoScreen({super.key});

  @override
  State<CriarTreinoScreen> createState() => _CriarTreinoScreenState();
}

class _CriarTreinoScreenState extends State<CriarTreinoScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _alunoId;
  DiaSemana? _dia;
  final List<ExercicioForm> _exercicios = [ExercicioForm()];

  @override
  void initState() {
    super.initState();
    // Garante alunos e a biblioteca de exercícios carregados.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ClienteProvider>();
      if (p.alunos.isEmpty) p.carregarAlunos();
      if (p.exercicios.isEmpty) p.carregarExercicios();
    });
  }

  void _adicionarExercicio() =>
      setState(() => _exercicios.add(ExercicioForm()));

  void _removerExercicio(int i) {
    if (_exercicios.length == 1) return;
    setState(() => _exercicios.removeAt(i));
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_alunoId == null) {
      SnackbarHelper.erro(context, 'Selecione um aluno.');
      return;
    }
    if (_dia == null) {
      SnackbarHelper.erro(context, 'Selecione o dia da semana.');
      return;
    }
    FocusScope.of(context).unfocus();

    try {
      await context.read<ClienteProvider>().criarTreino(
            idAluno: _alunoId!,
            diaSemana: _dia!,
            exercicios: _exercicios,
          );
      if (mounted) {
        SnackbarHelper.sucesso(context, 'Treino criado com sucesso!');
        Navigator.of(context).pop();
      }
    } on AppException catch (e) {
      if (mounted) SnackbarHelper.erro(context, e.message);
    } catch (_) {
      if (mounted) SnackbarHelper.erro(context, 'Erro ao criar treino.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();
    final salvando = provider.salvando;

    return Scaffold(
      appBar: AppBar(title: const Text('Criar Treino')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Aluno
              DropdownButtonFormField<int>(
                initialValue: _alunoId,
                isExpanded: true,
                dropdownColor: context.c.surface,
                decoration: const InputDecoration(
                  labelText: 'Aluno *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                hint: const Text('Selecione...'),
                items: provider.alunos
                    .map((Usuario a) => DropdownMenuItem(
                          value: a.idUsuario,
                          child: Text(a.nome,
                              style: TextStyle(color: context.c.textPrimary)),
                        ))
                    .toList(),
                onChanged:
                    salvando ? null : (v) => setState(() => _alunoId = v),
                validator: (v) => v == null ? 'Selecione um aluno' : null,
              ),
              const SizedBox(height: 16),

              // Dia da semana
              DropdownButtonFormField<DiaSemana>(
                initialValue: _dia,
                isExpanded: true,
                dropdownColor: context.c.surface,
                decoration: const InputDecoration(
                  labelText: 'Dia da semana *',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                hint: const Text('Selecione...'),
                items: DiaSemana.values
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d.label,
                              style: TextStyle(color: context.c.textPrimary)),
                        ))
                    .toList(),
                onChanged: salvando ? null : (v) => setState(() => _dia = v),
                validator: (v) => v == null ? 'Selecione o dia' : null,
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exercícios',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.c.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: (salvando || provider.exercicios.isEmpty)
                        ? null
                        : _adicionarExercicio,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (provider.exercicios.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.amareloPressed),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Nenhum exercício na biblioteca. Cadastre exercícios '
                            'na aba "Exercícios" para montar o treino.',
                            style: TextStyle(color: context.c.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._exercicios.asMap().entries.map(
                      (entry) => _ExercicioFormCard(
                        indice: entry.key,
                        form: entry.value,
                        exerciciosBiblioteca: provider.exercicios,
                        podeRemover: _exercicios.length > 1,
                        habilitado: !salvando,
                        onRemover: () => _removerExercicio(entry.key),
                        onSelecionar: (id) =>
                            setState(() => entry.value.idExercicio = id),
                      ),
                    ),

              const SizedBox(height: 16),
              FilledButton(
                onPressed: salvando ? null : _salvar,
                child: salvando
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: AppColors.onAmarelo),
                      )
                    : const Text('Salvar Treino'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExercicioFormCard extends StatelessWidget {
  final int indice;
  final ExercicioForm form;
  final List<Exercicio> exerciciosBiblioteca;
  final bool podeRemover;
  final bool habilitado;
  final VoidCallback onRemover;
  final ValueChanged<int?> onSelecionar;

  const _ExercicioFormCard({
    required this.indice,
    required this.form,
    required this.exerciciosBiblioteca,
    required this.podeRemover,
    required this.habilitado,
    required this.onRemover,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    // Garante que o valor selecionado ainda existe na lista.
    final ids = exerciciosBiblioteca.map((e) => e.idExercicio).toSet();
    final valorAtual = ids.contains(form.idExercicio) ? form.idExercicio : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Exercício ${indice + 1}',
                    style: const TextStyle(
                        color: AppColors.amareloPressed,
                        fontWeight: FontWeight.w700)),
                if (podeRemover)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.danger),
                    onPressed: habilitado ? onRemover : null,
                  ),
              ],
            ),
            DropdownButtonFormField<int>(
              initialValue: valorAtual,
              isExpanded: true,
              dropdownColor: context.c.surface,
              decoration: const InputDecoration(
                labelText: 'Exercício *',
                prefixIcon: Icon(Icons.fitness_center),
              ),
              hint: const Text('Selecione um exercício'),
              items: exerciciosBiblioteca
                  .map((e) => DropdownMenuItem(
                        value: e.idExercicio,
                        child: Text(
                          e.nome,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: context.c.textPrimary),
                        ),
                      ))
                  .toList(),
              onChanged: habilitado ? onSelecionar : null,
              validator: (v) => v == null ? 'Selecione um exercício' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: form.series,
                    enabled: habilitado,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => form.series = v,
                    decoration: const InputDecoration(labelText: 'Séries'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: form.repeticoes,
                    enabled: habilitado,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => form.repeticoes = v,
                    decoration: const InputDecoration(labelText: 'Repetições'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: form.carga,
              enabled: habilitado,
              keyboardType: TextInputType.number,
              onChanged: (v) => form.carga = v,
              decoration: const InputDecoration(labelText: 'Carga (kg)'),
            ),
          ],
        ),
      ),
    );
  }
}
