import 'package:flutter_test/flutter_test.dart';
import 'package:gymconnect/app/modules/treinos/models/exercicio.dart';

void main() {
  group('Exercicio.fromJson', () {
    test('desserializa todos os campos', () {
      final ex = Exercicio.fromJson({
        'idExercicio': 1,
        'nome': 'Supino Reto',
        'linkYoutube': 'https://youtube.com/watch?v=abc',
        'descricao': 'Deitar no banco e empurrar.',
      });

      expect(ex.idExercicio, 1);
      expect(ex.nome, 'Supino Reto');
      expect(ex.linkYoutube, 'https://youtube.com/watch?v=abc');
      expect(ex.descricao, 'Deitar no banco e empurrar.');
    });

    test('usa fallback quando nome é null', () {
      final ex = Exercicio.fromJson({'nome': null});
      expect(ex.nome, 'Exercício sem nome');
    });

    test('campos opcionais podem ser null', () {
      final ex = Exercicio.fromJson({'nome': 'Agachamento'});
      expect(ex.idExercicio, isNull);
      expect(ex.linkYoutube, isNull);
      expect(ex.descricao, isNull);
    });
  });

  group('Exercicio.toJson', () {
    test('roundtrip fromJson → toJson → fromJson preserva todos os campos', () {
      final original = Exercicio.fromJson({
        'idExercicio': 5,
        'nome': 'Rosca Direta',
        'linkYoutube': 'https://youtube.com/watch?v=xyz',
        'descricao': 'Posição inicial com braços estendidos.',
      });
      final restaurado = Exercicio.fromJson(original.toJson());

      expect(restaurado.idExercicio, original.idExercicio);
      expect(restaurado.nome, original.nome);
      expect(restaurado.linkYoutube, original.linkYoutube);
      expect(restaurado.descricao, original.descricao);
    });

    test('omite idExercicio quando null', () {
      const ex = Exercicio(nome: 'Novo');
      expect(ex.toJson().containsKey('idExercicio'), isFalse);
    });

    test('inclui linkYoutube null explicitamente', () {
      const ex = Exercicio(nome: 'Sem link');
      final json = ex.toJson();
      expect(json.containsKey('linkYoutube'), isTrue);
      expect(json['linkYoutube'], isNull);
    });
  });

  group('Exercicio.temVideo', () {
    test('true quando link tem conteúdo', () {
      const ex = Exercicio(nome: 'A', linkYoutube: 'https://youtube.com/watch?v=abc');
      expect(ex.temVideo, isTrue);
    });

    test('false quando link é null', () {
      const ex = Exercicio(nome: 'A');
      expect(ex.temVideo, isFalse);
    });

    test('false quando link é string vazia', () {
      const ex = Exercicio(nome: 'A', linkYoutube: '');
      expect(ex.temVideo, isFalse);
    });

    test('false quando link contém só espaços', () {
      const ex = Exercicio(nome: 'A', linkYoutube: '   ');
      expect(ex.temVideo, isFalse);
    });
  });

  group('Exercicio.temDescricao', () {
    test('true quando descrição tem conteúdo', () {
      const ex = Exercicio(nome: 'A', descricao: 'Fazer assim...');
      expect(ex.temDescricao, isTrue);
    });

    test('false quando descrição é null', () {
      const ex = Exercicio(nome: 'A');
      expect(ex.temDescricao, isFalse);
    });

    test('false quando descrição contém só espaços', () {
      const ex = Exercicio(nome: 'A', descricao: '  ');
      expect(ex.temDescricao, isFalse);
    });
  });
}
