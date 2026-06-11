import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:gymconnect/app/core/errors/app_exception.dart';
import 'package:gymconnect/app/core/theme/app_theme.dart';
import 'package:gymconnect/app/modules/auth/providers/auth_provider.dart';
import 'package:gymconnect/app/routes/route_names.dart';
import 'package:gymconnect/app/shared/utils/snackbar_helper.dart';
import 'package:gymconnect/app/shared/utils/validators.dart';
import 'package:gymconnect/app/shared/widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _ocultarSenha = true;
  String? _erroCredenciais;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() => _erroCredenciais = null);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    try {
      await auth.login(_emailController.text, _senhaController.text);
      if (!mounted) return;
      context.go(RouteNames.app);
    } on AppException catch (e) {
      if (!mounted) return;
      final credenciaisInvalidas = e.statusCode == 401 || e.statusCode == 403;
      if (credenciaisInvalidas) {
        setState(() => _erroCredenciais = 'E-mail ou senha incorretos');
      } else {
        SnackbarHelper.erro(context, e.message);
      }
    } catch (_) {
      if (mounted) SnackbarHelper.erro(context, 'Erro ao fazer login.');
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
                const SizedBox(height: 8),
                Text(
                  'Bem-vindo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: context.c.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Acesse sua conta para continuar sua jornada de alta performance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.c.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Label('E-mail'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          enabled: !carregando,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validators.email,
                          onChanged: (_) {
                            if (_erroCredenciais != null) {
                              setState(() => _erroCredenciais = null);
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: 'voce@email.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _Label('Senha'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _senhaController,
                          enabled: !carregando,
                          obscureText: _ocultarSenha,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _entrar(),
                          validator: (v) =>
                              Validators.obrigatorio(v, campo: 'Senha'),
                          onChanged: (_) {
                            if (_erroCredenciais != null) {
                              setState(() => _erroCredenciais = null);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: '••••••••',
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
                        if (_erroCredenciais != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.danger, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _erroCredenciais!,
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: carregando
                                    ? null
                                    : () => context.go(RouteNames.cadastro),
                                child: const Text(
                                  'Cadastrar',
                                  style: TextStyle(
                                    color: AppColors.amareloPressed,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: carregando ? null : _entrar,
                          child: carregando
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.onAmarelo,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Entrar'),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 20),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Não tem uma conta? ',
                        style: TextStyle(color: context.c.textSecondary)),
                    GestureDetector(
                      onTap: carregando
                          ? null
                          : () => context.go(RouteNames.cadastro),
                      child: const Text(
                        'Cadastrar',
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

class _Label extends StatelessWidget {
  final String texto;
  const _Label(this.texto);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        texto,
        style: TextStyle(
          color: context.c.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
