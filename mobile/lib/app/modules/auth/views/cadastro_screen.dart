import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:gymconnect/app/core/errors/app_exception.dart';
import 'package:gymconnect/app/core/theme/app_theme.dart';
import 'package:gymconnect/app/modules/auth/models/tipo_usuario.dart';
import 'package:gymconnect/app/modules/auth/providers/auth_provider.dart';
import 'package:gymconnect/app/routes/route_names.dart';
import 'package:gymconnect/app/shared/utils/snackbar_helper.dart';
import 'package:gymconnect/app/shared/utils/app_formatters.dart';
import 'package:gymconnect/app/shared/utils/validators.dart';
import 'package:gymconnect/app/shared/widgets/app_logo.dart';

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
  bool _ocultarConfirmar = true;
  bool _aceitouTermos = false;

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
    if (!_aceitouTermos) {
      SnackbarHelper.erro(
          context, 'Aceite os Termos de Uso para continuar.');
      return;
    }
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
      appBar: AppBar(title: const AppLogo(height: 30)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Criar conta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: context.c.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preencha os dados para começar sua jornada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.c.textSecondary),
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
                          inputFormatters: [AppFormatters.apenasLetras, LengthLimitingTextInputFormatter(150)],
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
                          inputFormatters: [AppFormatters.noEmoji, LengthLimitingTextInputFormatter(150)],
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
                          inputFormatters: [AppFormatters.noEmoji, LengthLimitingTextInputFormatter(72)],
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            hintText: 'Mín. 8 caracteres, letras e números',
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
                          obscureText: _ocultarConfirmar,
                          textInputAction: TextInputAction.done,
                          validator: (v) => Validators.confirmarSenha(
                              v, _senhaController.text),
                          inputFormatters: [AppFormatters.noEmoji, LengthLimitingTextInputFormatter(72)],
                          decoration: InputDecoration(
                            labelText: 'Confirmar senha',
                            prefixIcon: const Icon(Icons.lock_reset_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(_ocultarConfirmar
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () => setState(() =>
                                  _ocultarConfirmar = !_ocultarConfirmar),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tipo de perfil',
                            style: TextStyle(
                              color: context.c.textPrimary,
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
                                icone: Icons.fitness_center,
                                titulo: 'Professor',
                                selecionado: _tipo == TipoUsuario.cliente,
                                onTap: carregando
                                    ? null
                                    : () => setState(
                                        () => _tipo = TipoUsuario.cliente),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _aceitouTermos,
                              onChanged: carregando
                                  ? null
                                  : (v) => setState(
                                      () => _aceitouTermos = v ?? false),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Wrap(
                                  children: [
                                    Text(
                                      'Li e aceito os ',
                                      style: TextStyle(
                                          color: context.c.textSecondary),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          context.push(RouteNames.termos),
                                      child: const Text(
                                        'Termos de Uso',
                                        style: TextStyle(
                                          color: AppColors.amareloPressed,
                                          fontWeight: FontWeight.w700,
                                          decoration:
                                              TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: carregando ? null : _cadastrar,
                          child: carregando
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.onAmarelo,
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
                    Text('Já tem uma conta? ',
                        style: TextStyle(color: context.c.textSecondary)),
                    GestureDetector(
                      onTap: carregando
                          ? null
                          : () => context.go(RouteNames.login),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          color: AppColors.amareloPressed,
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selecionado
              ? AppColors.amarelo.withValues(alpha: 0.18)
              : context.c.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionado ? AppColors.amarelo : context.c.border,
            width: selecionado ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icone,
                color: selecionado
                    ? AppColors.amareloPressed
                    : context.c.textSecondary),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(
                color: selecionado
                    ? context.c.textPrimary
                    : context.c.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
