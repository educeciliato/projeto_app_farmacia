import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../model/fornecedor_medicamento.dart';

class FornecedorMedicamentoDAO {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<FornecedorMedicamento>> getAllFornecedorMedicamentos() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT fm.*, d.nome as distribuidora_nome, m.nome as medicamento_nome
      FROM fornecedor_medicamento fm
      INNER JOIN distribuidoras d ON fm.distribuidora_id = d.id
      INNER JOIN medicamentos m ON fm.medicamento_id = m.id
      WHERE fm.ativo = 1
      ORDER BY d.nome, m.nome
    ''');

    return List.generate(maps.length, (i) {
      return FornecedorMedicamento.fromMap(maps[i]);
    });
  }

  Future<void> insertFornecedorMedicamento(
      FornecedorMedicamento fornecedor) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'fornecedor_medicamento',
      fornecedor.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateFornecedorMedicamento(
      FornecedorMedicamento fornecedor) async {
    final db = await _databaseHelper.database;
    await db.update(
      'fornecedor_medicamento',
      fornecedor.toMap(),
      where: 'id = ?',
      whereArgs: [fornecedor.id],
    );
  }

  Future<void> deleteFornecedorMedicamento(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'fornecedor_medicamento',
      {'ativo': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<FornecedorMedicamento>> getFornecedoresByMedicamento(
      String medicamentoId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT fm.*, d.nome as distribuidora_nome, m.nome as medicamento_nome
      FROM fornecedor_medicamento fm
      INNER JOIN distribuidoras d ON fm.distribuidora_id = d.id
      INNER JOIN medicamentos m ON fm.medicamento_id = m.id
      WHERE fm.medicamento_id = ? AND fm.ativo = 1
      ORDER BY fm.preco
    ''', [medicamentoId]);

    return List.generate(maps.length, (i) {
      return FornecedorMedicamento.fromMap(maps[i]);
    });
  }

  Future<List<FornecedorMedicamento>> getMedicamentosByDistribuidora(
      int distribuidoraId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT fm.*, d.nome as distribuidora_nome, m.nome as medicamento_nome
      FROM fornecedor_medicamento fm
      INNER JOIN distribuidoras d ON fm.distribuidora_id = d.id
      INNER JOIN medicamentos m ON fm.medicamento_id = m.id
      WHERE fm.distribuidora_id = ? AND fm.ativo = 1
      ORDER BY m.nome
    ''', [distribuidoraId]);

    return List.generate(maps.length, (i) {
      return FornecedorMedicamento.fromMap(maps[i]);
    });
  }

  Future<bool> existeRelacionamento(
      int distribuidoraId, String medicamentoId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fornecedor_medicamento',
      where: 'distribuidora_id = ? AND medicamento_id = ? AND ativo = ?',
      whereArgs: [distribuidoraId, medicamentoId, 1],
    );

    return maps.isNotEmpty;
  }
}
