import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:gymconnect/app/modules/home/models/atividade.dart';
import 'package:gymconnect/app/core/storage/storage_service.dart';

/// Histórico local de "Atividade Recente" do aluno (persistido por usuário).
class AtividadeProvider extends ChangeNotifier {
  final StorageService _storage;
  AtividadeProvider(this._storage);

  static const int _maxItens = 30;

  int? _carregadoPara;
  List<Atividade> _itens = [];

  List<Atividade> get itens => List.unmodifiable(_itens);
  int? get carregadoPara => _carregadoPara;
  bool get vazio => _itens.isEmpty;

  /// Carrega o histórico do usuário (uma vez por id).
  Future<void> carregar(int idUsuario) async {
    if (_carregadoPara == idUsuario) return;
    _itens = [];
    _carregadoPara = idUsuario;
    notifyListeners();
    final raw = await _storage.lerAtividades(idUsuario);
    _itens = _decodificar(raw);
    notifyListeners();
  }

  /// Registra uma nova atividade no topo e persiste.
  Future<void> registrar(int idUsuario, Atividade atividade) async {
    _carregadoPara = idUsuario;
    _itens = [atividade, ..._itens];
    if (_itens.length > _maxItens) {
      _itens = _itens.sublist(0, _maxItens);
    }
    notifyListeners();
    await _persistir(idUsuario);
  }

  void limpar() {
    _itens = [];
    _carregadoPara = null;
    notifyListeners();
  }

  Future<void> _persistir(int idUsuario) async {
    final json = jsonEncode(_itens.map((a) => a.toJson()).toList());
    await _storage.salvarAtividades(idUsuario, json);
  }

  List<Atividade> _decodificar(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(Atividade.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
