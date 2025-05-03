import 'package:flutter/material.dart';
import 'tela_inicial.dart';
import 'adicionar_medicamentos.dart';
import 'listar_medicamentos.dart';

void main() {
  runApp(ControleEstoque());
}

class ControleEstoque extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Estoque',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => TelaInicial(),
        '/adicionar': (context) => TelaAdicionarMedicamento(),
        '/listar': (context) => TelaListarMedicamentos(),
      },
    );
  }
}
