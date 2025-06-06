import 'package:flutter/material.dart';
import 'botao.dart';
import 'controle_estoque.dart';

class RemoverMedicamentos extends StatefulWidget {
  const RemoverMedicamentos({super.key});

  @override
  _RemoverMedicamentosState createState() => _RemoverMedicamentosState();
}

class _RemoverMedicamentosState extends State<RemoverMedicamentos> {
  List<bool> selecionados = [];

  @override
  void initState() {
    super.initState();
    selecionados = List<bool>.filled(medicamentos.length, false);
  }

  void removerSelecionados() {
    setState(() {
      for (int i = medicamentos.length - 1; i >= 0; i--) {
        if (selecionados[i]) {
          medicamentos.removeAt(i);
        }
      }
      selecionados = List<bool>.filled(medicamentos.length, false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medicamentos removidos!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remover Medicamentos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Botao(
              rotulo: 'Remover Selecionados',
              cor: Colors.red,
              aoPressionar:
                  selecionados.contains(true) ? removerSelecionados : () {},
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
                      return CheckboxListTile(
                        title: Text(
                            '${medicamento['nome']} ${medicamento['dose']}'),
                        subtitle: Text(
                            '${medicamento['tipo']} - Qtd: ${medicamento['quantidade']}'),
                        value: selecionados[indice],
                        onChanged: (bool? valor) {
                          setState(() {
                            selecionados[indice] = valor ?? false;
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
