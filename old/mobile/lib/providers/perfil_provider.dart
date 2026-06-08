import 'package:flutter/foundation.dart';

import '../models/perfil.dart';
import '../repositories/perfil_repository.dart';

/// Estado da tela de Perfil.
class PerfilProvider extends ChangeNotifier {
  final PerfilRepository _repository;
  PerfilProvider(this._repository);

  bool _salvando = false;
  bool get salvando => _salvando;

  /// Salva o perfil. Lança [AppException] em falha para a UI tratar.
  Future<Perfil> salvar(Perfil perfil) async {
    _salvando = true;
    notifyListeners();
    try {
      return await _repository.salvar(perfil);
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }
}
