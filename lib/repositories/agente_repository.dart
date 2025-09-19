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

      // 1. Buscar dados da API
      print('Buscando dados da API...');
      final List<Map<String, dynamic>> jsonList = await api.fetchAgentes();
      print('Dados da API obtidos: ${jsonList.length} registros');

      // 2. Limpar banco local antes de inserir novos dados
      print('Limpando banco local...');
      await dao.deleteAll();
      print('Banco local limpo');

      // 3. Inserir cada agente no SQLite
      print('Inserindo agentes no banco local...');
      for (var json in jsonList) {
        final agente = AgenteModel.fromJson(json);
        await dao.insertAgente(agente);
      }
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
