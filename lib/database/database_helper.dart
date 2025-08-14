import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'farmacia.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de Laboratórios
    await db.execute('''
      CREATE TABLE laboratorios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        endereco TEXT,
        telefone TEXT,
        email TEXT,
        ativo INTEGER DEFAULT 1
      )
    ''');

    // Tabela de Distribuidoras
    await db.execute('''
      CREATE TABLE distribuidoras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        cnpj TEXT,
        endereco TEXT,
        telefone TEXT,
        email TEXT,
        ativo INTEGER DEFAULT 1
      )
    ''');

    // Tabela de Medicamentos
    await db.execute('''
      CREATE TABLE medicamentos (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        tipo TEXT NOT NULL,
        dose_mg REAL NOT NULL,
        descricao TEXT,
        laboratorio_id INTEGER NOT NULL,
        data_fabricacao TEXT NOT NULL,
        data_validade TEXT NOT NULL,
        lote TEXT NOT NULL,
        quantidade INTEGER NOT NULL,
        is_medicamento_controlado INTEGER DEFAULT 0,
        FOREIGN KEY (laboratorio_id) REFERENCES laboratorios (id)
      )
    ''');

    // Tabela de Produtos Diversos
    await db.execute('''
      CREATE TABLE produtos_diversos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT,
        categoria TEXT,
        preco REAL NOT NULL,
        quantidade_estoque INTEGER NOT NULL,
        ativo INTEGER DEFAULT 1
      )
    ''');

    // Inserir laboratórios padrão
    await db.execute('''
      INSERT INTO laboratorios (nome, endereco, telefone, email) VALUES 
      ('EMS', 'São Paulo - SP', '(11) 1234-5678', 'contato@ems.com.br'),
      ('Medley', 'Rio de Janeiro - RJ', '(21) 9876-5432', 'info@medley.com.br'),
      ('Sanofi', 'São Paulo - SP', '(11) 5555-1234', 'sanofi@sanofi.com.br')
    ''');
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
