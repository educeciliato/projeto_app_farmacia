class Distribuidora {
  int? id;
  String nome;
  String? cnpj;
  String? endereco;
  String? telefone;
  String? email;
  bool ativo;

  Distribuidora({
    this.id,
    required this.nome,
    this.cnpj,
    this.endereco,
    this.telefone,
    this.email,
    this.ativo = true,
  });

  factory Distribuidora.fromMap(Map<String, dynamic> map) {
    return Distribuidora(
      id: map['id'],
      nome: map['nome'],
      cnpj: map['cnpj'],
      endereco: map['endereco'],
      telefone: map['telefone'],
      email: map['email'],
      ativo: map['ativo'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'cnpj': cnpj,
      'endereco': endereco,
      'telefone': telefone,
      'email': email,
      'ativo': ativo ? 1 : 0,
    };
  }

  @override
  String toString() {
    return nome;
  }
}
