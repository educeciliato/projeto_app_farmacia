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
      title: 'Controle de Estoque - Farmácia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
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
      // Inicializa o banco de dados e carrega os dados
      final provider = Provider.of<MedicamentoProvider>(context, listen: false);
      await provider.initializeData();

      // Navega para a tela inicial após carregar os dados
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // Em caso de erro, ainda navega para a tela inicial
      debugPrint('Erro na inicialização: $e');
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
              'Farmácia',
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
