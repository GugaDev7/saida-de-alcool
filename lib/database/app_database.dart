import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'agente_dao.dart';

/// Responsável por inicializar e disponibilizar o banco SQLite (FFI desktop).
class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  /// Retorna a instância singleton de [AppDatabase].
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _database;

  /// Obtém (ou cria) a instância do [Database].
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  /// Configura SQLite FFI, abre o banco e cria estruturas necessárias.
  Future<Database> _initDatabase() async {
    try {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'anp_app.db');

      final db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await AgenteDao.createTable(db);
        },
        onOpen: (db) async {
          await db.execute('PRAGMA journal_mode=WAL');
          await db.execute('PRAGMA synchronous=NORMAL');
        },
      );

      return db;
    } catch (e) {
      rethrow;
    }
  }

  /// Retorna uma instância de [AgenteDao] vinculada ao banco atual.
  Future<AgenteDao> getAgenteDao() async {
    final db = await database;
    return AgenteDao(db);
  }

  /// Fecha o banco atual e limpa o cache de instância.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
