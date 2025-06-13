class Medicamento {
  String id; 
  String nome;
  String tipo; 
  double doseMg;
  String descricao;
  String laboratorio;
  DateTime dataFabricacao;
  DateTime dataValidade;
  String lote;
  int quantidade;
  bool isMedicamentoControlado;

  Medicamento({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.doseMg,
    required this.descricao,
    required this.laboratorio,
    required this.dataFabricacao,
    required this.dataValidade,
    required this.lote,
    required this.quantidade,
    required this.isMedicamentoControlado,
  });

  factory Medicamento.fromMap(Map<String, dynamic> map) {
    return Medicamento(
      id: map['id'] as String,
      nome: map['nome'] as String,
      tipo: map['tipo'] as String,
      doseMg: map['doseMg'] as double,
      descricao: map['descricao'] as String,
      laboratorio: map['laboratorio'] as String,
      dataFabricacao: DateTime.parse(map['dataFabricacao'] as String),
      dataValidade: DateTime.parse(map['dataValidade'] as String),
      lote: map['lote'] as String,
      quantidade: map['quantidade'] as int,
      isMedicamentoControlado: map['isMedicamentoControlado'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'doseMg': doseMg,
      'descricao': descricao,
      'laboratorio': laboratorio,
      'dataFabricacao': dataFabricacao.toIso8601String(),
      'dataValidade': dataValidade.toIso8601String(),
      'lote': lote,
      'quantidade': quantidade,
      'isMedicamentoControlado': isMedicamentoControlado,
    };
  }
}
