import 'package:flutter/material.dart';

class ListarMedicamentos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Medicamentos'),
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, indice) {
          return ListTile(
            title: Text('Medicamento $indice'),
            subtitle: Text('Detalhes do Medicamento $indice'),
          );
        },
      ),
    );
  }
}
