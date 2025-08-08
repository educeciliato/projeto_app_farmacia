import 'package:flutter/material.dart';
import '../dao/distribuidora_dao.dart';
import '../model/distribuidora.dart';
import '../serivces/url_launcher_service.dart';

class GerenciarDistribuidoras extends StatefulWidget {
  const GerenciarDistribuidoras({super.key});

  @override
  State<GerenciarDistribuidoras> createState() =>
      _GerenciarDistribuidorasState();
}

class _GerenciarDistribuidorasState extends State<GerenciarDistribuidoras> {
  final DistribuidoraDAO _distribuidoraDAO = DistribuidoraDAO();
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();

  List<Distribuidora> _distribuidoras = [];
  bool _isLoading = false;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _carregarDistribuidoras();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _enderecoController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _carregarDistribuidoras() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final distribuidoras = await _distribuidoraDAO.getAllDistribuidoras();
      setState(() {
        _distribuidoras = distribuidoras;
      });
    } catch (e) {
      _mostrarErro('Erro ao carregar distribuidoras: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _adicionarDistribuidora() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isAdding = true;
    });

    try {
      final novaDistribuidora = Distribuidora(
        nome: _nomeController.text,
        cnpj: _cnpjController.text.isEmpty ? null : _cnpjController.text,
        endereco:
            _enderecoController.text.isEmpty ? null : _enderecoController.text,
        telefone:
            _telefoneController.text.isEmpty ? null : _telefoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
      );

      await _distribuidoraDAO.insertDistribuidora(novaDistribuidora);
      await _carregarDistribuidoras();
      _limparFormulario();
      _mostrarSucesso('Distribuidora adicionada com sucesso!');
    } catch (e) {
      _mostrarErro('Erro ao adicionar distribuidora: $e');
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  void _limparFormulario() {
    _nomeController.clear();
    _cnpjController.clear();
    _enderecoController.clear();
    _telefoneController.clear();
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Distribuidoras'),
        backgroundColor: Colors.cyan.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDistribuidoras,
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
                  // Formulário para adicionar distribuidora
                  _buildFormulario(),

                  const SizedBox(height: 24),

                  // Lista de distribuidoras
                  _buildListaDistribuidoras(),
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
                'Adicionar Nova Distribuidora',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Distribuidora *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, insira o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cnpjController,
                decoration: const InputDecoration(
                  labelText: 'CNPJ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                  hintText: 'XX.XXX.XXX/0001-XX',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: '(XX) XXXXX-XXXX',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAdding ? null : _adicionarDistribuidora,
                  icon: _isAdding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: Text(
                      _isAdding ? 'Adicionando...' : 'Adicionar Distribuidora'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan.shade700,
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

  Widget _buildListaDistribuidoras() {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.list, color: Colors.cyan),
                const SizedBox(width: 8),
                const Text(
                  'Distribuidoras Cadastradas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_distribuidoras.length} item(ns)',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          if (_distribuidoras.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.business, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Nenhuma distribuidora cadastrada',
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
              itemCount: _distribuidoras.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final distribuidora = _distribuidoras[index];
                return _buildDistribuidoraItem(distribuidora);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDistribuidoraItem(Distribuidora distribuidora) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.cyan.shade700,
        child: Text(
          distribuidora.nome.substring(0, 1).toUpperCase(),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        distribuidora.nome,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (distribuidora.cnpj != null) Text('CNPJ: ${distribuidora.cnpj}'),
          if (distribuidora.endereco != null)
            Text('📍 ${distribuidora.endereco}'),
          if (distribuidora.telefone != null)
            Text('📞 ${distribuidora.telefone}'),
          if (distribuidora.email != null) Text('📧 ${distribuidora.email}'),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _acaoDistribuidora(value, distribuidora),
        itemBuilder: (context) => [
          if (distribuidora.telefone != null)
            const PopupMenuItem(
              value: 'ligar',
              child: Row(
                children: [
                  Icon(Icons.phone, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Ligar'),
                ],
              ),
            ),
          if (distribuidora.email != null)
            const PopupMenuItem(
              value: 'email',
              child: Row(
                children: [
                  Icon(Icons.email, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Enviar E-mail'),
                ],
              ),
            ),
          if (distribuidora.telefone != null)
            const PopupMenuItem(
              value: 'whatsapp',
              child: Row(
                children: [
                  Icon(Icons.message, color: Colors.green),
                  SizedBox(width: 8),
                  Text('WhatsApp'),
                ],
              ),
            ),
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
        ],
      ),
      isThreeLine: true,
    );
  }

  Future<void> _acaoDistribuidora(
      String acao, Distribuidora distribuidora) async {
    try {
      switch (acao) {
        case 'ligar':
          if (distribuidora.telefone != null) {
            await UrlLauncherService.fazerLigacao(distribuidora.telefone!);
          }
          break;

        case 'email':
          if (distribuidora.email != null) {
            await UrlLauncherService.enviarEmail(
              distribuidora.email!,
              assunto: 'Contato - ${distribuidora.nome}',
            );
          }
          break;

        case 'whatsapp':
          if (distribuidora.telefone != null) {
            await UrlLauncherService.abrirWhatsApp(
              distribuidora.telefone!,
              'Olá ${distribuidora.nome}! Entrando em contato através do sistema de farmácia.',
            );
          }
          break;

        case 'editar':
          _editarDistribuidora(distribuidora);
          break;

        case 'deletar':
          _confirmarDelecao(distribuidora);
          break;
      }
    } catch (e) {
      _mostrarErro('Erro: $e');
    }
  }

  void _editarDistribuidora(Distribuidora distribuidora) {
    _nomeController.text = distribuidora.nome;
    _cnpjController.text = distribuidora.cnpj ?? '';
    _enderecoController.text = distribuidora.endereco ?? '';
    _telefoneController.text = distribuidora.telefone ?? '';
    _emailController.text = distribuidora.email ?? '';

    // Scroll para o formulário
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    _mostrarMensagem('Dados carregados no formulário para edição');
  }

  void _confirmarDelecao(Distribuidora distribuidora) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
            'Deseja realmente excluir a distribuidora "${distribuidora.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletarDistribuidora(distribuidora);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletarDistribuidora(Distribuidora distribuidora) async {
    try {
      await _distribuidoraDAO.deleteDistribuidora(distribuidora.id!);
      await _carregarDistribuidoras();
      _mostrarSucesso('Distribuidora excluída com sucesso!');
    } catch (e) {
      _mostrarErro('Erro ao excluir distribuidora: $e');
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
