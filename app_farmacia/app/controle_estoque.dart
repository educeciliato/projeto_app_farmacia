import 'package:flutter/material.dart';
import 'tela_inicial.dart';
import 'adicionar_medicamento.dart';
import 'listar_medicamentos.dart';

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
      },
    );
  }
}
