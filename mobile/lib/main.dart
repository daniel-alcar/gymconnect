import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/atividade_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/cliente_provider.dart';
import 'providers/perfil_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/treino_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/chat_repository.dart';
import 'repositories/cliente_repository.dart';
import 'repositories/perfil_repository.dart';
import 'repositories/treino_repository.dart';
import 'routes/app_router.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/dio_client.dart';
import 'services/execucao_service.dart';
import 'services/exercicio_service.dart';
import 'services/gestao_service.dart';
import 'services/perfil_service.dart';
import 'services/registro_service.dart';
import 'services/storage_service.dart';
import 'services/treino_service.dart';
import 'services/usuario_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GymConnectApp());
}

/// Composição da árvore de dependências (Clean Architecture):
/// Storage/Dio → Services → Repositories → Providers → UI.
class GymConnectApp extends StatefulWidget {
  const GymConnectApp({super.key});

  @override
  State<GymConnectApp> createState() => _GymConnectAppState();
}

class _GymConnectAppState extends State<GymConnectApp> {
  // Infra
  late final StorageService _storage;
  late final DioClient _dioClient;

  // Providers
  late final AuthProvider _authProvider;
  late final TreinoProvider _treinoProvider;
  late final PerfilProvider _perfilProvider;
  late final ChatProvider _chatProvider;
  late final ClienteProvider _clienteProvider;
  late final ThemeProvider _themeProvider;
  late final AtividadeProvider _atividadeProvider;

  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();

    _storage = StorageService();
    _dioClient = DioClient(_storage);

    // Services
    final authService = AuthService(_dioClient);
    final treinoService = TreinoService(_dioClient);
    final execucaoService = ExecucaoService(_dioClient);
    final registroService = RegistroService(_dioClient);
    final perfilService = PerfilService(_dioClient);
    final chatService = ChatService(_dioClient);
    final usuarioService = UsuarioService(_dioClient);
    final exercicioService = ExercicioService(_dioClient);
    final gestaoService = GestaoService(_dioClient);

    // Repositories
    final authRepo = AuthRepository(authService, _storage);
    final treinoRepo =
        TreinoRepository(treinoService, execucaoService, registroService);
    final perfilRepo = PerfilRepository(perfilService);
    final chatRepo = ChatRepository(chatService);
    final clienteRepo = ClienteRepository(
      usuarioService,
      exercicioService,
      gestaoService,
      treinoRepo,
    );

    // Providers
    _authProvider = AuthProvider(authRepo);
    _treinoProvider = TreinoProvider(treinoRepo);
    _perfilProvider = PerfilProvider(perfilRepo);
    _chatProvider = ChatProvider(chatRepo);
    _clienteProvider = ClienteProvider(clienteRepo);
    _themeProvider = ThemeProvider(_storage);
    _atividadeProvider = AtividadeProvider(_storage);

    // Logout automático quando o backend responde 401/403.
    _dioClient.onUnauthorized = _authProvider.sessaoExpirada;

    _appRouter = AppRouter(_authProvider);

    // Carrega a preferência de tema e a sessão salva (token + usuário).
    _themeProvider.carregar();
    _authProvider.carregarSessao();
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _treinoProvider.dispose();
    _perfilProvider.dispose();
    _chatProvider.dispose();
    _clienteProvider.dispose();
    _themeProvider.dispose();
    _atividadeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _treinoProvider),
        ChangeNotifierProvider.value(value: _perfilProvider),
        ChangeNotifierProvider.value(value: _chatProvider),
        ChangeNotifierProvider.value(value: _clienteProvider),
        ChangeNotifierProvider.value(value: _themeProvider),
        ChangeNotifierProvider.value(value: _atividadeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, tema, __) => MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: tema.modo,
          routerConfig: _appRouter.router,
        ),
      ),
    );
  }
}
