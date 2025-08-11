import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../provider/medicamento_provider.dart';
import '../model/medicamento.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedPeriod = 30; // dias

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 7, child: Text('Últimos 7 dias')),
              const PopupMenuItem(value: 30, child: Text('Últimos 30 dias')),
              const PopupMenuItem(value: 90, child: Text('Últimos 90 dias')),
              const PopupMenuItem(value: 365, child: Text('Último ano')),
            ],
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Consumer<MedicamentoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cards de resumo
                _buildResumoCards(provider),

                const SizedBox(height: 24),

                // Gráfico de medicamentos por laboratório
                _buildGraficoLaboratorios(provider),

                const SizedBox(height: 24),

                // Gráfico de vencimentos
                _buildGraficoVencimentos(provider),

                const SizedBox(height: 24),

                // Gráfico de estoque
                _buildGraficoEstoque(provider),

                const SizedBox(height: 24),

                // Gráfico de medicamentos controlados
                _buildGraficoControlados(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResumoCards(MedicamentoProvider provider) {
    final medicamentos = provider.medicamentos;
    final vencidos = medicamentos
        .where((m) => m.dataValidade.isBefore(DateTime.now()))
        .length;
    final proximosVencimento = medicamentos.where((m) {
      final diff = m.dataValidade.difference(DateTime.now()).inDays;
      return diff > 0 && diff <= 30;
    }).length;
    final estoqueBaixo = medicamentos.where((m) => m.quantidade <= 10).length;
    final controlados =
        medicamentos.where((m) => m.isMedicamentoControlado).length;

    return Row(
      children: [
        Expanded(
            child: _buildCard('Total', '${medicamentos.length}', Colors.blue,
                Icons.medication)),
        const SizedBox(width: 8),
        Expanded(
            child:
                _buildCard('Vencidos', '$vencidos', Colors.red, Icons.warning)),
        const SizedBox(width: 8),
        Expanded(
            child: _buildCard('Próx. Venc.', '$proximosVencimento',
                Colors.orange, Icons.schedule)),
        const SizedBox(width: 8),
        Expanded(
            child: _buildCard(
                'Est. Baixo', '$estoqueBaixo', Colors.amber, Icons.inventory)),
      ],
    );
  }

  Widget _buildCard(String titulo, String valor, Color cor, IconData icone) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icone, color: cor, size: 24),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(
                fontSize: 20,
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

  Widget _buildGraficoLaboratorios(MedicamentoProvider provider) {
    Map<String, int> dados = {};
    for (var medicamento in provider.medicamentos) {
      dados[medicamento.laboratorio] =
          (dados[medicamento.laboratorio] ?? 0) + 1;
    }

    List<PieChartSectionData> sections = [];
    List<Color> cores = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple
    ];
    int index = 0;

    dados.forEach((laboratorio, quantidade) {
      sections.add(
        PieChartSectionData(
          color: cores[index % cores.length],
          value: quantidade.toDouble(),
          title: '$quantidade',
          titleStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          radius: 60,
        ),
      );
      index++;
    });

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medicamentos por Laboratório',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: sections.isEmpty
                  ? const Center(child: Text('Nenhum dado disponível'))
                  : Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: PieChart(
                            PieChartData(
                              sections: sections,
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: dados.entries.map((e) {
                              int idx = dados.keys.toList().indexOf(e.key);
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      color: cores[idx % cores.length],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        e.key,
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoVencimentos(MedicamentoProvider provider) {
    final agora = DateTime.now();
    Map<String, int> dados = {
      'Vencidos': 0,
      '0-30 dias': 0,
      '31-90 dias': 0,
      '91-180 dias': 0,
      '> 180 dias': 0,
    };

    for (var medicamento in provider.medicamentos) {
      final diff = medicamento.dataValidade.difference(agora).inDays;
      if (diff < 0) {
        dados['Vencidos'] = dados['Vencidos']! + 1;
      } else if (diff <= 30) {
        dados['0-30 dias'] = dados['0-30 dias']! + 1;
      } else if (diff <= 90) {
        dados['31-90 dias'] = dados['31-90 dias']! + 1;
      } else if (diff <= 180) {
        dados['91-180 dias'] = dados['91-180 dias']! + 1;
      } else {
        dados['> 180 dias'] = dados['> 180 dias']! + 1;
      }
    }

    List<BarChartGroupData> barGroups = [];
    List<Color> cores = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.lightGreen,
      Colors.green
    ];
    int index = 0;

    dados.forEach((periodo, quantidade) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: quantidade.toDouble(),
              color: cores[index],
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      index++;
    });

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medicamentos por Período de Vencimento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          List<String> titles = dados.keys.toList();
                          if (value.toInt() < titles.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                titles[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoEstoque(MedicamentoProvider provider) {
    Map<String, int> dados = {
      'Crítico (0-5)': 0,
      'Baixo (6-10)': 0,
      'Normal (11-50)': 0,
      'Alto (>50)': 0,
    };

    for (var medicamento in provider.medicamentos) {
      if (medicamento.quantidade <= 5) {
        dados['Crítico (0-5)'] = dados['Crítico (0-5)']! + 1;
      } else if (medicamento.quantidade <= 10) {
        dados['Baixo (6-10)'] = dados['Baixo (6-10)']! + 1;
      } else if (medicamento.quantidade <= 50) {
        dados['Normal (11-50)'] = dados['Normal (11-50)']! + 1;
      } else {
        dados['Alto (>50)'] = dados['Alto (>50)']! + 1;
      }
    }

    List<FlSpot> spots = [];
    List<Color> cores = [Colors.red, Colors.orange, Colors.blue, Colors.green];
    int index = 0;

    dados.forEach((nivel, quantidade) {
      spots.add(FlSpot(index.toDouble(), quantidade.toDouble()));
      index++;
    });

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribuição de Estoque',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          List<String> titles = dados.keys.toList();
                          if (value.toInt() < titles.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                titles[value.toInt()].split(' ')[0],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                          show: true, color: Colors.blue.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoControlados(MedicamentoProvider provider) {
    final controlados =
        provider.medicamentos.where((m) => m.isMedicamentoControlado).length;
    final naoControlados = provider.medicamentos.length - controlados;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medicamentos Controlados vs Não Controlados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.red,
                      value: controlados.toDouble(),
                      title: 'Controlados\n$controlados',
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      radius: 60,
                    ),
                    PieChartSectionData(
                      color: Colors.green,
                      value: naoControlados.toDouble(),
                      title: 'Não Controlados\n$naoControlados',
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      radius: 60,
                    ),
                  ],
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
