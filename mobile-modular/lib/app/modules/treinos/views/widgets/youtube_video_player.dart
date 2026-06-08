import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Player do YouTube embutido (reproduz dentro do app, sem abrir externamente).
///
/// Usa `youtube_player_flutter`. Extrai o ID do vídeo a partir da URL.
class YoutubeVideoPlayer extends StatefulWidget {
  final String url;

  /// Inicia a reprodução automaticamente ao montar (UX de 1 clique).
  final bool autoPlay;

  const YoutubeVideoPlayer({
    super.key,
    required this.url,
    this.autoPlay = false,
  });

  @override
  State<YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<YoutubeVideoPlayer> {
  YoutubePlayerController? _controller;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = YoutubePlayer.convertUrlToId(widget.url);
    if (_videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: _videoId!,
        flags: YoutubePlayerFlags(
          autoPlay: widget.autoPlay,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null || _controller == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.black12,
        child: const Row(
          children: [
            Icon(Icons.error_outline),
            SizedBox(width: 8),
            Expanded(child: Text('Link de vídeo inválido.')),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
