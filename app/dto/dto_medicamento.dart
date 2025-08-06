import 'dto.dart';

class DTOMedicamento extends DTO {
  final String tipo; 
  final double doseMg;
  final String? descricao;
  final int laboratorioId; 
  final String dataFabricacao; 
  final String dataValidade; 
  final String lote;
  final int quantidade;
  final bool isMedicamentoControlado; 

  DTOMedicamento({
    super.id,
    required super.nome,
    required this.tipo,
    required this.doseMg,
    this.descricao,
    required this.laboratorioId,
    required this.dataFabricacao,
    required this.dataValidade,
    required this.lote,
    required this.quantidade,
    this.isMedicamentoControlado = false,
  });
}
