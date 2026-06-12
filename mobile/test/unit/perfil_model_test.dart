import 'package:flutter_test/flutter_test.dart';
import 'package:gymconnect/app/modules/perfil/models/perfil.dart';

void main() {
  group('Perfil.fromJson', () {
    test('desserializa dataNascimento como String ISO', () {
      final perfil = Perfil.fromJson({
        'idPerfil': 1,
        'dataNascimento': '1995-08-20',
        'altura': 1.75,
        'objetivo': 'Hipertrofia',
      });

      expect(perfil.idPerfil, 1);
      expect(perfil.dataNascimento, '1995-08-20');
      expect(perfil.altura, 1.75);
      expect(perfil.objetivo, 'Hipertrofia');
    });

    test('desserializa dataNascimento como timestamp (int)', () {
      // 2000-06-15 em milissegundos UTC
      final timestamp = DateTime.utc(2000, 6, 15).millisecondsSinceEpoch;
      final perfil = Perfil.fromJson({
        'idPerfil': 2,
        'dataNascimento': timestamp,
        'altura': 1.80,
        'objetivo': null,
      });

      expect(perfil.dataNascimento, '2000-06-15');
    });

    test('aceita campos opcionais nulos', () {
      final perfil = Perfil.fromJson({
        'idPerfil': null,
        'dataNascimento': null,
        'altura': null,
        'objetivo': null,
      });

      expect(perfil.idPerfil, isNull);
      expect(perfil.dataNascimento, isNull);
      expect(perfil.altura, isNull);
      expect(perfil.objetivo, isNull);
    });

    test('converte altura de int para double', () {
      final perfil = Perfil.fromJson({
        'dataNascimento': '2000-01-01',
        'altura': 2,
        'objetivo': null,
      });
      expect(perfil.altura, 2.0);
      expect(perfil.altura, isA<double>());
    });
  });

  group('Perfil.toCreateJson', () {
    test('não inclui idPerfil no payload de criação', () {
      final perfil = Perfil(
        idPerfil: 42,
        dataNascimento: '2000-01-01',
        altura: 1.75,
        objetivo: 'Emagrecimento',
      );
      final json = perfil.toCreateJson();

      expect(json.containsKey('idPerfil'), isFalse);
      expect(json['dataNascimento'], '2000-01-01');
      expect(json['altura'], 1.75);
      expect(json['objetivo'], 'Emagrecimento');
    });
  });
}
