import 'package:flutter/material.dart';
import 'package:gymconnect/app/core/theme/app_theme.dart';
import 'package:gymconnect/app/shared/widgets/app_logo.dart';

class TermosScreen extends StatelessWidget {
  const TermosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(height: 30),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Termos de Uso',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: context.c.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Última atualização: junho de 2025',
                style: TextStyle(color: context.c.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              const _Secao(
                titulo: '1. Aceitação dos Termos',
                texto:
                    'Ao criar uma conta e utilizar o GymConnect, você concorda com estes Termos de Uso. '
                    'Se não concordar com qualquer parte destes termos, não utilize o aplicativo.',
              ),
              const _Secao(
                titulo: '2. Descrição do Serviço',
                texto:
                    'O GymConnect é uma plataforma que conecta professores de educação física '
                    'a seus alunos, permitindo a criação e acompanhamento de treinos personalizados. '
                    'O aplicativo oferece funcionalidades como cadastro de exercícios, montagem de '
                    'cronogramas semanais e acompanhamento de atividade física.',
              ),
              const _Secao(
                titulo: '3. Cadastro e Conta',
                texto:
                    'Para utilizar o GymConnect, você deve criar uma conta fornecendo informações '
                    'verdadeiras, precisas e completas. Você é responsável por manter a '
                    'confidencialidade da sua senha e por todas as atividades realizadas com sua conta. '
                    'Notifique-nos imediatamente em caso de uso não autorizado.',
              ),
              const _Secao(
                titulo: '4. Uso Adequado',
                texto:
                    'Você concorda em utilizar o aplicativo apenas para fins lícitos e de acordo '
                    'com estes termos. É proibido: '
                    '(a) usar o serviço para fins ilegais; '
                    '(b) transmitir conteúdo ofensivo, difamatório ou prejudicial; '
                    '(c) tentar acessar dados de outros usuários sem autorização; '
                    '(d) interferir no funcionamento do serviço.',
              ),
              const _Secao(
                titulo: '5. Saúde e Segurança',
                texto:
                    'O GymConnect não substitui orientação médica ou de profissional de saúde qualificado. '
                    'Consulte um médico antes de iniciar qualquer programa de exercícios. '
                    'O aplicativo não se responsabiliza por lesões ou problemas de saúde '
                    'decorrentes do uso das informações aqui disponibilizadas.',
              ),
              const _Secao(
                titulo: '6. Privacidade de Dados',
                texto:
                    'Coletamos e utilizamos seus dados pessoais conforme nossa Política de Privacidade. '
                    'Seus dados são utilizados exclusivamente para a prestação do serviço e '
                    'não são compartilhados com terceiros sem seu consentimento, salvo obrigação legal.',
              ),
              const _Secao(
                titulo: '7. Propriedade Intelectual',
                texto:
                    'Todo o conteúdo do GymConnect — incluindo textos, imagens, logotipos e código — '
                    'é de propriedade dos desenvolvedores ou licenciado por eles. '
                    'É proibida a reprodução, distribuição ou modificação sem autorização expressa.',
              ),
              const _Secao(
                titulo: '8. Limitação de Responsabilidade',
                texto:
                    'O GymConnect é fornecido "como está", sem garantias de qualquer natureza. '
                    'Não nos responsabilizamos por danos indiretos, incidentais ou consequenciais '
                    'decorrentes do uso ou da impossibilidade de uso do serviço.',
              ),
              const _Secao(
                titulo: '9. Alterações nos Termos',
                texto:
                    'Reservamo-nos o direito de modificar estes termos a qualquer momento. '
                    'Alterações significativas serão notificadas dentro do aplicativo. '
                    'O uso continuado do serviço após as alterações implica na aceitação dos novos termos.',
              ),
              const _Secao(
                titulo: '10. Contato',
                texto:
                    'Dúvidas sobre estes Termos de Uso podem ser enviadas para o suporte '
                    'disponível dentro do aplicativo. Faremos o possível para responder '
                    'em até 5 dias úteis.',
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Entendi'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  final String titulo;
  final String texto;
  const _Secao({required this.titulo, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.c.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            texto,
            style: TextStyle(
              color: context.c.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
