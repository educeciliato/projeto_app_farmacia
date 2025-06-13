// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/medicamento_provider.dart';
import 'telas/adicionar_medicamento.dart';
import 'telas/listar_medicamentos.dart';
import 'telas/remover_medicamentos.dart';
import 'telas/tela_inicial.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MedicamentoProvider(),
      child: const ControleEstoqueApp(),
    ),
  );
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
