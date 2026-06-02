import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/cronograma_exercicio.dart';
import '../../../utils/validators.dart';
import 'youtube_video_player.dart';

/// Card de um exercício do treino: dados, vídeo embutido, peso e "marcar feito".
class ExercicioCard extends StatefulWidget {
  final CronogramaExercicio exercicio;
  final bool feito;
  final bool processando;
  final Future<void> Function(double? peso) onMarcarFeito;

  const ExercicioCard({
    super.key,
    required this.exercicio,
    required this.feito,
    required this.processando,
    required this.onMarcarFeito,
  });

  @override
  State<ExercicioCard> createState() => _ExercicioCardState();
}

class _ExercicioCardState extends State<ExercicioCard> {
  final _pesoController = TextEditingController();
  bool _mostrarVideo = false;
  String? _erroPeso;

  @override
  void dispose() {
    _pesoController.dispose();
    super.dispose();
  }

  void _concluir() {
    final texto = _pesoController.text.trim();
    final erro = Validators.pesoOpcional(texto);
    setState(() => _erroPeso = erro);
    if (erro != null) return;

    final peso =
        texto.isEmpty ? null : double.tryParse(texto.replaceAll(',', '.'));
    widget.onMarcarFeito(peso);
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercicio;
    final exercicio = ex.exercicio;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: nome + pill de carga
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    exercicio?.nome ?? 'Exercício',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (ex.carga != null) _Pill('Carga: ${ex.carga}kg'),
              ],
            ),
            const SizedBox(height: 14),

            // Vídeo embutido (youtube_player_flutter)
            if (exercicio?.temVideo ?? false) ...[
              if (_mostrarVideo)
                YoutubeVideoPlayer(url: exercicio!.linkYoutube!)
              else
                _VideoThumb(
                    onPlay: () => setState(() => _mostrarVideo = true)),
              const SizedBox(height: 14),
            ],

            // Caixas de séries / repetições
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    icone: Icons.format_list_numbered,
                    label: 'SÉRIES',
                    valor: ex.serie?.toString() ?? '-',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBox(
                    icone: Icons.repeat,
                    label: 'REPS',
                    valor: ex.repeticao?.toString() ?? '-',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (!widget.feito) ...[
              TextField(
                controller: _pesoController,
                enabled: !widget.processando,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Peso Atual (kg)',
                  hintText: 'opcional',
                  errorText: _erroPeso,
                  prefixIcon: const Icon(Icons.monitor_weight_outlined),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Botão Marcar como Feito (tonal claro) / estado concluído
            SizedBox(
              width: double.infinity,
              child: widget.feito
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle,
                              color: AppColors.success, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Concluído',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : FilledButton(
                      onPressed: widget.processando ? null : _concluir,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primarySoft,
                        foregroundColor: const Color(0xFF1A2A52),
                      ),
                      child: widget.processando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF1A2A52),
                              ),
                            )
                          : const Text('Marcar como Feito'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String texto;
  const _Pill(this.texto);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: AppColors.wordmark,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icone;
  final String label;
  final String valor;
  const _StatBox(
      {required this.icone, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoThumb extends StatelessWidget {
  final VoidCallback onPlay;
  const _VideoThumb({required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPlay,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow,
                color: Color(0xFF111A2E), size: 32),
          ),
        ),
      ),
    );
  }
}
