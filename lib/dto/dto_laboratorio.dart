import 'dto.dart';

class DTOLaboratorio extends DTO {
  final String? endereco;
  final String? telefone;
  final String? email;
  final bool ativo;

  DTOLaboratorio({
    super.id,
    required super.nome,
    this.endereco,
    this.telefone,
    this.email,
    this.ativo = true,
  });
}
