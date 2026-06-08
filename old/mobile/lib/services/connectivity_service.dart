import 'package:connectivity_plus/connectivity_plus.dart';

/// Serviço de conectividade (wrapper sobre connectivity_plus).
///
/// Usado pelo fluxo Offline-First para decidir entre buscar do backend
/// ou servir o cache local, e para disparar sincronização ao reconectar.
class ConnectivityService {
  final Connectivity _connectivity;
  ConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  /// `true` se há alguma interface de rede ativa (wifi/celular/ethernet).
  Future<bool> isOnline() async {
    final resultados = await _connectivity.checkConnectivity();
    return resultados.any((r) => r != ConnectivityResult.none);
  }

  /// Emite eventos sempre que o estado de conectividade muda.
  Stream<bool> get onStatusChange => _connectivity.onConnectivityChanged
      .map((rs) => rs.any((r) => r != ConnectivityResult.none));
}
