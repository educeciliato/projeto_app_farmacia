import 'package:flutter/material.dart';

class AdicionarMedicamento extends StatelessWidget {
  final _chaveFormulario = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Medicamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _chaveFormulario,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Laboratório'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Data de Fabricação (YYYY-MM-DD)'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Data de Validade (YYYY-MM-DD)'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Lote'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (valor) {},
                  ),
                  Text('Medicamento Controlado')
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Salvar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
