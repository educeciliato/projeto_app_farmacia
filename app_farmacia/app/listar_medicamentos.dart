import 'package:flutter/material.dart';

import 'botao.dart';
import 'controle_estoque.dart';

class ListarMedicamentos extends StatelessWidget {
  const ListarMedicamentos({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: ListView.builder(
              itemCount: medicamentos.length,
              itemBuilder: (context, indice) {
                final medicamento = medicamentos[indice];
                return ListTile(
                  title: Text('${medicamento['nome']} ${medicamento['dose']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${medicamento['tipo']} - ${medicamento['descricao']}'),
                      Text('Laboratório: ${medicamento['laboratorio']}'),
                      Text(
                          'Data de Fabricação: ${medicamento['Data de Fabricacao']}'),
                      Text(
                          'Data de Validade: ${medicamento['Data de Validade']}'),
                      Text(
                          'Quantidade: ${medicamento['quantidade']} - Lote: ${medicamento['lote']}'),
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
