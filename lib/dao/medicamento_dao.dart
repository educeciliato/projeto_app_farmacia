import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../model/medicamento.dart';

class MedicamentoDAO {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Medicamento>> getAllMedicamentos() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT m.*, l.nome as laboratorio_nome 
      FROM medicamentos m 
      INNER JOIN laboratorios l ON m.laboratorio_id = l.id
      ORDER BY m.nome
    ''');

    return List.generate(maps.length, (i) {
      return Medicamento(
        id: maps[i]['id'],
        nome: maps[i]['nome'],
        tipo: maps[i]['tipo'],
        doseMg: maps[i]['dose_mg'],
        descricao: maps[i]['descricao'] ?? '',
        laboratorio: maps[i]['laboratorio_nome'],
        dataFabricacao: DateTime.parse(maps[i]['data_fabricacao']),
        dataValidade: DateTime.parse(maps[i]['data_validade']),
        lote: maps[i]['lote'],
        quantidade: maps[i]['quantidade'],
        isMedicamentoControlado: maps[i]['is_medicamento_controlado'] == 1,
      );
    });
  }

  Future<void> insertMedicamento(
      Medicamento medicamento, int laboratorioId) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'medicamentos',
      {
        'id': medicamento.id,
        'nome': medicamento.nome,
        'tipo': medicamento.tipo,
        'dose_mg': medicamento.doseMg,
        'descricao': medicamento.descricao,
        'laboratorio_id': laboratorioId,
        'data_fabricacao': medicamento.dataFabricacao.toIso8601String(),
        'data_validade': medicamento.dataValidade.toIso8601String(),
        'lote': medicamento.lote,
        'quantidade': medicamento.quantidade,
        'is_medicamento_controlado':
            medicamento.isMedicamentoControlado ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMedicamento(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'medicamentos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteMedicamentos(List<String> ids) async {
    final db = await _databaseHelper.database;
    final batch = db.batch();

    for (String id in ids) {
      batch.delete(
        'medicamentos',
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit();
  }

  Future<void> updateMedicamento(
      Medicamento medicamento, int laboratorioId) async {
    final db = await _databaseHelper.database;
    await db.update(
      'medicamentos',
      {
        'nome': medicamento.nome,
        'tipo': medicamento.tipo,
        'dose_mg': medicamento.doseMg,
        'descricao': medicamento.descricao,
        'laboratorio_id': laboratorioId,
        'data_fabricacao': medicamento.dataFabricacao.toIso8601String(),
        'data_validade': medicamento.dataValidade.toIso8601String(),
        'lote': medicamento.lote,
        'quantidade': medicamento.quantidade,
        'is_medicamento_controlado':
            medicamento.isMedicamentoControlado ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [medicamento.id],
    );
  }

  Future<Medicamento?> getMedicamentoById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT m.*, l.nome as laboratorio_nome 
      FROM medicamentos m 
      INNER JOIN laboratorios l ON m.laboratorio_id = l.id
      WHERE m.id = ?
    ''', [id]);

    if (maps.isNotEmpty) {
      return Medicamento(
        id: maps[0]['id'],
        nome: maps[0]['nome'],
        tipo: maps[0]['tipo'],
        doseMg: maps[0]['dose_mg'],
        descricao: maps[0]['descricao'] ?? '',
        laboratorio: maps[0]['laboratorio_nome'],
        dataFabricacao: DateTime.parse(maps[0]['data_fabricacao']),
        dataValidade: DateTime.parse(maps[0]['data_validade']),
        lote: maps[0]['lote'],
        quantidade: maps[0]['quantidade'],
        isMedicamentoControlado: maps[0]['is_medicamento_controlado'] == 1,
      );
    }
    return null;
  }
}
