import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../models/usuario.dart';

/// Abstrai a persistência local (SharedPreferences) do token JWT e do usuário.
class StorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  // ----- Token JWT -----
  Future<void> salvarToken(String token) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> lerToken() async {
    final prefs = await _instance;
    return prefs.getString(AppConstants.tokenKey);
  }

  // ----- Usuário -----
  Future<void> salvarUsuario(Usuario usuario) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.userKey, jsonEncode(usuario.toJson()));
  }

  Future<Usuario?> lerUsuario() async {
    final prefs = await _instance;
    final raw = prefs.getString(AppConstants.userKey);
    if (raw == null) return null;
    try {
      return Usuario.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ----- Limpeza (logout) -----
  Future<void> limpar() async {
    final prefs = await _instance;
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }
}
