import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/botao.dart';
import '../provider/medicamento_provider.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Controle de Estoque'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Consumer<MedicamentoProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                Icon(
                  Icons.local_pharmacy,
                  size: 80,
                  color: Colors.blue.shade700,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Sistema de Controle de Estoque',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Text(
                  'Farmácia',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Card com estatísticas
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Resumo do Estoque',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${provider.medicamentos.length}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Text('Medicamentos'),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${provider.laboratorios.length}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const Text('Laboratórios'),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${provider.medicamentos.where((m) => m.isMedicamentoControlado).length}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const Text('Controlados'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Botões principais
                Botao(
                  rotulo: 'Adicionar Medicamento',
                  cor: Colors.green,
                  aoPressionar: () =>
                      Navigator.pushNamed(context, '/adicionar'),
                ),

                const SizedBox(height: 20),

                Botao(
                  rotulo: 'Visualizar Estoque',
                  cor: Colors.blue,
                  aoPressionar: () => Navigator.pushNamed(context, '/listar'),
                ),

                const SizedBox(height: 20),

                Botao(
                  rotulo: 'Remover Medicamentos',
                  cor: Colors.red,
                  aoPressionar: () => Navigator.pushNamed(context, '/remover'),
                ),

                const SizedBox(height: 40),

                // Informações adicionais
                Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.amber,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Dicas Importantes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• Verifique sempre as datas de validade\n'
                          '• Medicamentos controlados requerem atenção especial\n'
                          '• Mantenha o estoque sempre atualizado',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.left,
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
}
