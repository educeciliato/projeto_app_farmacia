import 'package:flutter/material.dart';
import 'botao.dart';

class TelaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Controle de Estoque'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BotaoPersonalizado(
              rotulo: 'Adicionar Produto',
              cor: Colors.green,
              aoPressionar: () {
                Navigator.pushNamed(context, '/adicionar');
              },
            ),
            SizedBox(height: 20),
            BotaoPersonalizado(
              rotulo: 'Exibir Estoque',
              cor: Colors.blue,
              aoPressionar: () {
                Navigator.pushNamed(context, '/listar');
              },
            ),
          ],
        ),
      ),
    );
  }
}
