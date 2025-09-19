import 'package:flutter_test/flutter_test.dart';
import 'package:saida_de_alcool/services/anp_service.dart';

void main() {
  group('AnpService', () {
    final service = AnpService();

    test('fetchAgentes deve retornar lista de agentes', () async {
      // Chama o método
      final agentes = await service.fetchAgentes();

      // Verifica se retornou uma lista
      expect(agentes, isA<List>());

      // Se não estiver vazia, verifica se o primeiro item é Map
      if (agentes.isNotEmpty) {
        expect(agentes.first, isA<Map<String, dynamic>>());
        expect(agentes.first.containsKey('codigo'), true);
        expect(agentes.first.containsKey('cnpj'), true);
      }
    });

    test('fetchAgentes lança exceção em URL incorreta', () async {
      final badService = AnpService(baseUrl: 'https://url_invalida');

      // Verifica se lança exceção
      expect(() async => await badService.fetchAgentes(), throwsException);
    });
  });
}
