import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction_model.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'expense_tracker.db';
  static const String _tableName = 'transactions';

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            amount REAL,
            category TEXT,
            type TEXT,
            date TEXT
          )
        ''');
      },
    );
  }

  /// Create
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return db.insert(_tableName, transaction.toMap());
  }

  /// Read (newest first)
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'date DESC, id DESC');
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  /// Update
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return db.update(
      _tableName,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// Delete
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}