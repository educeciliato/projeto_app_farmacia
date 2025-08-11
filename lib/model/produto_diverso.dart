class ProdutoDiverso {
  int? id;
  String nome;
  String? descricao;
  String? categoria;
  double preco;
  int quantidadeEstoque;
  bool ativo;

  ProdutoDiverso({
    this.id,
    required this.nome,
    this.descricao,
    this.categoria,
    required this.preco,
    required this.quantidadeEstoque,
    this.ativo = true,
  });

  factory ProdutoDiverso.fromMap(Map<String, dynamic> map) {
    return ProdutoDiverso(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      categoria: map['categoria'],
      preco: map['preco']?.toDouble() ?? 0.0,
      quantidadeEstoque: map['quantidade_estoque'] ?? 0,
      ativo: map['ativo'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'categoria': categoria,
      'preco': preco,
      'quantidade_estoque': quantidadeEstoque,
      'ativo': ativo ? 1 : 0,
    };
  }

  @override
  String toString() {
    return nome;
  }
}
