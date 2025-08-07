import 'package:flutter/material.dart';
import '../dao/produto_diverso_dao.dart';
import '../model/produto_diverso.dart';

class ProdutosDiversos extends StatefulWidget {
  const ProdutosDiversos({super.key});

  @override
  State<ProdutosDiversos> createState() => _ProdutosDiversosState();
}

class _ProdutosDiversosState extends State<ProdutosDiversos> {
  final ProdutoDiversoDAO _produtoDAO = ProdutoDiversoDAO();
  final _formKey = GlobalKey<FormState>();
  
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _precoController = TextEditingController();
  final _quantidadeController = TextEditingController();
  
  List<ProdutoDiverso> _produtos = [];
  List<String> _categorias = [];
  String? _categoriaSelecionada;
  String _filtroTexto = '';
  String _filtroCategoria = 'Todas';
  bool _isLoading = false;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _categoriaController.dispose();
    _precoController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final produtos = await _produtoDAO.getAllProdutosDiversos();
      final categorias = await _produtoDAO.getCategorias();
      
      setState(() {
        _produtos = produtos;
        _categorias = ['Todas', ...categorias];
      });
    } catch (e) {
      _mostrarErro('Erro ao carregar dados: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _adicionarProduto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAdding = true;
    });

    try {
      final novoProduto = ProdutoDiverso(
        nome: _nomeController.text,
        descricao: _descricaoController.text.isEmpty ? null : _descricaoController.text,
        categoria: _categoriaSelecionada ?? _categoriaController.text,
        preco: double.parse(_precoController.text),
        quantidadeEstoque: int.parse(_quantidadeController.text),
      );

      await _produtoDAO.insertProdutoDiverso(novoProduto);
      await _carregarDados();
      _limparFormulario();
      _mostrarSucesso('Produto adicionado com sucesso!');
    } catch (e) {
      _mostrarErro('Erro ao adicionar produto: $e');
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  void _limparFormulario() {
    _nomeController.clear();
    _descricaoController.clear();
    _categoriaController.clear();
    _precoController.clear();
    _quantidadeController.clear();
    _categoriaSelecionada = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos Diversos'),
        backgroundColor: Colors.amber.shade700,
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
                  // Informações sobre CRUD simples
                  _buildInfoCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Formulário para adicionar produto
                  _buildFormulario(),
                  
                  const SizedBox(height: 20),
                  
                  // Filtros e estatísticas
                  _buildFiltrosEstatisticas(),
                  
                  const SizedBox(height: 20),
                  
                  // Lista de produtos
                  _buildListaProdutos(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Text(
                  'Cadastro Simples (CRUD Básico)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Este módulo demonstra um CRUD básico sem relacionamentos entre entidades. '
              'Permite gerenciar produtos diversos como materiais médicos, equipamentos, '
              'produtos de higiene e outros itens não medicamentosos.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text('CREATE - Criar'),
                  backgroundColor: Colors.green.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.green),
                ),
                Chip(
                  label: Text('READ - Ler'),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.blue),
                ),
                Chip(
                  label: Text('UPDATE - Atualizar'),
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.orange),
                ),
                Chip(
                  label: Text('DELETE - Excluir'),
                  backgroundColor: Colors.red.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
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
                'Adicionar Novo Produto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, insira o nome' : null,
              ),
              
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Categoria Existente',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      value: _categoriaSelecionada,
                      items: _categorias.where((cat) => cat != 'Todas').map((cat) => 
                        DropdownMenuItem(value: cat, child: Text(cat))
                      ).toList()..add(
                        const DropdownMenuItem(value: null, child: Text('Nova categoria'))
                      ),
                      onChanged: (value) {
                        setState(() {
                          _categoriaSelecionada = value;
                          if (value != null) {
                            _categoriaController.clear();
                          }
                        });
                      },
                    ),
                  ),
                  
                  if (_categoriaSelecionada == null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _categoriaController,
                        decoration: const InputDecoration(
                          labelText: 'Nova Categoria *',
                          border: OutlineInputBorder(),
                        ),
                        validator: _categoriaSelecionada == null 
                          ? (value) => value!.isEmpty ? 'Digite a categoria' : null
                          : null,
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precoController,
                      decoration: const InputDecoration(
                        labelText: 'Preço (R\$) *',
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
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: TextFormField(
                      controller: _quantidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Digite a quantidade';
                        if (int.tryParse(value) == null) return 'Quantidade inválida';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAdding ? null : _adicionarProduto,
                  icon: _isAdding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: Text(_isAdding ? 'Adicionando...' : 'Adicionar Produto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
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

  Widget _buildFiltrosEstatisticas() {
    final produtosFiltrados = _aplicarFiltros();
    final valorTotal = produtosFiltrados.fold<double>(
      0.0, (sum, p) => sum + (p.preco * p.quantidadeEstoque)
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros e Estatísticas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 12),
            
            TextField(
              decoration: const InputDecoration(
                labelText: 'Filtrar por nome ou descrição',
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
            
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Filtrar por categoria',
                border: OutlineInputBorder(),
              ),
              value: _filtroCategoria,
              items: _categorias.map((cat) => 
                DropdownMenuItem(value: cat, child: Text(cat))
              ).toList(),
              onChanged: (value) {
                setState(() {
                  _filtroCategoria = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Produtos', '${produtosFiltrados.length}', Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Categorias', '${_categorias.length - 1}', Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Valor Total', 'R\$ ${valorTotal.toStringAsFixed(2)}', Colors.orange)),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListaProdutos() {
    final produtosFiltrados = _aplicarFiltros();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.inventory, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Produtos Cadastrados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${produtosFiltrados.length} item(ns)',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          
          if (produtosFiltrados.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Nenhum produto encontrado',
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
              itemCount: produtosFiltrados.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final produto = produtosFiltrados[index];
                return _buildProdutoItem(produto);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProdutoItem(ProdutoDiverso produto) {
    final valorTotal = produto.preco * produto.quantidadeEstoque;
    final estoqueStatus = produto.quantidadeEstoque <= 5 
        ? 'Crítico' 
        : produto.quantidadeEstoque <= 20 
            ? 'Baixo' 
            : 'Normal';
    
    final corEstoque = produto.quantidadeEstoque <= 5 
        ? Colors.red 
        : produto.quantidadeEstoque <= 20 
            ? Colors.orange 
            : Colors.green;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.amber.shade700,
        child: Text(
          produto.nome.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        produto.nome,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (produto.descricao != null)
            Text(produto.descricao!),
          Text('Categoria: ${produto.categoria ?? 'Sem categoria'}'),
          Text('Preço unitário: R\$ ${produto.preco.toStringAsFixed(2)}'),
          Text('Quantidade: ${produto.quantidadeEstoque}'),
          Text('Valor total: R\$ ${valorTotal.toStringAsFixed(2)}'),
          Row(
            children: [
              Text('Estoque: '),
              Text(
                estoqueStatus,
                style: TextStyle(
                  color: corEstoque,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _acaoProduto(value, produto),
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
            value: 'duplicar',
            child: Row(
              children: [
                Icon(Icons.copy, color: Colors.blue),
                SizedBox(width: 8),
                Text('Duplicar'),
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
        ],
      ),
      isThreeLine: true,
    );
  }

  List<ProdutoDiverso> _aplicarFiltros() {
    List<ProdutoDiverso> produtosFiltrados = _produtos;

    // Filtro por texto
    if (_filtroTexto.isNotEmpty) {
      produtosFiltrados = produtosFiltrados.where((p) {
        final nome = p.nome.toLowerCase();
        final descricao = p.descricao?.toLowerCase() ?? '';
        final filtro = _filtroTexto.toLowerCase();
        return nome.contains(filtro) || descricao.contains(filtro);
      }).toList();
    }

    // Filtro por categoria
    if (_filtroCategoria != 'Todas') {
      produtosFiltrados = produtosFiltrados.where((p) => 
        p.categoria == _filtroCategoria
      ).toList();
    }

    return produtosFiltrados;
  }

  Future<void> _acaoProduto(String acao, ProdutoDiverso produto) async {
    switch (acao) {
      case 'editar':
        _editarProduto(produto);
        break;
      case 'duplicar':
        _duplicarProduto(produto);
        break;
      case 'deletar':
        _confirmarDelecao(produto);
        break;
    }
  }

  void _editarProduto(ProdutoDiverso produto) {
    _nomeController.text = produto.nome;
    _descricaoController.text = produto.descricao ?? '';
    _precoController.text = produto.preco.toString();
    _quantidadeController.text = produto.quantidadeEstoque.toString();
    
    if (produto.categoria != null && _categorias.contains(produto.categoria)) {
      _categoriaSelecionada = produto.categoria;
      _categoriaController.clear();
    } else {
      _categoriaSelecionada = null;
      _categoriaController.text = produto.categoria ?? '';
    }
    
    // Scroll para o formulário
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
    );
    
    _mostrarMensagem('Dados carregados para edição');
  }

  void _duplicarProduto(ProdutoDiverso produto) {
    _nomeController.text = '${produto.nome} (Cópia)';
    _descricaoController.text = produto.descricao ?? '';
    _precoController.text = produto.preco.toString();
    _quantidadeController.text = '0'; // Zerar quantidade na cópia
    
    if (produto.categoria != null && _categorias.contains(produto.categoria)) {
      _categoriaSelecionada = produto.categoria;
      _categoriaController.clear();
    } else {
      _categoriaSelecionada = null;
      _categoriaController.text = produto.categoria ?? '';
    }
    
    _mostrarMensagem('Produto duplicado no formulário');
  }

  void _confirmarDelecao(ProdutoDiverso produto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o produto "${produto.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletarProduto(produto);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletarProduto(ProdutoDiverso produto) async {
    try {
      await _produtoDAO.deleteProdutoDiverso(produto.id!);
      await _carregarDados();
      _mostrarSucesso('Produto excluído com sucesso!');
    } catch (e) {
      _mostrarErro('Erro ao excluir produto: $e');
    }
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
