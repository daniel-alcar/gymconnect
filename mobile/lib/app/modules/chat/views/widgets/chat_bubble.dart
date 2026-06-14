import 'package:flutter/material.dart';

import 'package:gymconnect/app/core/theme/app_colors.dart';
import 'package:gymconnect/app/modules/chat/models/chat_message.dart';
import 'package:gymconnect/app/shared/widgets/app_logo.dart';

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
      fundo = AppColors.danger.withValues(alpha: 0.14);
      texto = AppColors.danger;
    } else if (doUsuario) {
      fundo = AppColors.amarelo;
      texto = AppColors.onAmarelo;
    } else {
      fundo = context.c.surface;
      texto = context.c.textPrimary;
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
          border: doUsuario ? null : Border.all(color: context.c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!doUsuario && !mensagem.erro) ...[
              const ImageIcon(
                AssetImage(AppLogoAssets.giaIcon),
                size: 18,
                color: AppColors.amareloPressed,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(child: Text(mensagem.texto, style: TextStyle(color: texto))),
          ],
        ),
      ),
    );
  }
}
