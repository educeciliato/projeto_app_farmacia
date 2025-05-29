import 'package:flutter/material.dart';
import 'tela_inicial.dart';
import 'adicionar_medicamento.dart';
import 'listar_medicamentos.dart';
import 'remover_medicamentos.dart';

void main() {
  runApp(const ControleEstoqueApp());
}

class ControleEstoqueApp extends StatelessWidget {
  const ControleEstoqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle de Estoque',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TelaInicial(),
        '/adicionar': (context) => AdicionarMedicamento(),
        '/listar': (context) => const ListarMedicamentos(),
        '/remover': (context) => const RemoverMedicamentos(),
      },
    );
  }
}

List<Map<String, String>> medicamentos = [
  {
    'nome': 'Paracetamol',
    'dose': '500mg',
    'tipo': 'Comprimido',
    'descricao': 'Analgésico e antitérmico',
    'laboratorio': 'EMS',
    'Data de Fabricacao': '2025/04/22',
    'Data de Validade': '2027/05/07',
    'lote': 'PAR001',
    'quantidade': '150',
  },
  {
    'nome': 'Citrato de Sidenafila',
    'dose': '50mg',
    'tipo': 'Comprimido',
    'descricao': 'Estimulante ( ͡° ͜ʖ ͡°)',
    'laboratorio': 'Medley',
    'Data de Fabricacao': '2025/04/22',
    'Data de Validade': '2027/05/07',
    'lote': 'IBU002',
    'quantidade': '85',
  },
  {
    'nome': 'Dipirona',
    'dose': '500mg',
    'tipo': 'Comprimido',
    'descricao': 'Analgésico e antitérmico',
    'laboratorio': 'Sanofi',
    'Data de Fabricacao': '2025/04/22',
    'Data de Validade': '2027/05/07',
    'lote': 'DIP007',
    'quantidade': '175',
  },
];
