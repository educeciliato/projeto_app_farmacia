import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../model/medicamento.dart';
import '../model/laboratorio.dart';

class ApiService {
  static const String baseUrl =
      'https://jsonplaceholder.typicode.com'; // API de exemplo
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  // Simulação de busca de medicamentos em API externa
  Future<List<Map<String, dynamic>>> buscarMedicamentosExternos() async {
    try {
      final response =
          await _dio.get('/posts'); // Simula endpoint de medicamentos

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // Converte dados da API em formato de medicamentos
        return data.take(10).map((item) {
          final id = item['id'] as int;
          final userId = item['userId'] as int;
          final title = item['title'] as String? ?? '';
          final body = item['body'] as String? ?? '';

          return {
            'id': 'API_$id',
            'nome': _gerarNomeMedicamento(title),
            'tipo': _gerarTipoMedicamento(id),
            'doseMg': _gerarDosagem(id),
            'descricao': body.length > 50 ? body.substring(0, 50) : body,
            'laboratorio': _gerarLaboratorio(userId),
            'dataFabricacao': DateTime.now().subtract(Duration(days: id * 10)),
            'dataValidade': DateTime.now().add(Duration(days: 365 + id * 30)),
            'lote': 'API_LOTE_$id',
            'quantidade': 50 + (id % 100),
            'isMedicamentoControlado': id % 5 == 0,
          };
        }).toList();
      }
      throw Exception('Falha ao buscar dados da API');
    } catch (e) {
      throw Exception('Erro na comunicação com API: $e');
    }
  }

  // Buscar preços de medicamentos em API externa
  Future<Map<String, double>> buscarPrecosMedicamentos(
      List<String> medicamentosIds) async {
    try {
      final response = await _dio.get('/posts');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        Map<String, double> precos = {};

        for (var id in medicamentosIds) {
          final index = int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
          final item = data.firstWhere((post) => post['id'] == index,
              orElse: () => {'id': 1});
          final itemId = item['id'] as int;
          precos[id] = 10.0 + (itemId % 50).toDouble();
        }

        return precos;
      }
      throw Exception('Falha ao buscar preços');
    } catch (e) {
      throw Exception('Erro ao buscar preços: $e');
    }
  }

  // Verificar disponibilidade de medicamentos
  Future<Map<String, bool>> verificarDisponibilidade(
      List<String> medicamentosIds) async {
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simula latência

      Map<String, bool> disponibilidade = {};
      for (var id in medicamentosIds) {
        final hash = id.hashCode;
        disponibilidade[id] = hash % 3 != 0; // 66% de disponibilidade
      }

      return disponibilidade;
    } catch (e) {
      throw Exception('Erro ao verificar disponibilidade: $e');
    }
  }

  // Sincronizar dados com servidor remoto
  Future<bool> sincronizarDados(Map<String, dynamic> dados) async {
    try {
      final response = await _dio.post('/posts', data: dados);
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Métodos auxiliares para gerar dados simulados
  String _gerarNomeMedicamento(String title) {
    final medicamentos = [
      'Paracetamol',
      'Ibuprofeno',
      'Aspirina',
      'Dipirona',
      'Amoxicilina',
      'Azitromicina',
      'Omeprazol',
      'Losartana',
      'Metformina',
      'Sinvastatina'
    ];
    return medicamentos[title.length % medicamentos.length];
  }

  String _gerarTipoMedicamento(int id) {
    final tipos = ['Comprimido', 'Cápsula', 'Xarope', 'Pomada', 'Injeção'];
    return tipos[id % tipos.length];
  }

  double _gerarDosagem(int id) {
    final dosagens = [250.0, 500.0, 750.0, 1000.0, 100.0, 200.0];
    return dosagens[id % dosagens.length];
  }

  String _gerarLaboratorio(int userId) {
    final laboratorios = ['EMS', 'Medley', 'Sanofi', 'Roche', 'Pfizer'];
    return laboratorios[userId % laboratorios.length];
  }
}
