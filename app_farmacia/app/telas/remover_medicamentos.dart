import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/medicamento.dart';
import '../provider/medicamento_provider.dart';
import '../widgets/botao.dart';

class RemoverMedicamentos extends StatefulWidget {
  const RemoverMedicamentos({super.key});

  @override
  _RemoverMedicamentosState createState() => _RemoverMedicamentosState();
}

class _RemoverMedicamentosState extends State<RemoverMedicamentos> {
  List<Medicamento> _medicamentosSelecionadosParaRemover = [];

  void removerSelecionados() {
    if (_medicamentosSelecionadosParaRemover.isNotEmpty) {
      Provider.of<MedicamentoProvider>(context, listen: false)
          .removerMedicamentos(_medicamentosSelecionadosParaRemover);

      setState(() {
        _medicamentosSelecionadosParaRemover =
            []; 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medicamentos removidos!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione ao menos um medicamento para remover.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicamentoProvider = Provider.of<MedicamentoProvider>(context);
    final medicamentosDisponiveis = medicamentoProvider.medicamentos;

    return Scaffold(
      appBar: AppBar(title: const Text('Remover Medicamentos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Botao(
              rotulo: 'Remover Selecionados',
              cor: Colors.red,
              aoPressionar: removerSelecionados,
            ),
          ),
          Expanded(
            child: medicamentosDisponiveis.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum medicamento no estoque',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: medicamentosDisponiveis.length,
                    itemBuilder: (context, indice) {
                      final medicamento = medicamentosDisponiveis[indice];
                      return CheckboxListTile(
                        title: Text(
                            '${medicamento.nome} ${medicamento.doseMg.toStringAsFixed(0)}mg'),
                        subtitle: Text(
                            '${medicamento.tipo} - Qtd: ${medicamento.quantidade}'),
                        value: _medicamentosSelecionadosParaRemover
                            .contains(medicamento),
                        onChanged: (bool? valor) {
                          setState(() {
                            if (valor == true) {
                              _medicamentosSelecionadosParaRemover
                                  .add(medicamento);
                            } else {
                              _medicamentosSelecionadosParaRemover
                                  .remove(medicamento);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
