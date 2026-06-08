import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gymconnect/app/core/constants/app_constants.dart';
import 'package:gymconnect/app/modules/auth/models/usuario.dart';

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

  // ----- Preferência de tema (não é apagada no logout) -----
  Future<void> salvarThemeMode(ThemeMode modo) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.themeKey, modo.name);
  }

  Future<ThemeMode> lerThemeMode() async {
    final prefs = await _instance;
    final raw = prefs.getString(AppConstants.themeKey);
    return ThemeMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => ThemeMode.light, // padrão: claro (identidade oficial)
    );
  }

  // ----- Foto de perfil (path local, por usuário) -----
  Future<void> salvarFotoPerfil(int idUsuario, String path) async {
    final prefs = await _instance;
    await prefs.setString('${AppConstants.fotoPerfilPrefix}$idUsuario', path);
  }

  Future<String?> lerFotoPerfil(int idUsuario) async {
    final prefs = await _instance;
    return prefs.getString('${AppConstants.fotoPerfilPrefix}$idUsuario');
  }

  Future<void> removerFotoPerfil(int idUsuario) async {
    final prefs = await _instance;
    await prefs.remove('${AppConstants.fotoPerfilPrefix}$idUsuario');
  }

  // ----- Atividades recentes (JSON, por usuário) -----
  Future<void> salvarAtividades(int idUsuario, String jsonList) async {
    final prefs = await _instance;
    await prefs.setString('${AppConstants.atividadesPrefix}$idUsuario', jsonList);
  }

  Future<String?> lerAtividades(int idUsuario) async {
    final prefs = await _instance;
    return prefs.getString('${AppConstants.atividadesPrefix}$idUsuario');
  }

  // ----- Limpeza (logout) — preserva a preferência de tema -----
  Future<void> limpar() async {
    final prefs = await _instance;
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }
}
