import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/medicamento_provider.dart';
import '../model/laboratorio.dart';

class GerenciarLaboratorios extends StatefulWidget {
  const GerenciarLaboratorios({super.key});

  @override
  State<GerenciarLaboratorios> createState() => _GerenciarLaboratoriosState();
}

class _GerenciarLaboratoriosState extends State<GerenciarLaboratorios> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _enderecoController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _adicionarLaboratorio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final novoLaboratorio = Laboratorio(
        nome: _nomeController.text,
        endereco:
            _enderecoController.text.isEmpty ? null : _enderecoController.text,
        telefone:
            _telefoneController.text.isEmpty ? null : _telefoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
      );

      await Provider.of<MedicamentoProvider>(context, listen: false)
          .adicionarLaboratorio(novoLaboratorio);

      if (mounted) {
        _limparFormulario();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laboratório adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar laboratório: $e'),
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

  void _limparFormulario() {
    _nomeController.clear();
    _enderecoController.clear();
    _telefoneController.clear();
    _emailController.clear();
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Laboratórios'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<MedicamentoProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Formulário para adicionar laboratório
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Adicionar Novo Laboratório',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'Nome do Laboratório *',
                            _nomeController,
                            validator: (value) => value!.isEmpty
                                ? 'Por favor, insira o nome'
                                : null,
                          ),
                          _buildTextField('Endereço', _enderecoController),
                          _buildTextField('Telefone', _telefoneController),
                          _buildTextField('Email', _emailController),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _adicionarLaboratorio,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple.shade700,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text('Adicionar Laboratório'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Lista de laboratórios existentes
                const Text(
                  'Laboratórios Cadastrados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (provider.laboratorios.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'Nenhum laboratório cadastrado',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.laboratorios.length,
                    itemBuilder: (context, index) {
                      final laboratorio = provider.laboratorios[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple.shade700,
                            child: const Icon(
                              Icons.science,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            laboratorio.nome,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (laboratorio.endereco != null)
                                Text('Endereço: ${laboratorio.endereco}'),
                              if (laboratorio.telefone != null)
                                Text('Telefone: ${laboratorio.telefone}'),
                              if (laboratorio.email != null)
                                Text('Email: ${laboratorio.email}'),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ID: ${laboratorio.id}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Icon(
                                laboratorio.ativo
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: laboratorio.ativo
                                    ? Colors.green
                                    : Colors.red,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
