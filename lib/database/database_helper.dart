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
      version: 2, // Incrementamos a versão
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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

    // Tabela de relacionamento N:N entre Distribuidoras e Medicamentos
    await db.execute('''
      CREATE TABLE fornecedor_medicamento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        distribuidora_id INTEGER NOT NULL,
        medicamento_id TEXT NOT NULL,
        preco REAL NOT NULL,
        data_ultima_compra TEXT NOT NULL,
        ativo INTEGER DEFAULT 1,
        FOREIGN KEY (distribuidora_id) REFERENCES distribuidoras (id),
        FOREIGN KEY (medicamento_id) REFERENCES medicamentos (id),
        UNIQUE(distribuidora_id, medicamento_id)
      )
    ''');

    // Tabela para dados sincronizados da API
    await db.execute('''
      CREATE TABLE sync_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        last_sync TEXT NOT NULL,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    // Inserir dados padrão
    await _insertDefaultData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adicionar novas tabelas na versão 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS fornecedor_medicamento (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          distribuidora_id INTEGER NOT NULL,
          medicamento_id TEXT NOT NULL,
          preco REAL NOT NULL,
          data_ultima_compra TEXT NOT NULL,
          ativo INTEGER DEFAULT 1,
          FOREIGN KEY (distribuidora_id) REFERENCES distribuidoras (id),
          FOREIGN KEY (medicamento_id) REFERENCES medicamentos (id),
          UNIQUE(distribuidora_id, medicamento_id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS sync_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          table_name TEXT NOT NULL,
          record_id TEXT NOT NULL,
          last_sync TEXT NOT NULL,
          sync_status TEXT DEFAULT 'pending'
        )
      ''');
    }
  }

  Future<void> _insertDefaultData(Database db) async {
    // Inserir laboratórios padrão
    await db.execute('''
      INSERT INTO laboratorios (nome, endereco, telefone, email) VALUES 
      ('EMS', 'São Paulo - SP', '(11) 1234-5678', 'contato@ems.com.br'),
      ('Medley', 'Rio de Janeiro - RJ', '(21) 9876-5432', 'info@medley.com.br'),
      ('Sanofi', 'São Paulo - SP', '(11) 5555-1234', 'sanofi@sanofi.com.br'),
      ('Roche', 'São Paulo - SP', '(11) 3333-4444', 'contato@roche.com.br'),
      ('Pfizer', 'São Paulo - SP', '(11) 2222-3333', 'info@pfizer.com.br')
    ''');

    // Inserir distribuidoras padrão
    await db.execute('''
      INSERT INTO distribuidoras (nome, cnpj, endereco, telefone, email) VALUES 
      ('Distribuidora Alfa', '11.222.333/0001-44', 'São Paulo - SP', '(11) 1111-2222', 'contato@alfa.com.br'),
      ('Beta Medicamentos', '22.333.444/0001-55', 'Rio de Janeiro - RJ', '(21) 3333-4444', 'vendas@beta.com.br'),
      ('Gama Distribuidora', '33.444.555/0001-66', 'Belo Horizonte - MG', '(31) 5555-6666', 'comercial@gama.com.br'),
      ('Delta Farma', '44.555.666/0001-77', 'Curitiba - PR', '(41) 7777-8888', 'pedidos@delta.com.br')
    ''');

    // Inserir produtos diversos padrão
    await db.execute('''
      INSERT INTO produtos_diversos (nome, descricao, categoria, preco, quantidade_estoque) VALUES 
      ('Algodão Hidrófilo', 'Algodão para uso hospitalar', 'Higiene', 5.90, 100),
      ('Seringa 5ml', 'Seringa descartável 5ml', 'Material Médico', 0.80, 500),
      ('Luva Descartável', 'Luva de procedimento', 'EPI', 0.25, 1000),
      ('Álcool 70%', 'Álcool etílico 70% 1L', 'Higiene', 12.50, 50),
      ('Termômetro Digital', 'Termômetro clínico digital', 'Equipamento', 25.90, 20),
      ('Máscara Cirúrgica', 'Máscara descartável tripla camada', 'EPI', 0.50, 800),
      ('Esparadrapo', 'Esparadrapo hipoalergênico 5cm', 'Material Médico', 8.90, 75)
    ''');
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }

  // Método para limpeza de dados antigos
  Future<void> cleanOldSyncData() async {
    final db = await database;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    await db.delete(
      'sync_data',
      where: 'last_sync < ? AND sync_status = ?',
      whereArgs: [thirtyDaysAgo.toIso8601String(), 'synced'],
    );
  }
}
