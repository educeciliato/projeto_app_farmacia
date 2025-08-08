class Laboratorio {
  int? id;
  String nome;
  String? endereco;
  String? telefone;
  String? email;
  bool ativo;

  Laboratorio({
    this.id,
    required this.nome,
    this.endereco,
    this.telefone,
    this.email,
    this.ativo = true,
  });

  factory Laboratorio.fromMap(Map<String, dynamic> map) {
    return Laboratorio(
      id: map['id'],
      nome: map['nome'],
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
