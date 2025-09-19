import 'package:sqflite/sqflite.dart';
import '../models/agente_model.dart';

class AgenteDao {
  final Database db;

  AgenteDao(this.db);

  // Cria a tabela de agentes se não existir
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS agentes (
        codigo INTEGER PRIMARY KEY,
        cnpj TEXT NOT NULL,
        razaoSocial TEXT NOT NULL,
        cep TEXT,
        municipio TEXT,
        estado TEXT,
        status TEXT
      )
    ''');
    // Índice para acelerar buscas por CNPJ
    await db.execute('CREATE INDEX IF NOT EXISTS idx_agentes_cnpj ON agentes(cnpj)');
  }

  // Insere ou atualiza um agente no banco
  Future<int> insertAgente(AgenteModel agente) async {
    return await db.insert(
      'agentes',
      agente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // substitui se já existir
    );
  }

  // Insere muitos agentes em lote (muito mais rápido que inserir um a um)
  Future<void> insertAgentesBatch(List<AgenteModel> agentes) async {
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final agente in agentes) {
        batch.insert(
          'agentes',
          agente.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  // Busca um agente pelo CNPJ
  Future<AgenteModel?> getAgenteByCnpj(String cnpj) async {
    try {
      final normalized = cnpj.replaceAll(RegExp(r'\D'), '');
      print('Buscando agente com CNPJ: $normalized');
      final result = await db.query(
        'agentes',
        where: 'cnpj = ?',
        whereArgs: [normalized],
      );
      print('Resultado da busca: ${result.length} registros encontrados');
      return result.isNotEmpty ? AgenteModel.fromMap(result.first) : null;
    } catch (e) {
      print('Erro ao buscar agente: $e');
      rethrow;
    }
  }

  // Retorna todos os agentes
  Future<List<AgenteModel>> getAllAgentes() async {
    final result = await db.query('agentes');
    return result.map((map) => AgenteModel.fromMap(map)).toList();
  }

  // Deleta todos os registros da tabela (útil para sincronização)
  Future<int> deleteAll() async {
    return await db.delete('agentes');
  }
}
