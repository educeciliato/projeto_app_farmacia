// Modelo para relacionamento N:N entre Distribuidoras e Medicamentos
class FornecedorMedicamento {
  int? id;
  int distribuidoraId;
  String medicamentoId;
  double preco;
  DateTime dataUltimaCompra;
  bool ativo;

  // Propriedades calculadas para exibição
  String? distribuidoraNome;
  String? medicamentoNome;

  FornecedorMedicamento({
    this.id,
    required this.distribuidoraId,
    required this.medicamentoId,
    required this.preco,
    required this.dataUltimaCompra,
    this.ativo = true,
    this.distribuidoraNome,
    this.medicamentoNome,
  });

  factory FornecedorMedicamento.fromMap(Map<String, dynamic> map) {
    return FornecedorMedicamento(
      id: map['id'],
      distribuidoraId: map['distribuidora_id'],
      medicamentoId: map['medicamento_id'],
      preco: map['preco']?.toDouble() ?? 0.0,
      dataUltimaCompra: DateTime.parse(map['data_ultima_compra']),
      ativo: map['ativo'] == 1,
      distribuidoraNome: map['distribuidora_nome'],
      medicamentoNome: map['medicamento_nome'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'distribuidora_id': distribuidoraId,
      'medicamento_id': medicamentoId,
      'preco': preco,
      'data_ultima_compra': dataUltimaCompra.toIso8601String(),
      'ativo': ativo ? 1 : 0,
    };
  }
}
