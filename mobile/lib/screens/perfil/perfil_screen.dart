import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../models/perfil.dart';
import '../../providers/auth_provider.dart';
import '../../providers/perfil_provider.dart';
import '../../routes/route_names.dart';
import '../../utils/date_formatter.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/validators.dart';
import '../../widgets/app_logo.dart';
import '../configuracoes/configuracoes_screen.dart';

/// TELA 6 – PERFIL. Atualização de informações pessoais (POST /perfil/me).
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _alturaController = TextEditingController();
  final _objetivoController = TextEditingController();
  DateTime? _dataNascimento;

  @override
  void dispose() {
    _alturaController.dispose();
    _objetivoController.dispose();
    super.dispose();
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
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.amarelo,
                          child: Text(
                            (usuario?.nome.isNotEmpty ?? false)
                                ? usuario!.nome[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onAmarelo,
                            ),
                          ),
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
                                  color: AppColors.amarelo
                                      .withValues(alpha: 0.20),
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
