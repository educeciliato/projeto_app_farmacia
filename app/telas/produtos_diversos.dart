import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../dao/fornecedor_medicamento_dao.dart';
import '../dao/distribuidora_dao.dart';
import '../dao/medicamento_dao.dart';
import '../model/fornecedor_medicamento.dart';
import '../model/distribuidora.dart';
import '../model/medicamento.dart';
import '../provider/medicamento_provider.dart';

class FornecedoresMedicamentos extends StatefulWidget {
  const FornecedoresMedicamentos({super.key});

  @override
  State<FornecedoresMedicamentos> createState() =>
      _FornecedoresMedicamentosState();
}

class _FornecedoresMedicamentosState extends State<FornecedoresMedicamentos> {
  final FornecedorMedicamentoDAO _fornecedorDAO = FornecedorMedicamentoDAO();
  final DistribuidoraDAO _distribuidoraDAO = DistribuidoraDAO();
  final MedicamentoDAO _medicamentoDAO = MedicamentoDAO();

  final _formKey = GlobalKey<FormState>();
  final _precoController = TextEditingController();

  List<FornecedorMedicamento> _fornecedores = [];
  List<Distribuidora> _distribuidoras = [];
  List<Medicamento> _medicamentos = [];

  Distribuidora? _distribuidoraSelecionada;
  Medicamento? _medicamentoSelecionado;
  DateTime _dataUltimaCompra = DateTime.now();

  bool _isLoading = false;
  bool _isAdding = false;
  String _filtroTexto = '';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fornecedores = await _fornecedorDAO.getAllFornecedorMedicamentos();
      final distribuidoras = await _distribuidoraDAO.getAllDistribuidoras();
      final medicamentos = await _medicamentoDAO.getAllMedicamentos();

