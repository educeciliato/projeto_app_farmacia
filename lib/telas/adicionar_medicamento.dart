import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../model/medicamento.dart';
import '../model/laboratorio.dart';
import '../provider/medicamento_provider.dart';

class AdicionarMedicamento extends StatefulWidget {
  @override
  _AdicionarMedicamentoState createState() => _AdicionarMedicamentoState();
}

class _AdicionarMedicamentoState extends State<AdicionarMedicamento> {
  final _formKey = GlobalKey<FormState>();
  bool _isMedicamentoControlado = false;
  bool _isLoading = false;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _laboratorioController = TextEditingController();
  final TextEditingController _dataFabricacaoController =
      TextEditingController();
  final TextEditingController _dataValidadeController = TextEditingController();
  final TextEditingController _loteController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();

  Laboratorio? _laboratorioSelecionado;

  @override
  void dispose() {
    _nomeController.dispose();
    _tipoController.dispose();
    _doseController.dispose();
    _descricaoController.dispose();
    _laboratorioController.dispose();
    _dataFabricacaoController.dispose();
    _dataValidadeController.dispose();
    _loteController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildLaboratorioDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Consumer<MedicamentoProvider>(
        builder: (context, provider, child) {
          return DropdownButtonFormField<Laboratorio>(
            decoration: const InputDecoration(
              labelText: 'Laboratório',
              border: OutlineInputBorder(),
            ),
            value: _laboratorioSelecionado,
            items: [
              ...provider.laboratorios
                  .map((lab) => DropdownMenuItem<Laboratorio>(
                        value: lab,
                        child: Text(lab.nome),
                      )),
              const DropdownMenuItem<Laboratorio>(
                value: null,
                child: Text('Outro (digite abaixo)'),
              ),
            ],
            onChanged: (Laboratorio? value) {
              setState(() {
                _laboratorioSelecionado = value;
                if (value != null) {
                  _laboratorioController.text = value.nome;
                } else {
                  _laboratorioController.clear();
                }
              });
            },
            validator: (value) {
              if (value == null && _laboratorioController.text.isEmpty) {
                return 'Por favor, selecione ou digite um laboratório';
              }
              return null;
            },
          );
        },
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _salvarMedicamento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String nomeLaboratorio =
          _laboratorioSelecionado?.nome ?? _laboratorioController.text;

      final newMedicamento = Medicamento(
        id: const Uuid().v4(),
        nome: _nomeController.text,
        tipo: _tipoController.text,
        doseMg: double.parse(_doseController.text),
        descricao: _descricaoController.text,
        laboratorio: nomeLaboratorio,
        dataFabricacao: DateTime.parse(_dataFabricacaoController.text),
        dataValidade: DateTime.parse(_dataValidadeController.text),
        lote: _loteController.text,
        quantidade: int.parse(_quantidadeController.text),
        isMedicamentoControlado: _isMedicamentoControlado,
      );

      await Provider.of<MedicamentoProvider>(context, listen: false)
          .adicionarMedicamento(newMedicamento, nomeLaboratorio);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicamento adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar medicamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Medicamento'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextField('Nome', _nomeController,
                        validator: (value) =>
                            value!.isEmpty ? 'Por favor, insira o nome' : null),
                    _buildTextField(
                        'Tipo (Comprimido, Xarope...)', _tipoController,
                        validator: (value) =>
                            value!.isEmpty ? 'Por favor, insira o tipo' : null),
                    _buildTextField('Dose (mg)', _doseController,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty || double.tryParse(value) == null
                                ? 'Dose inválida'
                                : null),
                    _buildTextField('Descrição', _descricaoController),
                    _buildLaboratorioDropdown(),
                    if (_laboratorioSelecionado == null)
                      _buildTextField(
                          'Nome do Laboratório', _laboratorioController,
                          validator: _laboratorioSelecionado == null
                              ? (value) => value!.isEmpty
                                  ? 'Por favor, insira o laboratório'
                                  : null
                              : null),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _dataFabricacaoController,
                        decoration: InputDecoration(
                          labelText: 'Data de Fabricação (YYYY-MM-DD)',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () =>
                                _selectDate(context, _dataFabricacaoController),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) => value!.isEmpty
                            ? 'Por favor, selecione a data de fabricação'
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _dataValidadeController,
                        decoration: InputDecoration(
                          labelText: 'Data de Validade (YYYY-MM-DD)',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () =>
                                _selectDate(context, _dataValidadeController),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) => value!.isEmpty
                            ? 'Por favor, selecione a data de validade'
                            : null,
                      ),
                    ),
                    _buildTextField('Lote', _loteController,
                        validator: (value) =>
                            value!.isEmpty ? 'Por favor, insira o lote' : null),
                    _buildTextField('Quantidade', _quantidadeController,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty || int.tryParse(value) == null
                                ? 'Quantidade inválida'
                                : null),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
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
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _salvarMedicamento,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Salvar',
                              style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
