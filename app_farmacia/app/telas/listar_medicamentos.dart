import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/medicamento_provider.dart';
import '../widgets/botao.dart'; 

class ListarMedicamentos extends StatelessWidget {
  const ListarMedicamentos({super.key});

  @override
  Widget build(BuildContext context) {
    final medicamentoProvider = Provider.of<MedicamentoProvider>(context);
    final medicamentos = medicamentoProvider.medicamentos;

    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Medicamentos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Botao(
              rotulo: 'Remover do Estoque',
              cor: Colors.red,
              aoPressionar: () => Navigator.pushNamed(context, '/remover'),
            ),
          ),
          Expanded(
            child: medicamentos.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum medicamento no estoque',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: medicamentos.length,
                    itemBuilder: (context, indice) {
                      final medicamento = medicamentos[indice];
                      return ListTile(
                        title: Text(
                            '${medicamento.nome} ${medicamento.doseMg.toStringAsFixed(0)}mg'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${medicamento.tipo} - ${medicamento.descricao}'),
                            Text('Laboratório: ${medicamento.laboratorio}'),
                            Text(
                                'Data de Fabricação: ${DateFormat('yyyy-MM-dd').format(medicamento.dataFabricacao)}'),
                            Text(
                                'Data de Validade: ${DateFormat('yyyy-MM-dd').format(medicamento.dataValidade)}'),
                            Text(
                                'Quantidade: ${medicamento.quantidade} - Lote: ${medicamento.lote}'),
                            if (medicamento.isMedicamentoControlado)
                              const Text('Medicamento Controlado',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                          ],
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
