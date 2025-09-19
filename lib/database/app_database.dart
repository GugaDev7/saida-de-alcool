import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'agente_dao.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Inicializa o banco
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      // Inicializa FFI quando rodando em desktop (Windows/Linux/macOS)
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      // Define o path do banco
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'anp_app.db');

      // Abre/cria o banco
      final db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await AgenteDao.createTable(db);
        },
        onOpen: (db) async {
          // Ajustes de performance para muitas inserções
          await db.execute('PRAGMA journal_mode=WAL');
          await db.execute('PRAGMA synchronous=NORMAL');
        },
      );

      return db;
    } catch (e) {
      rethrow;
    }
  }

  // Obter DAO de agentes
  Future<AgenteDao> getAgenteDao() async {
    final db = await database;
    return AgenteDao(db);
  }

  // Fechar o banco
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
