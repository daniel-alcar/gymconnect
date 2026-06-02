import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../models/tipo_usuario.dart';
import '../../providers/auth_provider.dart';
import '../../routes/route_names.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/validators.dart';
import '../../widgets/app_logo.dart';

/// TELA 3 – CADASTRO.
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();
  TipoUsuario _tipo = TipoUsuario.aluno;
  bool _ocultarSenha = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    try {
      await auth.cadastrar(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
        tipo: _tipo,
      );
      if (!mounted) return;
      SnackbarHelper.sucesso(context, 'Conta criada com sucesso!');
      context.go(RouteNames.app);
    } on AppException catch (e) {
      if (mounted) SnackbarHelper.erro(context, e.message);
    } catch (_) {
      if (mounted) SnackbarHelper.erro(context, 'Erro ao cadastrar.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final carregando = context.watch<AuthProvider>().carregando;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            AppLogoMark(size: 30),
            SizedBox(width: 10),
            AppWordmark(fontSize: 20),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Criar conta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Preencha os dados para começar sua jornada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nomeController,
                          enabled: !carregando,
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              Validators.obrigatorio(v, campo: 'Nome'),
                          decoration: const InputDecoration(
                            labelText: 'Nome completo',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          enabled: !carregando,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validators.email,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _senhaController,
                          enabled: !carregando,
                          obscureText: _ocultarSenha,
                          textInputAction: TextInputAction.next,
                          validator: Validators.senha,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_ocultarSenha
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () => setState(
                                  () => _ocultarSenha = !_ocultarSenha),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmarController,
                          enabled: !carregando,
                          obscureText: _ocultarSenha,
                          textInputAction: TextInputAction.done,
                          validator: (v) => Validators.confirmarSenha(
                              v, _senhaController.text),
                          decoration: const InputDecoration(
                            labelText: 'Confirmar senha',
                            prefixIcon: Icon(Icons.lock_reset_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tipo de perfil',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _PerfilOption(
                                icone: Icons.directions_run,
                                titulo: 'Aluno',
                                selecionado: _tipo == TipoUsuario.aluno,
                                onTap: carregando
                                    ? null
                                    : () => setState(
                                        () => _tipo = TipoUsuario.aluno),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PerfilOption(
                                icone: Icons.business,
                                titulo: 'Cliente',
                                selecionado: _tipo == TipoUsuario.cliente,
                                onTap: carregando
                                    ? null
                                    : () => setState(
                                        () => _tipo = TipoUsuario.cliente),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: carregando ? null : _cadastrar,
                          child: carregando
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Criar Conta'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já tem uma conta? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: carregando
                          ? null
                          : () => context.go(RouteNames.login),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PerfilOption extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final bool selecionado;
  final VoidCallback? onTap;

  const _PerfilOption({
    required this.icone,
    required this.titulo,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selecionado
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selecionado ? AppColors.primary : AppColors.border,
            width: selecionado ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icone,
                color:
                    selecionado ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(
                color:
                    selecionado ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
