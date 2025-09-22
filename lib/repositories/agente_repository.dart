import '../database/agente_dao.dart';
import '../models/agente_model.dart';
import '../services/anp_service.dart';

/// Camada de repositório que orquestra API e SQLite para agentes.
class AgenteRepository {
  final AnpService api;
  final AgenteDao dao;

  /// Cria um [AgenteRepository] com as dependências necessárias.
  AgenteRepository({required this.api, required this.dao});

  /// Sincroniza os agentes da API com o banco local SQLite.
  ///
  /// Executa limpeza prévia, busca os dados e insere em lotes para
  /// melhor desempenho e possibilidade de feedback de progresso.
  Future<void> sincronizarAgentes({
    void Function(int inserted, int total)? onProgress,
  }) async {
    try {
      await dao.deleteAll();

      final List<Map<String, dynamic>> jsonList = await api.fetchAgentes();

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
        if (onProgress != null &&
            (inserted % (chunkSize) == 0 || inserted == total)) {
          onProgress(inserted, total);
        }
      }

      stopwatch.stop();
    } catch (e) {
      rethrow;
    }
  }

  /// Busca um agente pelo CNPJ via DAO.
  Future<AgenteModel?> getAgenteByCnpj(String cnpj) async {
    return await dao.getAgenteByCnpj(cnpj);
  }
}
