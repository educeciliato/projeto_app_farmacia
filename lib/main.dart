import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:controle_estoque/provider/medicamento_provider.dart';
import 'package:controle_estoque/telas/adicionar_medicamento.dart';
import 'package:controle_estoque/telas/listar_medicamentos.dart';
import 'package:controle_estoque/telas/remover_medicamentos.dart';
import 'package:controle_estoque/telas/tela_inicial.dart';

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
      title: 'Controle de Estoque - Farmacia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const TelaInicial(),
        '/adicionar': (context) => AdicionarMedicamento(),
        '/listar': (context) => const ListarMedicamentos(),
        '/remover': (context) => const RemoverMedicamentos(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Aguarda um pouco para simular carregamento
      await Future.delayed(const Duration(seconds: 2));

      // Inicializa o provider
      if (mounted) {
        final provider =
            Provider.of<MedicamentoProvider>(context, listen: false);
        await provider.initializeData();
      }

      // Navega para a tela inicial
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      debugPrint('Erro na inicializacao: $e');
      // Em caso de erro, ainda navega para a tela inicial
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_pharmacy,
              size: 80,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 20),
            Text(
              'Controle de Estoque',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            Text(
              'Farmacia',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              'Carregando dados...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
