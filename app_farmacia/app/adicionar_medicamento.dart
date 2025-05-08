import 'package:flutter/material.dart';

class AdicionarMedicamento extends StatefulWidget {
  @override
  _AdicionarMedicamentoState createState() => _AdicionarMedicamentoState();
}

class _AdicionarMedicamentoState extends State<AdicionarMedicamento> {
  final _formKey = GlobalKey<FormState>();
  bool _isMedicamentoControlado = false;

  Widget _buildTextField(String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Medicamento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('Nome'),
              _buildTextField('Laboratório'),
              _buildTextField('Data de Fabricação (YYYY-MM-DD)'),
              _buildTextField('Data de Validade (YYYY-MM-DD)'),
              _buildTextField('Lote'),
              _buildTextField('Quantidade', keyboardType: TextInputType.number),
              Row(
                children: [
                  Checkbox(
                    value: _isMedicamentoControlado,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _isMedicamentoControlado = newValue ?? false;
                      });
                    },
                  ),
                  const Text('Medicamento Controlado'),
                ],
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
