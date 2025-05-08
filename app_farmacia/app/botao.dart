import 'package:flutter/material.dart';

class Botao extends StatelessWidget {
  final String rotulo;
  final Color cor;
  final VoidCallback aoPressionar;

  const Botao({
    super.key,
    required this.rotulo,
    required this.cor,
    required this.aoPressionar,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: cor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 18),
      ),
      onPressed: aoPressionar,
      child: Text(rotulo),
    );
  }
}
