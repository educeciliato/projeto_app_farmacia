import 'dto.dart';

class DTOProdutoDiverso extends DTO {
  final String? descricao;
  final String? categoria;
  final double preco;
  final int quantidadeEstoque;
  final bool ativo;

  DTOProdutoDiverso({
    super.id,
    required super.nome,
    this.descricao,
    this.categoria,
    required this.preco,
    required this.quantidadeEstoque,
    this.ativo = true,
  });
}
