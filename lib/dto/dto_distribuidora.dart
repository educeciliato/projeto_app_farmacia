import 'dto.dart';

class DTODistribuidora extends DTO {
  final String? cnpj;
  final String? endereco;
  final String? telefone;
  final String? email;
  final bool ativo;

  DTODistribuidora({
    super.id,
    required super.nome,
    this.cnpj,
    this.endereco,
    this.telefone,
    this.email,
    this.ativo = true,
  });
}
