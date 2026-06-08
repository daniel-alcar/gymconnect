import 'package:flutter/material.dart';

/// Helpers para exibir Snackbars padronizados.
class SnackbarHelper {
  SnackbarHelper._();

  static void sucesso(BuildContext context, String mensagem) {
    _show(context, mensagem, Colors.green.shade700, Icons.check_circle);
  }

  static void erro(BuildContext context, String mensagem) {
    _show(context, mensagem, Colors.red.shade700, Icons.error_outline);
  }

  static void info(BuildContext context, String mensagem) {
    _show(context, mensagem, Colors.blueGrey.shade800, Icons.info_outline);
  }

  static void _show(
    BuildContext context,
    String mensagem,
    Color cor,
    IconData icone,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: cor,
          content: Row(
            children: [
              Icon(icone, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(mensagem)),
            ],
          ),
        ),
      );
  }
}
