import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:gymconnect/app/core/errors/app_exception.dart';
import 'package:gymconnect/app/core/theme/app_theme.dart';
import 'package:gymconnect/app/modules/treinos/models/dia_semana.dart';
import 'package:gymconnect/app/modules/treinos/models/exercicio.dart';
import 'package:gymconnect/app/modules/treinos/models/exercicio_form.dart';
import 'package:gymconnect/app/modules/auth/models/usuario.dart';
import 'package:gymconnect/app/modules/cliente/providers/cliente_provider.dart';
import 'package:gymconnect/app/shared/utils/snackbar_helper.dart';

class CriarTreinoScreen extends StatefulWidget {
  const CriarTreinoScreen({super.key});

  @override
  State<CriarTreinoScreen> createState() => _CriarTreinoScreenState();
}

class _CriarTreinoScreenState extends State<CriarTreinoScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _alunoId;
  final List<_DiaSection> _dias = [_DiaSection()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ClienteProvider>();
      if (p.alunos.isEmpty) p.carregarAlunos();
      p.carregarExercicios();
    });
  }

  void _adicionarDia() => setState(() => _dias.add(_DiaSection()));

  void _removerDia(int i) {
    if (_dias.length == 1) return;
    setState(() => _dias.removeAt(i));
  }

  void _adicionarExercicio(int diaIndex) =>
      setState(() => _dias[diaIndex].exercicios.add(ExercicioForm()));

  void _removerExercicio(int diaIndex, int exIndex) {
    if (_dias[diaIndex].exercicios.length == 1) return;
    setState(() => _dias[diaIndex].exercicios.removeAt(exIndex));
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_alunoId == null) {
      SnackbarHelper.erro(context, 'Selecione um aluno.');
      return;
    }
    FocusScope.of(context).unfocus();

    try {
      await context.read<ClienteProvider>().criarTreinoMultiplosDias(
            idAluno: _alunoId!,
            dias: _dias
                .map((d) => (dia: d.dia!, exercicios: d.exercicios))
                .toList(),
          );
      if (mounted) {
        SnackbarHelper.sucesso(
          context,
          _dias.length == 1
              ? 'Treino criado com sucesso!'
              : '${_dias.length} treinos criados com sucesso!',
        );
        Navigator.of(context).pop();
      }
    } on AppException catch (e) {
      if (mounted) SnackbarHelper.erro(context, e.message);
    } catch (_) {
      if (mounted) SnackbarHelper.erro(context, 'Erro ao criar treinos.');
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
              const SizedBox(height: 24),

              if (provider.exercicios.isEmpty && !provider.carregandoExercicios)
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
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
                ),

              ...List.generate(
                _dias.length,
                (i) => _DiaSectionCard(
                  key: ValueKey(i),
                  indice: i,
                  section: _dias[i],
                  exerciciosBiblioteca: provider.exercicios,
                  podeRemover: _dias.length > 1,
                  habilitado: !salvando,
                  onRemoverDia: () => _removerDia(i),
                  onAdicionarExercicio: () => _adicionarExercicio(i),
                  onRemoverExercicio: (exIdx) => _removerExercicio(i, exIdx),
                  onSelecionarDia: (dia) =>
                      setState(() => _dias[i].dia = dia),
                  onSelecionarExercicio: (exIdx, id) =>
                      setState(() => _dias[i].exercicios[exIdx].idExercicio = id),
                ),
              ),

              OutlinedButton.icon(
                onPressed: salvando ? null : _adicionarDia,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar dia'),
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
                    : const Text('Salvar Treinos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiaSection {
  DiaSemana? dia;
  final List<ExercicioForm> exercicios;
  _DiaSection() : exercicios = [ExercicioForm()];
}

class _DiaSectionCard extends StatelessWidget {
  final int indice;
  final _DiaSection section;
  final List<Exercicio> exerciciosBiblioteca;
  final bool podeRemover;
  final bool habilitado;
  final VoidCallback onRemoverDia;
  final VoidCallback onAdicionarExercicio;
  final ValueChanged<int> onRemoverExercicio;
  final ValueChanged<DiaSemana?> onSelecionarDia;
  final void Function(int exIdx, int? id) onSelecionarExercicio;

  const _DiaSectionCard({
    super.key,
    required this.indice,
    required this.section,
    required this.exerciciosBiblioteca,
    required this.podeRemover,
    required this.habilitado,
    required this.onRemoverDia,
    required this.onAdicionarExercicio,
    required this.onRemoverExercicio,
    required this.onSelecionarDia,
    required this.onSelecionarExercicio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Dia ${indice + 1}',
                  style: const TextStyle(
                    color: AppColors.amareloPressed,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (podeRemover)
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.danger),
                    onPressed: habilitado ? onRemoverDia : null,
                    tooltip: 'Remover dia',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<DiaSemana>(
              initialValue: section.dia,
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
              onChanged: habilitado ? onSelecionarDia : null,
              validator: (v) => v == null ? 'Selecione o dia' : null,
            ),
            const SizedBox(height: 16),

            if (exerciciosBiblioteca.isEmpty)
              Text(
                'Cadastre exercícios na aba "Exercícios" para adicioná-los aqui.',
                style: TextStyle(color: context.c.textSecondary, fontSize: 13),
              )
            else ...[
              ...section.exercicios.asMap().entries.map((entry) {
                final exIdx = entry.key;
                final form = entry.value;
                final ids =
                    exerciciosBiblioteca.map((e) => e.idExercicio).toSet();
                final valorAtual =
                    ids.contains(form.idExercicio) ? form.idExercicio : null;

                return Card(
                  color: context.c.surfaceAlt,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                initialValue: valorAtual,
                                isExpanded: true,
                                dropdownColor: context.c.surface,
                                decoration: InputDecoration(
                                  labelText: 'Exercício ${exIdx + 1} *',
                                  prefixIcon:
                                      const Icon(Icons.fitness_center),
                                  isDense: true,
                                ),
                                hint: const Text('Selecione'),
                                items: exerciciosBiblioteca
                                    .map((e) => DropdownMenuItem(
                                          value: e.idExercicio,
                                          child: Text(
                                            e.nome,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: context.c.textPrimary),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: habilitado
                                    ? (id) => onSelecionarExercicio(exIdx, id)
                                    : null,
                                validator: (v) => v == null
                                    ? 'Selecione um exercício'
                                    : null,
                              ),
                            ),
                            if (section.exercicios.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.danger, size: 20),
                                onPressed: habilitado
                                    ? () => onRemoverExercicio(exIdx)
                                    : null,
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: form.series,
                                enabled: habilitado,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                onChanged: (v) => form.series = v,
                                decoration: const InputDecoration(
                                    labelText: 'Séries', isDense: true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: form.repeticoes,
                                enabled: habilitado,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                onChanged: (v) => form.repeticoes = v,
                                decoration: const InputDecoration(
                                    labelText: 'Reps', isDense: true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: form.carga,
                                enabled: habilitado,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                onChanged: (v) => form.carga = v,
                                decoration: const InputDecoration(
                                    labelText: 'Carga (kg)', isDense: true),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              TextButton.icon(
                onPressed: habilitado ? onAdicionarExercicio : null,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar exercício'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
