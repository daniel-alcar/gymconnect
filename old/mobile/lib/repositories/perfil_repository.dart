import '../models/perfil.dart';
import '../services/perfil_service.dart';

/// Orquestra o salvamento do perfil do aluno.
class PerfilRepository {
  final PerfilService _perfilService;
  PerfilRepository(this._perfilService);

  Future<Perfil> salvar(Perfil perfil) => _perfilService.salvar(perfil);
}
