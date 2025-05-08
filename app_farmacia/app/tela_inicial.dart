import 'package:flutter/material.dart';
import 'botao.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Controle de Estoque',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Botao(
              rotulo: 'Adicionar Produto',
              cor: Colors.green,
              aoPressionar: () => Navigator.pushNamed(context, '/adicionar'),
            ),
            const SizedBox(height: 20),
            Botao(
              rotulo: 'Exibir Estoque',
              cor: Colors.blue,
              aoPressionar: () => Navigator.pushNamed(context, '/listar'),
            ),
          ],
        ),
      ),
    );
  }
}
