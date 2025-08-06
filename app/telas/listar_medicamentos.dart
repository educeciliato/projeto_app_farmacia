import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/medicamento_provider.dart';
import '../widgets/botao.dart';

class ListarMedicamentos extends StatefulWidget {
  const ListarMedicamentos({super.key});

  @override
  State<ListarMedicamentos> createState() => _ListarMedicamentosState();
}

class _ListarMedicamentosState extends State<ListarMedicamentos> {
  String _filtroTexto = '';
  bool _mostrarApenasControlados = false;
  bool _mostrarApenasVencidos = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Medicamentos'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<MedicamentoProvider>(context, listen: false)
                  .initializeData();
            },
          ),
        ],
      ),
      body: Consumer<MedicamentoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final medicamentosFiltrados =
              provider.medicamentos.where((medicamento) {
            bool passaFiltroTexto = medicamento.nome
                    .toLowerCase()
                    .contains(_filtroTexto.toLowerCase()) ||
                medicamento.laboratorio
                    .toLowerCase()
                    .contains(_filtroTexto.toLowerCase());

            bool passaFiltroControlado = !_mostrarApenasControlados ||
                medicamento.isMedicamentoControlado;

            bool passaFiltroVencido = !_mostrarApenasVencidos ||
                medicamento.dataValidade.isBefore(DateTime.now());

            return passaFiltroTexto &&
                passaFiltroControlado &&
                passaFiltroVencido;
          }).toList();

          return Column(
            children: [
              // Filtros
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey.shade100,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Pesquisar medicamento ou laboratório',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
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
                          child: CheckboxListTile(
                            title: const Text('Apenas Controlados'),
                            value: _mostrarApenasControlados,
                            onChanged: (bool? value) {
                              setState(() {
                                _mostrarApenasControlados = value ?? false;
                              });
                            },
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Apenas Vencidos'),
                            value: _mostrarApenasVencidos,
                            onChanged: (bool? value) {
                              setState(() {
                                _mostrarApenasVencidos = value ?? false;
                              });
                            },
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Botão remover
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Botao(
                        rotulo: 'Remover Medicamentos',
                        cor: Colors.red,
                        aoPressionar: () =>
                            Navigator.pushNamed(context, '/remover'),
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de medicamentos
              Expanded(
                child: medicamentosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medication_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _filtroTexto.isNotEmpty ||
                                      _mostrarApenasControlados ||
                                      _mostrarApenasVencidos
                                  ? 'Nenhum medicamento encontrado com os filtros aplicados'
                                  : 'Nenhum medicamento no estoque',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: medicamentosFiltrados.length,
                        itemBuilder: (context, indice) {
                          final medicamento = medicamentosFiltrados[indice];
                          final isVencido =
                              medicamento.dataValidade.isBefore(DateTime.now());
                          final isProximoVencimento = medicamento.dataValidade
                              .isBefore(
                                  DateTime.now().add(const Duration(days: 30)));

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 4.0),
                            elevation: 2,
                            color: isVencido
                                ? Colors.red.shade50
                                : isProximoVencimento
                                    ? Colors.orange.shade50
                                    : null,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    medicamento.isMedicamentoControlado
                                        ? Colors.red
                                        : Colors.blue,
                                child: Icon(
                                  medicamento.isMedicamentoControlado
                                      ? Icons.lock
                                      : Icons.medication,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                '${medicamento.nome} ${medicamento.doseMg.toStringAsFixed(0)}mg',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${medicamento.tipo} - ${medicamento.descricao}'),
                                  Text(
                                      'Laboratório: ${medicamento.laboratorio}'),
                                  Text(
                                      'Fabricação: ${DateFormat('dd/MM/yyyy').format(medicamento.dataFabricacao)}'),
                                  Row(
                                    children: [
                                      Text(
                                          'Validade: ${DateFormat('dd/MM/yyyy').format(medicamento.dataValidade)}'),
                                      if (isVencido)
                                        const Text(
                                          ' (VENCIDO)',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      else if (isProximoVencimento)
                                        const Text(
                                          ' (Próximo ao venc.)',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                  Text(
                                      'Quantidade: ${medicamento.quantidade} - Lote: ${medicamento.lote}'),
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
                              isThreeLine: true,
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (medicamento.quantidade <= 10)
                                    const Icon(
                                      Icons.warning,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                  Text(
                                    'Qtd: ${medicamento.quantidade}',
                                    style: TextStyle(
                                      color: medicamento.quantidade <= 10
                                          ? Colors.orange
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Resumo no rodapé
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${medicamentosFiltrados.length}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Text('Total'),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${medicamentosFiltrados.where((m) => m.isMedicamentoControlado).length}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const Text('Controlados'),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${medicamentosFiltrados.where((m) => m.dataValidade.isBefore(DateTime.now())).length}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const Text('Vencidos'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
