import 'dart:convert';
import 'package:http/http.dart' as http;

/// Serviço HTTP para consumo da API pública da ANP de instalações abertas.
class AnpService {
  final String baseUrl;

  /// Cria um [AnpService] opcionalmente com a [baseUrl] personalizada.
  AnpService({
    this.baseUrl =
        'https://dpp-isimp-consultas-api.anp.gov.br/instalacoes-abertas',
  });

  /// Busca a lista de agentes na API da ANP.
  ///
  /// Retorna uma lista de Maps (JSON bruto) para posterior mapeamento em modelos.
  Future<List<Map<String, dynamic>>> fetchAgentes() async {
    try {
      print('Fazendo requisição para: $baseUrl');
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Timeout: A requisição demorou mais de 30 segundos',
              );
            },
          );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception(
          'Falha ao carregar dados da ANP: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
