import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/medicamento_provider.dart';
import '../model/medicamento.dart';
import '../serivces/url_launcher_service.dart';

class Relatorios extends StatefulWidget {
  const Relatorios({super.key});

  @override
  State<Relatorios> createState() => _RelatoriosState();
}

class _RelatoriosState extends State<Relatorios> {
  String _tipoRelatorio = 'geral';
  String? _laboratorioSelecionado;
  DateTime? _dataInicio;
  DateTime? _dataFim;
  bool _apenasControlados = false;
  bool _apenasVencidos = false;
  bool _apenasEstoqueBaixo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _compartilharRelatorio,
          ),
          IconButton(
            icon: const Icon(Icons.email),
            onPressed: _enviarPorEmail,
          ),
        ],
      ),
      body: Consumer<MedicamentoProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Filtros
              _buildFiltros(provider),

              // Conteúdo do relatório
              Expanded(
                child: _buildConteudoRelatorio(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFiltros(MedicamentoProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros do Relatório',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Tipo de relatório
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Tipo de Relatório',
                border: OutlineInputBorder(),
              ),
              value: _tipoRelatorio,
              items: const [
                DropdownMenuItem(
                    value: 'geral', child: Text('Relatório Geral')),
                DropdownMenuItem(
                    value: 'estoque', child: Text('Relatório de Estoque')),
                DropdownMenuItem(
                    value: 'vencimentos',
                    child: Text('Relatório de Vencimentos')),
                DropdownMenuItem(
                    value: 'controlados',
                    child: Text('Medicamentos Controlados')),
                DropdownMenuItem(
                    value: 'laboratorio', child: Text('Por Laboratório')),
              ],
              onChanged: (value) {
                setState(() {
                  _tipoRelatorio = value!;
                });
              },
            ),

            const SizedBox(height: 12),

            // Laboratório
            if (_tipoRelatorio == 'laboratorio')
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Laboratório',
                  border: OutlineInputBorder(),
                ),
                value: _laboratorioSelecionado,
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Todos os laboratórios')),
                  ...provider.laboratorios.map((lab) =>
                      DropdownMenuItem(value: lab.nome, child: Text(lab.nome))),
                ],
                onChanged: (value) {
                  setState(() {
                    _laboratorioSelecionado = value;
                  });
                },
              ),

            const SizedBox(height: 12),

            // Período
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Data Início',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selecionarData(context, true),
                      ),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: _dataInicio != null
                          ? DateFormat('dd/MM/yyyy').format(_dataInicio!)
                          : '',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Data Fim',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selecionarData(context, false),
                      ),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: _dataFim != null
                          ? DateFormat('dd/MM/yyyy').format(_dataFim!)
                          : '',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Filtros adicionais
            Wrap(
              children: [
                FilterChip(
                  label: const Text('Apenas Controlados'),
                  selected: _apenasControlados,
                  onSelected: (value) {
                    setState(() {
                      _apenasControlados = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Apenas Vencidos'),
                  selected: _apenasVencidos,
                  onSelected: (value) {
                    setState(() {
                      _apenasVencidos = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Estoque Baixo'),
                  selected: _apenasEstoqueBaixo,
                  onSelected: (value) {
                    setState(() {
                      _apenasEstoqueBaixo = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudoRelatorio(MedicamentoProvider provider) {
    List<Medicamento> medicamentosFiltrados =
        _aplicarFiltros(provider.medicamentos);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Cabeçalho do relatório
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTituloRelatorio(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gerado em: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  'Total de itens: ${medicamentosFiltrados.length}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Resumo estatístico
          if (_tipoRelatorio == 'geral')
            _buildResumoEstatistico(medicamentosFiltrados),

          // Lista de medicamentos
          Expanded(
            child: medicamentosFiltrados.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum medicamento encontrado com os filtros aplicados',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: medicamentosFiltrados.length,
                    itemBuilder: (context, index) {
                      final medicamento = medicamentosFiltrados[index];
                      return _buildItemRelatorio(medicamento);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoEstatistico(List<Medicamento> medicamentos) {
    final vencidos = medicamentos
        .where((m) => m.dataValidade.isBefore(DateTime.now()))
        .length;
    final controlados =
        medicamentos.where((m) => m.isMedicamentoControlado).length;
    final estoqueBaixo = medicamentos.where((m) => m.quantidade <= 10).length;
    final quantidadeTotal =
        medicamentos.fold<int>(0, (sum, m) => sum + m.quantidade);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo Estatístico',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildEstatistica('Medicamentos Únicos',
                      '${medicamentos.length}', Colors.blue)),
              Expanded(
                  child: _buildEstatistica(
                      'Quantidade Total', '$quantidadeTotal', Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child:
                      _buildEstatistica('Vencidos', '$vencidos', Colors.red)),
              Expanded(
                  child: _buildEstatistica(
                      'Controlados', '$controlados', Colors.orange)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _buildEstatistica(
                      'Estoque Baixo', '$estoqueBaixo', Colors.amber)),
              Expanded(
                  child: _buildEstatistica('Laboratórios',
                      '${_contarLaboratorios(medicamentos)}', Colors.purple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstatistica(String titulo, String valor, Color cor) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: TextStyle(
              fontSize: 18,
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
    );
  }

  Widget _buildItemRelatorio(Medicamento medicamento) {
    final isVencido = medicamento.dataValidade.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color:
                medicamento.isMedicamentoControlado ? Colors.red : Colors.blue,
            width: 4,
          ),
        ),
        color: isVencido ? Colors.red.withOpacity(0.1) : null,
      ),
      child: ListTile(
        title: Text(
          '${medicamento.nome} ${medicamento.doseMg.toStringAsFixed(0)}mg',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${medicamento.tipo} | Lab: ${medicamento.laboratorio}'),
            Text('Lote: ${medicamento.lote} | Qtd: ${medicamento.quantidade}'),
            Text(
              'Fabricação: ${DateFormat('dd/MM/yyyy').format(medicamento.dataFabricacao)} | '
              'Validade: ${DateFormat('dd/MM/yyyy').format(medicamento.dataValidade)}',
              style: TextStyle(
                color: isVencido ? Colors.red : null,
                fontWeight: isVencido ? FontWeight.bold : null,
              ),
            ),
            if (medicamento.isMedicamentoControlado)
              const Text(
                'MEDICAMENTO CONTROLADO',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isVencido)
              const Icon(Icons.warning, color: Colors.red, size: 20),
            if (medicamento.quantidade <= 10)
              const Icon(Icons.inventory, color: Colors.orange, size: 20),
          ],
        ),
      ),
    );
  }

  List<Medicamento> _aplicarFiltros(List<Medicamento> medicamentos) {
    List<Medicamento> filtrados = List.from(medicamentos);

    // Filtro por laboratório
    if (_laboratorioSelecionado != null) {
      filtrados = filtrados
          .where((m) => m.laboratorio == _laboratorioSelecionado)
          .toList();
    }

    // Filtro por período
    if (_dataInicio != null) {
      filtrados = filtrados
          .where((m) =>
              m.dataFabricacao.isAfter(_dataInicio!) ||
              m.dataFabricacao.isAtSameMomentAs(_dataInicio!))
          .toList();
    }

    if (_dataFim != null) {
      filtrados = filtrados
          .where((m) =>
              m.dataValidade.isBefore(_dataFim!) ||
              m.dataValidade.isAtSameMomentAs(_dataFim!))
          .toList();
    }

    // Filtros adicionais
    if (_apenasControlados) {
      filtrados = filtrados.where((m) => m.isMedicamentoControlado).toList();
    }

    if (_apenasVencidos) {
      filtrados = filtrados
          .where((m) => m.dataValidade.isBefore(DateTime.now()))
          .toList();
    }

    if (_apenasEstoqueBaixo) {
      filtrados = filtrados.where((m) => m.quantidade <= 10).toList();
    }

    return filtrados;
  }

  String _getTituloRelatorio() {
    switch (_tipoRelatorio) {
      case 'estoque':
        return 'Relatório de Estoque';
      case 'vencimentos':
        return 'Relatório de Vencimentos';
      case 'controlados':
        return 'Relatório de Medicamentos Controlados';
      case 'laboratorio':
        return 'Relatório por Laboratório';
      default:
        return 'Relatório Geral de Medicamentos';
    }
  }

  int _contarLaboratorios(List<Medicamento> medicamentos) {
    return medicamentos.map((m) => m.laboratorio).toSet().length;
  }

  Future<void> _selecionarData(BuildContext context, bool isDataInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isDataInicio) {
          _dataInicio = picked;
        } else {
          _dataFim = picked;
        }
      });
    }
  }

  Future<void> _compartilharRelatorio() async {
    final relatorio = _gerarTextoRelatorio();
    await UrlLauncherService.compartilhar(relatorio);
  }

  Future<void> _enviarPorEmail() async {
    final relatorio = _gerarTextoRelatorio();
    await UrlLauncherService.enviarEmail(
      'destinatario@email.com',
      assunto:
          'Relatório de Medicamentos - ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
      corpo: relatorio,
    );
  }

  String _gerarTextoRelatorio() {
    final provider = Provider.of<MedicamentoProvider>(context, listen: false);
    final medicamentos = _aplicarFiltros(provider.medicamentos);

    StringBuffer relatorio = StringBuffer();
    relatorio.writeln('RELATÓRIO DE MEDICAMENTOS');
    relatorio.writeln('=' * 40);
    relatorio.writeln('Tipo: ${_getTituloRelatorio()}');
    relatorio.writeln(
        'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    relatorio.writeln('Total de itens: ${medicamentos.length}');
    relatorio.writeln('');

    if (_tipoRelatorio == 'geral') {
      final vencidos = medicamentos
          .where((m) => m.dataValidade.isBefore(DateTime.now()))
          .length;
      final controlados =
          medicamentos.where((m) => m.isMedicamentoControlado).length;
      final estoqueBaixo = medicamentos.where((m) => m.quantidade <= 10).length;

      relatorio.writeln('RESUMO ESTATÍSTICO:');
      relatorio.writeln('- Medicamentos vencidos: $vencidos');
      relatorio.writeln('- Medicamentos controlados: $controlados');
      relatorio.writeln('- Medicamentos com estoque baixo: $estoqueBaixo');
      relatorio.writeln('');
    }

    relatorio.writeln('DETALHAMENTO:');
    relatorio.writeln('-' * 40);

    for (var medicamento in medicamentos) {
      relatorio.writeln('Nome: ${medicamento.nome} ${medicamento.doseMg}mg');
      relatorio.writeln('Tipo: ${medicamento.tipo}');
      relatorio.writeln('Laboratório: ${medicamento.laboratorio}');
      relatorio.writeln('Lote: ${medicamento.lote}');
      relatorio.writeln('Quantidade: ${medicamento.quantidade}');
      relatorio.writeln(
          'Fabricação: ${DateFormat('dd/MM/yyyy').format(medicamento.dataFabricacao)}');
      relatorio.writeln(
          'Validade: ${DateFormat('dd/MM/yyyy').format(medicamento.dataValidade)}');
      if (medicamento.isMedicamentoControlado) {
        relatorio.writeln('*** MEDICAMENTO CONTROLADO ***');
      }
      relatorio.writeln('');
    }

    return relatorio.toString();
  }
}
