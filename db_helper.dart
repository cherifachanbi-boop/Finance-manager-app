import "package:path/path.dart";
import "package:sqflite/sqflite.dart";

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  DBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "salary_manager.db");
    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE installments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity TEXT NOT NULL,
        monthlyAmount REAL NOT NULL,
        totalCount INTEGER NOT NULL,
        remainingCount INTEGER NOT NULL,
        startDate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        creditor TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        monthlyPayment REAL NOT NULL,
        paid REAL NOT NULL,
        notes TEXT,
        lastPaymentDate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE months (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        monthLabel TEXT NOT NULL,
        salary REAL NOT NULL,
        motherAmount REAL NOT NULL,
        alimony REAL NOT NULL,
        distributionMode TEXT NOT NULL,
        percentFamily REAL,
        percentInstallment REAL,
        percentDebt REAL,
        percentSaving REAL,
        percentReserve REAL,
        fixedFamily REAL,
        fixedInstallment REAL,
        fixedDebt REAL,
        fixedSaving REAL,
        fixedReserve REAL
      )
    ''');
  }

  // ---------- Settings ----------
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      "settings",
      {"key": key, "value": value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query("settings", where: "key = ?", whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first["value"] as String?;
  }

  // ---------- Installments ----------
  Future<int> insertInstallment(Map<String, dynamic> row) async {
    final db = await database;
    row.remove("id");
    return db.insert("installments", row);
  }

  Future<int> updateInstallment(int id, Map<String, dynamic> row) async {
    final db = await database;
    row.remove("id");
    return db.update("installments", row, where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteInstallment(int id) async {
    final db = await database;
    return db.delete("installments", where: "id = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> fetchInstallments() async {
    final db = await database;
    return db.query("installments", orderBy: "id DESC");
  }

  // ---------- Debts ----------
  Future<int> insertDebt(Map<String, dynamic> row) async {
    final db = await database;
    row.remove("id");
    return db.insert("debts", row);
  }

  Future<int> updateDebt(int id, Map<String, dynamic> row) async {
    final db = await database;
    row.remove("id");
    return db.update("debts", row, where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteDebt(int id) async {
    final db = await database;
    return db.delete("debts", where: "id = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> fetchDebts() async {
    final db = await database;
    return db.query("debts", orderBy: "id DESC");
  }

  // ---------- Months ----------
  Future<int> insertMonth(Map<String, dynamic> row) async {
    final db = await database;
    row.remove("id");
    return db.insert("months", row);
  }

  Future<List<Map<String, dynamic>>> fetchMonths() async {
    final db = await database;
    return db.query("months", orderBy: "id DESC");
  }

  Future<Map<String, dynamic>?> fetchLatestMonth() async {
    final db = await database;
    final rows = await db.query("months", orderBy: "id DESC", limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }
}
