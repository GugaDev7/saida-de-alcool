import '../database/agente_dao.dart';
import '../models/agente_model.dart';
import '../services/anp_service.dart';

class AgenteRepository {
  final AnpService api;
  final AgenteDao dao;

  AgenteRepository({required this.api, required this.dao});

  // Sincroniza dados da API para o SQLite
  Future<void> sincronizarAgentes() async {
    try {
      print('Iniciando sincronização de agentes...');

      // 1. Limpar banco local antes de consultar a API
      print('Limpando banco local...');
      await dao.deleteAll();
      print('Banco local limpo');

      // 2. Buscar dados da API
      print('Buscando dados da API...');
      final List<Map<String, dynamic>> jsonList = await api.fetchAgentes();
      print('Dados da API obtidos: ${jsonList.length} registros');

      // 3. Inserir em lotes com progresso para melhor performance e visibilidade
      print('Inserindo agentes no banco local (lotes)...');
      const int chunkSize = 2000;
      int total = jsonList.length;
      int inserted = 0;
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < total; i += chunkSize) {
        final end = (i + chunkSize < total) ? i + chunkSize : total;
        final chunk = jsonList.sublist(i, end);
        final agentesChunk = chunk
            .map((json) => AgenteModel.fromJson(json))
            .toList(growable: false);
        await dao.insertAgentesBatch(agentesChunk);
        inserted = end;
        if (inserted % (chunkSize * 5) == 0 || inserted == total) {
          print('Inseridos: $inserted / $total');
        }
      }

      stopwatch.stop();
      print(
        'Inserção concluída: $inserted registros em ${stopwatch.elapsed.inSeconds}s',
      );
      print('Sincronização concluída com sucesso');
    } catch (e) {
      print('Erro na sincronização: $e');
      rethrow;
    }
  }

  // Buscar agente por CNPJ
  Future<AgenteModel?> getAgenteByCnpj(String cnpj) async {
    return await dao.getAgenteByCnpj(cnpj);
  }
}
