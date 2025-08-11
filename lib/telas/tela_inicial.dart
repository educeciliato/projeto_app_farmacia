import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../serivces/notification_service.dart';
import '../widgets/botao.dart';
import '../provider/medicamento_provider.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  @override
  void initState() {
    super.initState();
    _verificarAlertas();
  }

  Future<void> _verificarAlertas() async {
    // Aguarda um pouco para a tela carregar
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final provider = Provider.of<MedicamentoProvider>(context, listen: false);

    // Verificar medicamentos vencidos
    final vencidos = provider.medicamentos
        .where((m) => m.dataValidade.isBefore(DateTime.now()))
        .toList();

    if (vencidos.isNotEmpty) {
      await NotificationService.notificarMedicamentosVencidos(vencidos);
    }

    // Verificar medicamentos próximos ao vencimento (30 dias)
    final proximosVencimento = provider.medicamentos.where((m) {
      final diff = m.dataValidade.difference(DateTime.now()).inDays;
      return diff > 0 && diff <= 30;
    }).toList();

    if (proximosVencimento.isNotEmpty) {
      await NotificationService.notificarMedicamentosProximosVencimento(
          proximosVencimento);
    }

    // Verificar estoque baixo
    final estoqueBaixo =
        provider.medicamentos.where((m) => m.quantidade <= 10).toList();

    if (estoqueBaixo.isNotEmpty) {
      await NotificationService.notificarEstoqueBaixo(estoqueBaixo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Sistema de Controle'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _mostrarAlertas,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'sobre') {
                _mostrarSobre();
              } else if (value == 'configuracoes') {
                _mostrarConfiguracoes();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'configuracoes',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Configurações'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sobre',
                child: Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 8),
                    Text('Sobre'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<MedicamentoProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Logo e título
                Hero(
                  tag: 'logo',
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.local_pharmacy,
                      size: 60,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Farmácia Inteligente',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Text(
                  'Sistema Completo de Gestão',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Cards com estatísticas principais
                _buildResumoCards(provider),

                const SizedBox(height: 30),

                // Alertas visuais
                _buildAlertas(provider),

                const SizedBox(height: 30),

                // Botões principais organizados em grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildMenuCard(
                      'Adicionar\nMedicamento',
                      Icons.add_box,
                      Colors.green,
                      () => Navigator.pushNamed(context, '/adicionar'),
                    ),
                    _buildMenuCard(
                      'Visualizar\nEstoque',
                      Icons.inventory_2,
                      Colors.blue,
                      () => Navigator.pushNamed(context, '/listar'),
                    ),
                    _buildMenuCard(
                      'Dashboard\nGráficos',
                      Icons.dashboard,
                      Colors.purple,
                      () => Navigator.pushNamed(context, '/dashboard'),
                    ),
                    _buildMenuCard(
                      'Relatórios\nDetalhados',
                      Icons.assessment,
                      Colors.indigo,
                      () => Navigator.pushNamed(context, '/relatorios'),
                    ),
                    _buildMenuCard(
                      'Farmácias\nPróximas',
                      Icons.location_on,
                      Colors.teal,
                      () => Navigator.pushNamed(context, '/farmacias'),
                    ),
                    _buildMenuCard(
                      'Sincronização\nDados',
                      Icons.sync,
                      Colors.orange,
                      () => Navigator.pushNamed(context, '/sincronizacao'),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Botões secundários
                Row(
                  children: [
                    Expanded(
                      child: Botao(
                        rotulo: 'Gerenciar Laboratórios',
                        cor: Colors.purple.shade600,
                        aoPressionar: () =>
                            Navigator.pushNamed(context, '/laboratorios'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Botao(
                        rotulo: 'Produtos Diversos',
                        cor: Colors.amber.shade700,
                        aoPressionar: () =>
                            Navigator.pushNamed(context, '/produtos'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Botao(
                        rotulo: 'Fornecedores',
                        cor: Colors.cyan.shade700,
                        aoPressionar: () =>
                            Navigator.pushNamed(context, '/fornecedores'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Rodapé com informações
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Icon(Icons.security,
                                    color: Colors.green.shade600),
                                const SizedBox(height: 4),
                                const Text('Seguro',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(Icons.cloud_done,
                                    color: Colors.blue.shade600),
                                const SizedBox(height: 4),
                                const Text('Sincronizado',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(Icons.phone_android,
                                    color: Colors.purple.shade600),
                                const SizedBox(height: 4),
                                const Text('Mobile',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Versão 1.0.0 - Sistema Completo de Farmácia',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResumoCards(MedicamentoProvider provider) {
    final vencidos = provider.medicamentos
        .where((m) => m.dataValidade.isBefore(DateTime.now()))
        .length;
    final proximosVencimento = provider.medicamentos.where((m) {
      final diff = m.dataValidade.difference(DateTime.now()).inDays;
      return diff > 0 && diff <= 30;
    }).length;
    final estoqueBaixo =
        provider.medicamentos.where((m) => m.quantidade <= 10).length;

    return Row(
      children: [
        Expanded(
            child: _buildStatCard('${provider.medicamentos.length}',
                'Medicamentos', Colors.blue, Icons.medication)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard('${provider.laboratorios.length}',
                'Laboratórios', Colors.green, Icons.science)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard(
                '${provider.medicamentos.where((m) => m.isMedicamentoControlado).length}',
                'Controlados',
                Colors.red,
                Icons.lock)),
      ],
    );
  }

  Widget _buildStatCard(
      String valor, String titulo, Color cor, IconData icone) {
    return Card(
      elevation: 8,
      shadowColor: cor.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [cor.withOpacity(0.1), cor.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(icone, color: cor, size: 32),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
            Text(
              titulo,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertas(MedicamentoProvider provider) {
    final vencidos = provider.medicamentos
        .where((m) => m.dataValidade.isBefore(DateTime.now()))
        .length;
    final proximosVencimento = provider.medicamentos.where((m) {
      final diff = m.dataValidade.difference(DateTime.now()).inDays;
      return diff > 0 && diff <= 30;
    }).length;
    final estoqueBaixo =
        provider.medicamentos.where((m) => m.quantidade <= 10).length;

    if (vencidos == 0 && proximosVencimento == 0 && estoqueBaixo == 0) {
      return Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Estoque em dia! Nenhum alerta no momento.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (vencidos > 0)
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$vencidos medicamento(s) vencido(s)',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/listar'),
                    child: const Text('Ver'),
                  ),
                ],
              ),
            ),
          ),
        if (proximosVencimento > 0)
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.orange.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$proximosVencimento medicamento(s) próximo(s) ao vencimento',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/listar'),
                    child: const Text('Ver'),
                  ),
                ],
              ),
            ),
          ),
        if (estoqueBaixo > 0)
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.inventory, color: Colors.amber.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$estoqueBaixo medicamento(s) com estoque baixo',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/listar'),
                    child: const Text('Ver'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMenuCard(
      String titulo, IconData icone, Color cor, VoidCallback onTap) {
    return Card(
      elevation: 8,
      shadowColor: cor.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [cor.withOpacity(0.1), cor.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 48, color: cor),
              const SizedBox(height: 12),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarAlertas() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.notifications),
              SizedBox(width: 8),
              Text('Alertas do Sistema'),
            ],
          ),
          content: const Text(
            'Notificações estão ativas para:\n'
            '• Medicamentos vencidos\n'
            '• Medicamentos próximos ao vencimento\n'
            '• Estoque baixo\n'
            '• Sincronização de dados',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarSobre() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info),
              SizedBox(width: 8),
              Text('Sobre o Sistema'),
            ],
          ),
          content: const Text(
            'Sistema Completo de Controle de Estoque para Farmácias\n\n'
            'Funcionalidades:\n'
            '• Gestão completa de medicamentos\n'
            '• Dashboard com gráficos\n'
            '• Relatórios personalizados\n'
            '• Sincronização com APIs\n'
            '• Localização de farmácias\n'
            '• Notificações inteligentes\n'
            '• Relacionamentos N:N\n\n'
            'Versão 1.0.0\n'
            'Desenvolvido com Flutter',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarConfiguracoes() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.settings),
              SizedBox(width: 8),
              Text('Configurações'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notificações'),
                subtitle: const Text('Gerenciar alertas do sistema'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Implementar tela de configurações de notificações
                },
              ),
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Sincronização'),
                subtitle: const Text('Configurar sync automático'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/sincronizacao');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
