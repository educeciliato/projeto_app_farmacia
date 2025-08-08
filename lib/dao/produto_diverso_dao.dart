import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../model/produto_diverso.dart';

class ProdutoDiversoDAO {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<ProdutoDiverso>> getAllProdutosDiversos() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'produtos_diversos',
      where: 'ativo = ?',
      whereArgs: [1],
      orderBy: 'nome',
    );

    return List.generate(maps.length, (i) {
      return ProdutoDiverso.fromMap(maps[i]);
    });
  }

  Future<void> insertProdutoDiverso(ProdutoDiverso produto) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'produtos_diversos',
      produto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProdutoDiverso(ProdutoDiverso produto) async {
    final db = await _databaseHelper.database;
    await db.update(
      'produtos_diversos',
      produto.toMap(),
      where: 'id = ?',
      whereArgs: [produto.id],
    );
  }

  Future<void> deleteProdutoDiverso(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'produtos_diversos',
      {'ativo': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ProdutoDiverso?> getProdutoDiversoById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'produtos_diversos',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ProdutoDiverso.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ProdutoDiverso>> getProdutosByCategoria(String categoria) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'produtos_diversos',
      where: 'categoria = ? AND ativo = ?',
      whereArgs: [categoria, 1],
      orderBy: 'nome',
    );

    return List.generate(maps.length, (i) {
      return ProdutoDiverso.fromMap(maps[i]);
    });
  }

  Future<List<String>> getCategorias() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT categoria FROM produtos_diversos WHERE ativo = 1 AND categoria IS NOT NULL ORDER BY categoria',
    );

    return maps.map((map) => map['categoria'] as String).toList();
  }
}
