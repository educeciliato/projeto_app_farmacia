import 'package:flutter/material.dart';

class Botao extends StatefulWidget {
  final String rotulo;
  final Color cor;
  final VoidCallback aoPressionar;

  Botao({
    required this.rotulo,
    required this.cor,
    required this.aoPressionar,
  });

  @override
  _EstadoBotao createState() => _EstadoBotao();
}

class _EstadoBotao extends State<Botao> {
  late Color _corAtual;

  @override
  void initState() {
    super.initState();
    _corAtual = widget.cor;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _corAtual = widget.cor.withOpacity(0.8);
        });
      },
      onExit: (_) {
        setState(() {
          _corAtual = widget.cor;
        });
      },
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(_corAtual),
          padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18)),
        ),
        onPressed: widget.aoPressionar,
        child: Text(widget.rotulo),
      ),
    );
  }
}
