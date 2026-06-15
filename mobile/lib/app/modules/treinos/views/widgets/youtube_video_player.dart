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
  bool _shortsVideo = false;

  String? _extractVideoId(String url) {
    final id = YoutubePlayer.convertUrlToId(url);
    if (id != null) return id;
    // YouTube Shorts: youtube.com/shorts/VIDEO_ID
    final match = RegExp(r'youtube\.com/shorts/([a-zA-Z0-9_-]{11})').firstMatch(url);
    return match?.group(1);
  }

  @override
  void initState() {
    super.initState();
    _videoId = _extractVideoId(widget.url);
    _shortsVideo = widget.url.contains('youtube.com/shorts/');
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
        aspectRatio: _shortsVideo ? 9 / 16 : 16 / 9,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
