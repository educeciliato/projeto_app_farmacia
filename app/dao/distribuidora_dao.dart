import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../model/distribuidora.dart';

class DistribuidoraDAO {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Distribuidora>> getAllDistribuidoras() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'distribuidoras',
      where: 'ativo = ?',
      whereArgs: [1],
      orderBy: 'nome',
    );

    return List.generate(maps.length, (i) {
      return Distribuidora.fromMap(maps[i]);
    });
  }

  Future<void> insertDistribuidora(Distribuidora distribuidora) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'distribuidoras',
      distribuidora.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateDistribuidora(Distribuidora distribuidora) async {
    final db = await _databaseHelper.database;
    await db.update(
      'distribuidoras',
      distribuidora.toMap(),
      where: 'id = ?',
      whereArgs: [distribuidora.id],
    );
  }

  Future<void> deleteDistribuidora(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'distribuidoras',
      {'ativo': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Distribuidora?> getDistribuidoraById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'distribuidoras',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Distribuidora.fromMap(maps.first);
    }
    return null;
  }

  Future<Distribuidora?> getDistribuidoraByNome(String nome) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'distribuidoras',
      where: 'nome = ? AND ativo = ?',
      whereArgs: [nome, 1],
    );

    if (maps.isNotEmpty) {
      return Distribuidora.fromMap(maps.first);
    }
    return null;
  }
}
