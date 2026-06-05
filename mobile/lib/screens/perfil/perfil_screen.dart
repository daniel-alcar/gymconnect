import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../models/perfil.dart';
import '../../providers/auth_provider.dart';
import '../../providers/perfil_provider.dart';
import '../../routes/route_names.dart';
import '../../services/storage_service.dart';
import '../../utils/date_formatter.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/validators.dart';
import '../../widgets/app_logo.dart';
import '../configuracoes/configuracoes_screen.dart';

/// TELA 6 – PERFIL. Foto (câmera/galeria, local) + dados pessoais (POST /perfil/me).
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _alturaController = TextEditingController();
  final _objetivoController = TextEditingController();
  final _storage = StorageService();
  final _picker = ImagePicker();

  DateTime? _dataNascimento;
  int? _idUsuario;
  String? _fotoPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarFoto());
  }

  @override
  void dispose() {
    _alturaController.dispose();
    _objetivoController.dispose();
    super.dispose();
  }

  Future<void> _carregarFoto() async {
    final id = context.read<AuthProvider>().usuario?.idUsuario;
    if (id == null) return;
    _idUsuario = id;
    final path = await _storage.lerFotoPerfil(id);
    // Só usa o path se o arquivo ainda existir no dispositivo.
    if (path != null && File(path).existsSync()) {
      if (mounted) setState(() => _fotoPath = path);
    }
  }

  Future<void> _selecionarFoto(ImageSource origem) async {
    try {
      final XFile? img = await _picker.pickImage(
        source: origem,
        maxWidth: 1080,
        imageQuality: 85,
      );
      if (img == null) return;
      if (_idUsuario != null) {
        await _storage.salvarFotoPerfil(_idUsuario!, img.path);
      }
      if (mounted) {
        setState(() => _fotoPath = img.path);
        SnackbarHelper.sucesso(context, 'Foto de perfil atualizada!');
      }
    } catch (_) {
      if (mounted) {
        SnackbarHelper.erro(context, 'Não foi possível acessar a imagem.');
      }
    }
  }

  Future<void> _removerFoto() async {
    if (_idUsuario != null) await _storage.removerFotoPerfil(_idUsuario!);
    if (mounted) setState(() => _fotoPath = null);
  }

  void _abrirOpcoesFoto() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: AppColors.amareloPressed),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.pop(ctx);
                _selecionarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.amareloPressed),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(ctx);
                _selecionarFoto(ImageSource.gallery);
              },
            ),
            if (_fotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.danger),
                title: const Text('Remover foto'),
                onTap: () {
                  Navigator.pop(ctx);
                  _removerFoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarData() async {
    final agora = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime(agora.year - 20),
      firstDate: DateTime(1920),
      lastDate: agora,
      helpText: 'Selecione a data de nascimento',
    );
    if (data != null) setState(() => _dataNascimento = data);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final perfil = Perfil(
      dataNascimento: _dataNascimento != null
          ? DateFormatter.toIso(_dataNascimento!)
          : null,
      altura: _alturaController.text.trim().isEmpty
          ? null
          : double.tryParse(_alturaController.text.replaceAll(',', '.')),
      objetivo: _objetivoController.text.trim().isEmpty
          ? null
          : _objetivoController.text.trim(),
    );
    try {
      await context.read<PerfilProvider>().salvar(perfil);
      if (mounted) SnackbarHelper.sucesso(context, 'Perfil salvo com sucesso!');
    } on AppException catch (e) {
      if (mounted) SnackbarHelper.erro(context, e.message);
    } catch (_) {
      if (mounted) SnackbarHelper.erro(context, 'Erro ao salvar perfil.');
    }
  }

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente encerrar a sessão?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sair')),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;
    final salvando = context.watch<PerfilProvider>().salvando;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const AppLogo(height: 30),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ConfiguracoesScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        _Avatar(
                          fotoPath: _fotoPath,
                          inicial: (usuario?.nome.isNotEmpty ?? false)
                              ? usuario!.nome[0].toUpperCase()
                              : '?',
                          onTap: _abrirOpcoesFoto,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                usuario?.nome ?? '—',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: context.c.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                usuario?.email ?? '—',
                                style: TextStyle(
                                  color: context.c.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.amarelo.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  usuario?.tipo.label ?? '',
                                  style: const TextStyle(
                                    color: AppColors.amareloPressed,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Informações pessoais',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.c.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Todos os campos são opcionais.',
                  style: TextStyle(color: context.c.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: salvando ? null : _selecionarData,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    child: Text(
                      _dataNascimento != null
                          ? DateFormatter.toBr(_dataNascimento!)
                          : 'Selecionar data',
                      style: TextStyle(
                        color: _dataNascimento != null
                            ? context.c.textPrimary
                            : context.c.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _alturaController,
                  enabled: !salvando,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: Validators.alturaOpcional,
                  decoration: const InputDecoration(
                    labelText: 'Altura (m)',
                    hintText: 'ex.: 1.75',
                    prefixIcon: Icon(Icons.height),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _objetivoController,
                  enabled: !salvando,
                  decoration: const InputDecoration(
                    labelText: 'Objetivo',
                    hintText: 'ex.: Hipertrofia',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: salvando ? null : _salvar,
                  child: salvando
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.onAmarelo,
                          ),
                        )
                      : const Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar do perfil: mostra a foto local (se houver) ou a inicial, com selo de câmera.
class _Avatar extends StatelessWidget {
  final String? fotoPath;
  final String inicial;
  final VoidCallback onTap;

  const _Avatar({
    required this.fotoPath,
    required this.inicial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.amarelo,
            backgroundImage:
                fotoPath != null ? FileImage(File(fotoPath!)) : null,
            child: fotoPath == null
                ? Text(
                    inicial,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onAmarelo,
                    ),
                  )
                : null,
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.amarelo,
                shape: BoxShape.circle,
                border: Border.all(color: context.c.surface, width: 2),
              ),
              child: const Icon(Icons.photo_camera,
                  size: 14, color: AppColors.onAmarelo),
            ),
          ),
        ],
      ),
    );
  }
}
