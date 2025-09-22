import 'package:sqflite/sqflite.dart';
import '../models/agente_model.dart';

/// DAO responsável pelo acesso à tabela `agentes` no SQLite.
class AgenteDao {
  final Database db;

  /// Cria um [AgenteDao] usando a instância de [Database] informada.
  AgenteDao(this.db);

  /// Cria a tabela e índices necessários para `agentes` caso não existam.
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
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_agentes_cnpj ON agentes(cnpj)',
    );
  }

  /// Insere ou atualiza um agente (upsert) na tabela `agentes`.
  Future<int> insertAgente(AgenteModel agente) async {
    return await db.insert(
      'agentes',
      agente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insere vários agentes em transação usando `batch` para melhor desempenho.
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

  /// Retorna um agente pelo seu CNPJ (somente dígitos).
  Future<AgenteModel?> getAgenteByCnpj(String cnpj) async {
    try {
      final normalized = cnpj.replaceAll(RegExp(r'\D'), '');
      final result = await db.query(
        'agentes',
        where: 'cnpj = ?',
        whereArgs: [normalized],
      );
      return result.isNotEmpty ? AgenteModel.fromMap(result.first) : null;
    } catch (e) {
      rethrow;
    }
  }

  /// Retorna todos os agentes da tabela.
  Future<List<AgenteModel>> getAllAgentes() async {
    final result = await db.query('agentes');
    return result.map((map) => AgenteModel.fromMap(map)).toList();
  }

  /// Remove todos os registros da tabela `agentes` (útil para sincronização).
  Future<int> deleteAll() async {
    return await db.delete('agentes');
  }
}
