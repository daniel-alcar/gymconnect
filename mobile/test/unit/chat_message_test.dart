import 'package:flutter_test/flutter_test.dart';
import 'package:gymconnect/app/modules/chat/models/chat_message.dart';

void main() {
  group('ChatMessage.usuario', () {
    test('cria mensagem marcada como do usuário', () {
      final msg = ChatMessage.usuario('Olá');
      expect(msg.texto, 'Olá');
      expect(msg.doUsuario, isTrue);
      expect(msg.erro, isFalse);
    });
  });

  group('ChatMessage.ia', () {
    test('cria mensagem marcada como da IA', () {
      final msg = ChatMessage.ia('Resposta');
      expect(msg.texto, 'Resposta');
      expect(msg.doUsuario, isFalse);
      expect(msg.erro, isFalse);
    });

    test('cria mensagem de erro da IA', () {
      final msg = ChatMessage.ia('Erro de rede', erro: true);
      expect(msg.erro, isTrue);
    });
  });

  group('ChatMessage serialização', () {
    test('toJson / fromJson são inversos', () {
      final original = ChatMessage(
        texto: 'Teste de serialização',
        doUsuario: true,
        horario: DateTime(2024, 6, 15, 10, 30),
        erro: false,
      );

      final json = original.toJson();
      final restaurado = ChatMessage.fromJson(json);

      expect(restaurado.texto, original.texto);
      expect(restaurado.doUsuario, original.doUsuario);
      expect(restaurado.horario, original.horario);
      expect(restaurado.erro, original.erro);
    });

    test('fromJson com erro=true preserva o campo', () {
      final json = {
        'texto': 'Erro',
        'doUsuario': false,
        'horario': '2024-06-15T10:30:00.000',
        'erro': true,
      };
      final msg = ChatMessage.fromJson(json);
      expect(msg.erro, isTrue);
    });

    test('fromJson sem campo erro assume false', () {
      final json = {
        'texto': 'Sem campo erro',
        'doUsuario': true,
        'horario': '2024-06-15T10:30:00.000',
      };
      final msg = ChatMessage.fromJson(json);
      expect(msg.erro, isFalse);
    });
  });
}
