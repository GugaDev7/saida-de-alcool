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
      // 1. Limpar banco local antes de consultar a API
      await dao.deleteAll();

      // 2. Buscar dados da API
      final List<Map<String, dynamic>> jsonList = await api.fetchAgentes();

      // 3. Inserir em lotes com progresso para melhor performance e visibilidade
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
        if (inserted % (chunkSize * 5) == 0 || inserted == total) {}
      }

      stopwatch.stop();
    } catch (e) {
      rethrow;
    }
  }

  // Buscar agente por CNPJ
  Future<AgenteModel?> getAgenteByCnpj(String cnpj) async {
    return await dao.getAgenteByCnpj(cnpj);
  }
}
