import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/medicamento_provider.dart';
import 'serivces/notification_service.dart';
import 'telas/adicionar_medicamento.dart';
import 'telas/listar_medicamentos.dart';
import 'telas/remover_medicamentos.dart';
import 'telas/tela_inicial.dart';
import 'telas/dashboard.dart';
import 'telas/relatorios.dart';
import 'telas/farmacias_proximas.dart';
import 'telas/gerenciar_laboratorios.dart';
import 'telas/sincronizacao.dart';
import 'telas/gerenciar_distribuidoras.dart';
import 'telas/fornecedores_medicamentos.dart';
import 'telas/produtos_diversos.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Suporte para SQLite FFI em ambientes desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Inicializar notificações
  await NotificationService.initialize();

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const TelaInicial(),
        '/adicionar': (context) => AdicionarMedicamento(),
        '/listar': (context) => const ListarMedicamentos(),
        '/remover': (context) => const RemoverMedicamentos(),
        '/dashboard': (context) => const Dashboard(),
        '/relatorios': (context) => const Relatorios(),
        '/farmacias': (context) => const FarmaciasProximas(),
        '/laboratorios': (context) => const GerenciarLaboratorios(),
        '/sincronizacao': (context) => const Sincronizacao(),
        '/distribuidoras': (context) => const GerenciarDistribuidoras(),
        '/fornecedores': (context) => const FornecedoresMedicamentos(),
        '/produtos': (context) => const ProdutosDiversos()
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Inicializa o banco de dados e carrega os dados
      final provider = Provider.of<MedicamentoProvider>(context, listen: false);
      await provider.initializeData();

      // Aguarda a animação terminar
      await Future.delayed(const Duration(seconds: 3));

      // Navega para a tela inicial após carregar os dados
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // Em caso de erro, ainda navega para a tela inicial
      debugPrint('Erro na inicialização: $e');
      if (mounted) {
        await Future.delayed(const Duration(seconds: 3));
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_pharmacy,
                        size: 80,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Controle de Estoque',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Text(
                      'Farmácia Inteligente',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.blue.shade100,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                      ),
                    ),
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
            ),
          );
        },
      ),
    );
  }
}
