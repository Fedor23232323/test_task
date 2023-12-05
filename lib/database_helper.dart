import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'test.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE buildings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        floors INTEGER
      )
    ''');
  }

  Future<int> insertBuilding(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('buildings', row);
  }

  Future<List<Map<String, dynamic>>> getAllBuildings() async {
    Database db = await instance.database;

    return await db.query('buildings');
  }

  Future<void> deleteBuilding(String buildingName) async {
    Database db = await instance.database;
    await db.delete('buildings', where: 'name = ?', whereArgs: [buildingName]);
  }
}
