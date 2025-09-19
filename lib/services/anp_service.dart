import 'dart:convert';
import 'package:http/http.dart' as http;

class AnpService {
  // URL da API da ANP para instalações abertas
  final String baseUrl;

  // Construtor com valor padrão da API
  AnpService({
    this.baseUrl =
        'https://dpp-isimp-consultas-api.anp.gov.br/instalacoes-abertas',
  });

  // Método para buscar agentes da ANP
  Future<List<Map<String, dynamic>>> fetchAgentes() async {
    try {
      print('Fazendo requisição para: $baseUrl');

      // Faz a requisição GET para a API com timeout de 30 segundos
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

      print('Resposta recebida: ${response.statusCode}');

      // Se a resposta for OK, converte o JSON em lista de mapas
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Dados decodificados: ${data.length} registros');
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        // Caso dê erro, lança uma exceção
        throw Exception(
          'Falha ao carregar dados da ANP: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Erro na requisição da API: $e');
      rethrow;
    }
  }
}
