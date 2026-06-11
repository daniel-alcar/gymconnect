import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gymconnect/app/modules/auth/providers/auth_provider.dart';
import 'package:gymconnect/app/modules/auth/views/cadastro_screen.dart';
import 'package:gymconnect/app/modules/auth/views/login_screen.dart';
import 'package:gymconnect/app/modules/auth/views/termos_screen.dart';
import 'package:gymconnect/app/modules/home/views/initial_screen.dart';
import 'package:gymconnect/app/modules/home/views/main_shell.dart';
import 'package:gymconnect/app/modules/home/views/splash_screen.dart';
import 'package:gymconnect/app/routes/route_names.dart';

/// Configuração do GoRouter com rotas protegidas baseadas no [AuthProvider].
class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final status = authProvider.status;
      final emSplash = state.matchedLocation == RouteNames.splash;

      // Enquanto a sessão é checada, mantém na splash.
      if (status == AuthStatus.desconhecido) {
        return emSplash ? null : RouteNames.splash;
      }

      final logado = status == AuthStatus.autenticado;
      final indoParaPublica =
          RouteNames.publicas.contains(state.matchedLocation);

      // Não logado tentando rota protegida → login.
      if (!logado && !indoParaPublica) {
        return RouteNames.login;
      }

      // Logado em rota pública (incluindo splash) → app principal.
      if (logado && indoParaPublica) {
        return RouteNames.app;
      }

      // Sessão resolvida mas ainda na splash e não logado → tela inicial.
      if (!logado && emSplash) {
        return RouteNames.inicial;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.inicial,
        builder: (_, __) => const InitialScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.cadastro,
        builder: (_, __) => const CadastroScreen(),
      ),
      GoRoute(
        path: RouteNames.termos,
        builder: (_, __) => const TermosScreen(),
      ),
      GoRoute(
        path: RouteNames.app,
        builder: (_, __) => const MainShell(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Rota não encontrada: ${state.uri}')),
    ),
  );
}
