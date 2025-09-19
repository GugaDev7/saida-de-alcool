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
  }

  // Insere ou atualiza um agente no banco
  Future<int> insertAgente(AgenteModel agente) async {
    return await db.insert(
      'agentes',
      agente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // substitui se já existir
    );
  }

  // Busca um agente pelo CNPJ
  Future<AgenteModel?> getAgenteByCnpj(String cnpj) async {
    try {
      print('Buscando agente com CNPJ: $cnpj');
      final result = await db.query(
        'agentes',
        where: 'cnpj = ?',
        whereArgs: [cnpj],
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
