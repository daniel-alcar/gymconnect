import 'package:flutter/material.dart';

/// Indicador de carregamento centralizado e reutilizável.
class LoadingIndicator extends StatelessWidget {
  final String? mensagem;
  const LoadingIndicator({super.key, this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (mensagem != null) ...[
            const SizedBox(height: 16),
            Text(mensagem!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
