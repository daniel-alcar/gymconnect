import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/chat_message.dart';

/// Balão de mensagem do chat (usuário à direita, IA à esquerda).
class ChatBubble extends StatelessWidget {
  final ChatMessage mensagem;
  const ChatBubble({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    final doUsuario = mensagem.doUsuario;

    final Color fundo;
    final Color texto;
    if (mensagem.erro) {
      fundo = AppColors.danger.withValues(alpha: 0.18);
      texto = const Color(0xFFFFB4B4);
    } else if (doUsuario) {
      fundo = AppColors.primary;
      texto = Colors.white;
    } else {
      fundo = AppColors.surface;
      texto = AppColors.textPrimary;
    }

    return Align(
      alignment: doUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(doUsuario ? 16 : 4),
            bottomRight: Radius.circular(doUsuario ? 4 : 16),
          ),
          border: doUsuario
              ? null
              : Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!doUsuario && !mensagem.erro) ...[
              const Icon(Icons.smart_toy, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
            ],
            Flexible(child: Text(mensagem.texto, style: TextStyle(color: texto))),
          ],
        ),
      ),
    );
  }
}
