import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gymconnect/app/core/theme/app_theme.dart';
import 'package:gymconnect/app/modules/chat/providers/chat_provider.dart';
import 'package:gymconnect/app/shared/widgets/app_logo.dart';
import 'package:gymconnect/app/modules/chat/views/widgets/chat_bubble.dart';

/// TELA 7 – GIA (GymConnect IA). Conversa com o assistente (Gemini via backend).
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    _controller.clear();
    await context.read<ChatProvider>().enviar(texto);
    _rolarParaFim();
  }

  void _rolarParaFim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          children: [
            AppLogoMark(size: 30),
            SizedBox(width: 10),
            Text('GIA',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: provider.vazio
                  ? const _BoasVindasGia()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.mensagens.length,
                      itemBuilder: (_, i) =>
                          ChatBubble(mensagem: provider.mensagens[i]),
                    ),
            ),
            if (provider.enviando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('A IA está digitando...'),
                  ],
                ),
              ),
            _buildAreaEnvio(provider.enviando),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaEnvio(bool enviando) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: context.c.surface,
        border: Border(top: BorderSide(color: context.c.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => enviando ? null : _enviar(),
              decoration: const InputDecoration(
                hintText: 'Digite sua mensagem...',
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: enviando ? null : _enviar,
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
              minimumSize: const Size(56, 56),
            ),
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

/// Tela inicial da GIA (sem mensagens): mascote em destaque + boas-vindas.
class _BoasVindasGia extends StatelessWidget {
  const _BoasVindasGia();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GiaMascot(height: 170),
            const SizedBox(height: 8),
            Text(
              'Converse com a GIA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.c.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A Inteligência Artificial do GymConnect.\n'
              'Pergunte sobre seu treino, séries, cargas e dicas.\n'
              'Ex.: "Quantas séries faço no supino?"',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.c.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
