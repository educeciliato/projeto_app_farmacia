import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../model/laboratorio.dart';

class LaboratorioDAO {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Laboratorio>> getAllLaboratorios() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'laboratorios',
      where: 'ativo = ?',
      whereArgs: [1],
      orderBy: 'nome',
    );

    return List.generate(maps.length, (i) {
      return Laboratorio.fromMap(maps[i]);
    });
  }

  Future<void> insertLaboratorio(Laboratorio laboratorio) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'laboratorios',
      laboratorio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateLaboratorio(Laboratorio laboratorio) async {
    final db = await _databaseHelper.database;
    await db.update(
      'laboratorios',
      laboratorio.toMap(),
      where: 'id = ?',
      whereArgs: [laboratorio.id],
    );
  }

  Future<void> deleteLaboratorio(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'laboratorios',
      {'ativo': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Laboratorio?> getLaboratorioById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'laboratorios',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Laboratorio.fromMap(maps.first);
    }
    return null;
  }

  Future<Laboratorio?> getLaboratorioByNome(String nome) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'laboratorios',
      where: 'nome = ? AND ativo = ?',
      whereArgs: [nome, 1],
    );

    if (maps.isNotEmpty) {
      return Laboratorio.fromMap(maps.first);
    }
    return null;
  }
}
