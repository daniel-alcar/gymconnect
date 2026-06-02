import 'package:flutter/material.dart';

/// Estado vazio reutilizável (ícone + título + descrição + ação opcional).
class EmptyState extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String? descricao;
  final Widget? acao;

  const EmptyState({
    super.key,
    required this.icone,
    required this.titulo,
    this.descricao,
    this.acao,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (descricao != null) ...[
              const SizedBox(height: 8),
              Text(
                descricao!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
            if (acao != null) ...[
              const SizedBox(height: 24),
              acao!,
            ],
          ],
        ),
      ),
    );
  }
}
