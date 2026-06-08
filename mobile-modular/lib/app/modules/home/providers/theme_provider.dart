import 'package:flutter/material.dart';

import 'package:gymconnect/app/core/storage/storage_service.dart';

/// Gerencia o tema global (claro/escuro/sistema) com persistência.
///
/// Padrão: **claro** (identidade oficial do GymConnect). A escolha é salva
/// em SharedPreferences e restaurada ao reabrir o app.
class ThemeProvider extends ChangeNotifier {
  final StorageService _storage;
  ThemeProvider(this._storage);

  ThemeMode _modo = ThemeMode.light;
  ThemeMode get modo => _modo;

  bool get isEscuro => _modo == ThemeMode.dark;

  /// Carrega a preferência salva (chamado no início do app).
  Future<void> carregar() async {
    _modo = await _storage.lerThemeMode();
    notifyListeners();
  }

  Future<void> definir(ThemeMode modo) async {
    if (_modo == modo) return;
    _modo = modo;
    notifyListeners();
    await _storage.salvarThemeMode(modo);
  }

  /// Alterna entre claro e escuro (usado no switch das Configurações).
  Future<void> alternar(bool escuro) =>
      definir(escuro ? ThemeMode.dark : ThemeMode.light);
}
