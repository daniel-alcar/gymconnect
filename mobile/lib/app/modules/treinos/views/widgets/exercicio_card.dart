import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:gymconnect/app/core/theme/app_colors.dart';
import 'package:gymconnect/app/modules/treinos/models/cronograma_exercicio.dart';
import 'package:gymconnect/app/modules/treinos/views/widgets/youtube_video_player.dart';

/// Card de um exercício do treino: dados, vídeo embutido e "marcar feito".
class ExercicioCard extends StatefulWidget {
  final CronogramaExercicio exercicio;
  final bool feito;
  final bool processando;
  final Future<void> Function() onMarcarFeito;
  final VoidCallback? onDesmarcar;

  const ExercicioCard({
    super.key,
    required this.exercicio,
    required this.feito,
    required this.processando,
    required this.onMarcarFeito,
    this.onDesmarcar,
  });

  @override
  State<ExercicioCard> createState() => _ExercicioCardState();
}

class _ExercicioCardState extends State<ExercicioCard> {
  bool _reproduzir = false;
  Duration? _videoPosition;

  void _concluir() {
    widget.onMarcarFeito();
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    exercicio?.nome ?? 'Exercício',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.c.textPrimary,
                    ),
                  ),
                ),
                if (ex.carga != null) _Pill('Carga: ${ex.carga}kg'),
              ],
            ),
            const SizedBox(height: 14),

            // Vídeo: thumbnail imediata + play em 1 clique (autoplay).
            if (exercicio?.temVideo ?? false) ...[
              if (_reproduzir)
                YoutubeVideoPlayer(
                  url: exercicio!.linkYoutube!,
                  autoPlay: true,
                  initialPosition: _videoPosition,
                  onNeedsPause: (pos) => setState(() {
                    _videoPosition = pos;
                    _reproduzir = false;
                  }),
                )
              else
                _VideoThumb(
                  url: exercicio!.linkYoutube!,
                  onPlay: () => setState(() => _reproduzir = true),
                ),
              const SizedBox(height: 14),
            ],

            // Descrição / execução correta (definida pelo professor).
            if (exercicio?.temDescricao ?? false) ...[
              _DescricaoExercicio(texto: exercicio!.descricao!),
              const SizedBox(height: 14),
            ],

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


            SizedBox(
              width: double.infinity,
              child: widget.feito
                  ? Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
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
                        ),
                        if (widget.onDesmarcar != null)
                          TextButton.icon(
                            onPressed:
                                widget.processando ? null : widget.onDesmarcar,
                            icon: const Icon(Icons.undo, size: 18),
                            label: const Text('Desmarcar'),
                          ),
                      ],
                    )
                  : FilledButton(
                      onPressed: widget.processando ? null : _concluir,
                      child: widget.processando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.onAmarelo,
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

/// Bloco expansível com a descrição/execução correta do exercício.
class _DescricaoExercicio extends StatefulWidget {
  final String texto;
  const _DescricaoExercicio({required this.texto});

  @override
  State<_DescricaoExercicio> createState() => _DescricaoExercicioState();
}

class _DescricaoExercicioState extends State<_DescricaoExercicio> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.c.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.c.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          initiallyExpanded: false,
          onExpansionChanged: (v) => setState(() => _expandido = v),
          leading: const Icon(Icons.menu_book_outlined,
              color: AppColors.amareloPressed),
          title: Text(
            'Como executar',
            style: TextStyle(
              color: context.c.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          trailing: Icon(
            _expandido ? Icons.expand_less : Icons.expand_more,
            color: context.c.textSecondary,
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.texto,
                style: TextStyle(
                  color: context.c.textSecondary,
                  height: 1.4,
                  fontSize: 14,
                ),
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
        color: AppColors.amarelo.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: AppColors.amareloPressed,
          fontWeight: FontWeight.w700,
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
        color: context.c.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.c.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 14, color: context.c.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: context.c.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              color: context.c.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thumbnail do YouTube exibida de imediato, com botão de play sobreposto.
class _VideoThumb extends StatelessWidget {
  final String url;
  final VoidCallback onPlay;
  const _VideoThumb({required this.url, required this.onPlay});

  static String? _extractId(String url) {
    final id = YoutubePlayer.convertUrlToId(url);
    if (id != null) return id;
    final match = RegExp(r'youtube\.com/shorts/([a-zA-Z0-9_-]{11})').firstMatch(url);
    return match?.group(1);
  }

  static bool _isShorts(String url) => url.contains('youtube.com/shorts/');

  @override
  Widget build(BuildContext context) {
    final id = _extractId(url);
    final isShorts = _isShorts(url);
    final thumb =
        id != null ? 'https://img.youtube.com/vi/$id/hqdefault.jpg' : null;

    return InkWell(
      onTap: onPlay,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: isShorts ? 9 / 16 : 16 / 9,
              child: thumb != null
                  ? Image.network(
                      thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.black),
                      loadingBuilder: (ctx, child, progress) =>
                          progress == null
                              ? child
                              : Container(color: Colors.black12),
                    )
                  : Container(color: Colors.black),
            ),
            // Camada escura + ícone de play (sinaliza que há vídeo).
            Container(color: Colors.black.withValues(alpha: 0.25)),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.amarelo,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.play_arrow,
                  color: AppColors.onAmarelo, size: 34),
            ),
          ],
        ),
      ),
    );
  }
}