      setState(() {
        _fornecedores = fornecedores;
        _distribuidoras = distribuidoras;
        _medicamentos = medicamentos;
      });
    } catch (e) {
      _mostrarErro('Erro ao carregar dados: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _adicionarFornecedor() async {
    if (!_formKey.currentState!.validate()) return;

    if (_distribuidoraSelecionada == null || _medicamentoSelecionado == null) {
      _mostrarErro('Selecione uma distribuidora e um medicamento');
      return;
    }

    // Verificar se já existe o relacionamento
    final existeRelacionamento = await _fornecedorDAO.existeRelacionamento(
      _distribuidoraSelecionada!.id!,
      _medicamentoSelecionado!.id,
    );

    if (existeRelacionamento) {
      _mostrarErro('Este relacionamento já existe');
      return;
    }

    setState(() {
      _isAdding = true;
    });

    try {
      final novoFornecedor = FornecedorMedicamento(
        distribuidoraId: _distribuidoraSelecionada!.id!,
        medicamentoId: _medicamentoSelecionado!.id,
        preco: double.parse(_precoController.text),
        dataUltimaCompra: _dataUltimaCompra,
      );

      await _fornecedorDAO.insertFornecedorMedicamento(novoFornecedor);
      await _carregarDados();
      _limparFormulario();
      _mostrarSucesso('Relacionamento criado com sucesso!');
    } catch (e) {
      _mostrarErro('Erro ao criar relacionamento: $e');
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  void _limparFormulario() {
    _distribuidoraSelecionada = null;
    _medicamentoSelecionado = null;
    _precoController.clear();
    _dataUltimaCompra = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fornecedores x Medicamentos'),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informações sobre relacionamento N:N
                  _buildInfoCard(),

                  const SizedBox(height: 20),

                  // Formulário para criar relacionamento
                  _buildFormulario(),

                  const SizedBox(height: 20),

                  // Filtro e estatísticas
                  _buildFiltroEstatisticas(),

                  const SizedBox(height: 20),

                  // Lista de relacionamentos
                  _buildListaRelacionamentos(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.deepPurple.shade700),
                const SizedBox(width: 8),
                Text(
                  'Relacionamento Muitos-para-Muitos (N:N)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Este módulo gerencia o relacionamento entre Distribuidoras e Medicamentos, '
              'permitindo que uma distribuidora forneça vários medicamentos e um medicamento '
              'seja fornecido por várias distribuidoras, com preços e datas específicas.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatChip(
                    'Distribuidoras', _distribuidoras.length, Colors.blue),
                const SizedBox(width: 8),
                _buildStatChip(
                    'Medicamentos', _medicamentos.length, Colors.green),
                const SizedBox(width: 8),
                _buildStatChip(
                    'Relacionamentos', _fornecedores.length, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int value, Color color) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildFormulario() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Criar Novo Relacionamento',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Dropdown Distribuidora
              DropdownButtonFormField<Distribuidora>(
                decoration: const InputDecoration(
                  labelText: 'Distribuidora',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                value: _distribuidoraSelecionada,
                items: _distribuidoras
                    .map(
                      (dist) => DropdownMenuItem(
                        value: dist,
                        child: Text(dist.nome),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _distribuidoraSelecionada = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecione uma distribuidora' : null,
              ),

              const SizedBox(height: 12),

              // Dropdown Medicamento
              DropdownButtonFormField<Medicamento>(
                decoration: const InputDecoration(
                  labelText: 'Medicamento',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
                value: _medicamentoSelecionado,
                items: _medicamentos
                    .map(
                      (med) => DropdownMenuItem(
                        value: med,
                        child: Text(
                            '${med.nome} ${med.doseMg}mg - ${med.laboratorio}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _medicamentoSelecionado = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecione um medicamento' : null,
              ),

              const SizedBox(height: 12),

              // Campo Preço
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(
                  labelText: 'Preço (R\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Digite o preço';
                  if (double.tryParse(value) == null) return 'Preço inválido';
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Campo Data
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Data da Última Compra',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _selecionarData,
                  ),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('dd/MM/yyyy').format(_dataUltimaCompra),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAdding ? null : _adicionarFornecedor,
                  icon: _isAdding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label:
                      Text(_isAdding ? 'Criando...' : 'Criar Relacionamento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltroEstatisticas() {
    final fornecedoresFiltrados = _aplicarFiltro();
    final precoMedio = fornecedoresFiltrados.isEmpty
        ? 0.0
        : fornecedoresFiltrados.fold<double>(0.0, (sum, f) => sum + f.preco) /
            fornecedoresFiltrados.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Filtrar por distribuidora ou medicamento',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _filtroTexto = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                      'Total', '${fornecedoresFiltrados.length}', Colors.blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('Preço Médio',
                      'R\$ ${precoMedio.toStringAsFixed(2)}', Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildListaRelacionamentos() {
    final fornecedoresFiltrados = _aplicarFiltro();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.link, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Text(
                  'Relacionamentos Ativos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${fornecedoresFiltrados.length} item(ns)',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          if (fornecedoresFiltrados.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.link_off, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Nenhum relacionamento encontrado',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fornecedoresFiltrados.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final fornecedor = fornecedoresFiltrados[index];
                return _buildFornecedorItem(fornecedor);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFornecedorItem(FornecedorMedicamento fornecedor) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple.shade700,
        child: const Icon(Icons.link, color: Colors.white),
      ),
      title: Text(
        '${fornecedor.distribuidoraNome} ↔ ${fornecedor.medicamentoNome}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preço: R\$ ${fornecedor.preco.toStringAsFixed(2)}'),
          Text(
            'Última compra: ${DateFormat('dd/MM/yyyy').format(fornecedor.dataUltimaCompra)}',
          ),
          Text(
            'ID: ${fornecedor.id}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _acaoFornecedor(value, fornecedor),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'editar',
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.orange),
                SizedBox(width: 8),
                Text('Editar'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'deletar',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Deletar'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'historico',
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.blue),
                SizedBox(width: 8),
                Text('Histórico'),
              ],
            ),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

  List<FornecedorMedicamento> _aplicarFiltro() {
    if (_filtroTexto.isEmpty) return _fornecedores;

    return _fornecedores.where((f) {
      final distribuidora = f.distribuidoraNome?.toLowerCase() ?? '';
      final medicamento = f.medicamentoNome?.toLowerCase() ?? '';
      final filtro = _filtroTexto.toLowerCase();

      return distribuidora.contains(filtro) || medicamento.contains(filtro);
    }).toList();
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataUltimaCompra,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dataUltimaCompra = picked;
      });
    }
  }

  Future<void> _acaoFornecedor(
      String acao, FornecedorMedicamento fornecedor) async {
    switch (acao) {
      case 'editar':
        _editarFornecedor(fornecedor);
        break;
      case 'deletar':
        _confirmarDelecao(fornecedor);
        break;
      case 'historico':
        _mostrarHistorico(fornecedor);
        break;
    }
  }

  void _editarFornecedor(FornecedorMedicamento fornecedor) {
    // Implementar edição
    _mostrarMensagem('Funcionalidade de edição em desenvolvimento');
  }

  void _confirmarDelecao(FornecedorMedicamento fornecedor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir este relacionamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletarFornecedor(fornecedor);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletarFornecedor(FornecedorMedicamento fornecedor) async {
    try {
      await _fornecedorDAO.deleteFornecedorMedicamento(fornecedor.id!);
      await _carregarDados();
      _mostrarSucesso('Relacionamento excluído com sucesso!');
    } catch (e) {
      _mostrarErro('Erro ao excluir relacionamento: $e');
    }
  }

  void _mostrarHistorico(FornecedorMedicamento fornecedor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Histórico do Relacionamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distribuidora: ${fornecedor.distribuidoraNome}'),
            Text('Medicamento: ${fornecedor.medicamentoNome}'),
            Text('Preço Atual: R\$ ${fornecedor.preco.toStringAsFixed(2)}'),
            Text(
                'Última Compra: ${DateFormat('dd/MM/yyyy').format(fornecedor.dataUltimaCompra)}'),
            const SizedBox(height: 16),
            const Text(
              'Histórico completo em desenvolvimento...',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _mostrarSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
