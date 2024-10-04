import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/creditCard.dart';

class CreditCardDBHelper {
  static final CreditCardDBHelper _instance = CreditCardDBHelper._internal();
  factory CreditCardDBHelper() => _instance;
  CreditCardDBHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'credit_cards.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE credit_cards(id INTEGER PRIMARY KEY AUTOINCREMENT, cardHolderName TEXT, cardNumber TEXT, cvv TEXT, expiryDate TEXT)',
        );
      },
    );
  }

  Future<void> insertCard(CreditCard card) async {
    final db = await database;
    await db.insert(
      'credit_cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CreditCard>> getCards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('credit_cards');
    return List.generate(maps.length, (i) {
      return CreditCard.fromMap(maps[i]);
    });
  }

  Future<void> updateCard(CreditCard card) async {
    final db = await database;
    await db.update(
      'credit_cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteCard(int id) async {
    final db = await database;
    await db.delete(
      'credit_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
