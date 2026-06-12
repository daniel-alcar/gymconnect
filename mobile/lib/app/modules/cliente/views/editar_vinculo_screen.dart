import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:gymconnect/app/core/errors/app_exception.dart';
import 'package:gymconnect/app/core/theme/app_theme.dart';
import 'package:gymconnect/app/modules/treinos/models/cronograma_exercicio.dart';
import 'package:gymconnect/app/modules/treinos/models/dia_semana.dart';
import 'package:gymconnect/app/modules/treinos/models/exercicio.dart';
import 'package:gymconnect/app/modules/cliente/providers/cliente_provider.dart';
import 'package:gymconnect/app/shared/utils/snackbar_helper.dart';

/// CLIENTE – Edita um exercício do treino (PUT /cronogramaexercicio/{id}).
///
/// Permite trocar o exercício (biblioteca) e ajustar dia/série/repetição/carga.
class EditarVinculoScreen extends StatefulWidget {
  final CronogramaExercicio vinculo;
  const EditarVinculoScreen({super.key, required this.vinculo});

  @override
  State<EditarVinculoScreen> createState() => _EditarVinculoScreenState();
}

class _EditarVinculoScreenState extends State<EditarVinculoScreen> {
  final _formKey = GlobalKey<FormState>();
  late int? _idExercicio = widget.vinculo.exercicio?.idExercicio;
  late DiaSemana? _dia = widget.vinculo.diaSemana;
  late final _serieController =
      TextEditingController(text: widget.vinculo.serie?.toString() ?? '');
  late final _repController =
      TextEditingController(text: widget.vinculo.repeticao?.toString() ?? '');
  late final _cargaController =
      TextEditingController(text: widget.vinculo.carga?.toString() ?? '');
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ClienteProvider>();
      if (p.exercicios.isEmpty) p.carregarExercicios();
    });
  }

  @override
  void dispose() {
    _serieController.dispose();
    _repController.dispose();
    _cargaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_idExercicio == null) {
      SnackbarHelper.erro(context, 'Selecione um exercício.');
      return;
    }
    if (_dia == null) {
      SnackbarHelper.erro(context, 'Selecione o dia da semana.');
      return;
    }
    final idCronograma = widget.vinculo.idCronograma;
    final idVinculo = widget.vinculo.idCronogramaExercicio;
    if (idCronograma == null || idVinculo == null) {
      SnackbarHelper.erro(context, 'Vínculo inválido para edição.');
      return;
    }

    setState(() => _salvando = true);
    try {
      await context.read<ClienteProvider>().atualizarVinculo(
            idCronogramaExercicio: idVinculo,
            idCronograma: idCronograma,
            idExercicio: _idExercicio!,
            diaSemana: _dia,
            serie: int.tryParse(_serieController.text.trim()),
            repeticao: int.tryParse(_repController.text.trim()),
            carga: int.tryParse(_cargaController.text.trim()),
          );
      if (mounted) {
        SnackbarHelper.sucesso(context, 'Treino atualizado!');
        Navigator.of(context).pop();
      }
    } on AppException catch (e) {
      if (mounted) SnackbarHelper.erro(context, e.message);
    } catch (_) {
      if (mounted) SnackbarHelper.erro(context, 'Erro ao atualizar treino.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercicios = context.watch<ClienteProvider>().exercicios;
    // Garante que o exercício atual exista na lista do dropdown.
    final ids = exercicios.map((e) => e.idExercicio).toSet();
    final valorExercicio =
        (_idExercicio != null && ids.contains(_idExercicio)) ? _idExercicio : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar exercício')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<int>(
                initialValue: valorExercicio,
                isExpanded: true,
                dropdownColor: context.c.surface,
                decoration: const InputDecoration(
                  labelText: 'Exercício *',
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                hint: const Text('Selecione...'),
                items: exercicios
                    .map((Exercicio e) => DropdownMenuItem(
                          value: e.idExercicio,
                          child: Text(e.nome,
                              style: TextStyle(color: context.c.textPrimary)),
                        ))
                    .toList(),
                onChanged:
                    _salvando ? null : (v) => setState(() => _idExercicio = v),
                validator: (v) => v == null ? 'Selecione um exercício' : null,
              ),
              const SizedBox(height: 16),
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
                onChanged: _salvando ? null : (v) => setState(() => _dia = v),
                validator: (v) => v == null ? 'Selecione o dia' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _serieController,
                      enabled: !_salvando,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                      decoration: const InputDecoration(labelText: 'Séries'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _repController,
                      enabled: !_salvando,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                      decoration:
                          const InputDecoration(labelText: 'Repetições'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cargaController,
                enabled: !_salvando,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                decoration: const InputDecoration(labelText: 'Carga (kg)'),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: AppColors.onAmarelo),
                      )
                    : const Text('Salvar alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
