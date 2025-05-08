import 'package:flutter/material.dart';

class ListarMedicamentos extends StatelessWidget {
  const ListarMedicamentos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Medicamentos')),
      body: ListView.builder(
        itemCount: 5, 
        itemBuilder: (context, indice) {
          return MedicamentoTile(indice: indice);
        },
      ),
    );
  }
}

class MedicamentoTile extends StatelessWidget {
  final int indice;

  const MedicamentoTile({super.key, required this.indice});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Medicamento $indice'),
      subtitle: Text('Detalhes do Medicamento $indice'),
    );
  }
}
