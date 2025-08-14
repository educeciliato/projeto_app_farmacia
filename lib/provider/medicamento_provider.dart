import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:controle_estoque/model/medicamento.dart';
import 'package:controle_estoque/model/laboratorio.dart';

class MedicamentoProvider with ChangeNotifier {
  List<Medicamento> _medicamentos = [];
  List<Laboratorio> _laboratorios = [];
  bool _isLoading = false;

  List<Medicamento> get medicamentos => _medicamentos;
  List<Laboratorio> get laboratorios => _laboratorios;
  bool get isLoading => _isLoading;

  Future<void> initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadLaboratorios();
      await _loadMedicamentos();

      // Se não houver medicamentos, adiciona dados de exemplo
      if (_medicamentos.isEmpty) {
        await _addExampleData();
      }
    } catch (e) {
      debugPrint('Erro ao inicializar dados: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadMedicamentos() async {
    try {
      // Para web, vamos simular dados em memória
      // Em um app real, você carregaria do banco
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar medicamentos: $e');
    }
  }

  Future<void> _loadLaboratorios() async {
    try {
      // Laboratorios de exemplo
      _laboratorios = [
        Laboratorio(id: 1, nome: 'EMS'),
        Laboratorio(id: 2, nome: 'Medley'),
        Laboratorio(id: 3, nome: 'Sanofi'),
      ];
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar laboratorios: $e');
    }
  }

  Future<void> adicionarMedicamento(
      Medicamento medicamento, String nomeLaboratorio) async {
    try {
      // Busca ou cria laboratorio
      Laboratorio? laboratorio =
          _laboratorios.where((lab) => lab.nome == nomeLaboratorio).firstOrNull;

      if (laboratorio == null) {
        laboratorio = Laboratorio(
          id: _laboratorios.length + 1,
          nome: nomeLaboratorio,
        );
        _laboratorios.add(laboratorio);
      }

      _medicamentos.add(medicamento);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar medicamento: $e');
      rethrow;
    }
  }

  Future<void> removerMedicamentos(
      List<Medicamento> medicamentosParaRemover) async {
    try {
      for (var med in medicamentosParaRemover) {
        _medicamentos.removeWhere((m) => m.id == med.id);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao remover medicamentos: $e');
      rethrow;
    }
  }

  Future<void> atualizarMedicamento(
      Medicamento medicamento, String nomeLaboratorio) async {
    try {
      int index = _medicamentos.indexWhere((m) => m.id == medicamento.id);
      if (index != -1) {
        _medicamentos[index] = medicamento;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao atualizar medicamento: $e');
      rethrow;
    }
  }

  Future<void> _addExampleData() async {
    try {
      // Dados de exemplo
      final medicamentosExemplo = [
        Medicamento(
          id: const Uuid().v4(),
          nome: 'Paracetamol',
          tipo: 'Comprimido',
          doseMg: 500.0,
          descricao: 'Analgesico e antitermico',
          laboratorio: 'EMS',
          dataFabricacao: DateTime(2024, 1, 15),
          dataValidade: DateTime(2026, 1, 15),
          lote: 'LOTPAR001',
          quantidade: 200,
          isMedicamentoControlado: false,
        ),
        Medicamento(
          id: const Uuid().v4(),
          nome: 'Amoxicilina',
          tipo: 'Capsula',
          doseMg: 250.0,
          descricao: 'Antibiotico de amplo espectro.',
          laboratorio: 'Medley',
          dataFabricacao: DateTime(2023, 11, 1),
          dataValidade: DateTime(2025, 11, 1),
          lote: 'LOTAMO002',
          quantidade: 150,
          isMedicamentoControlado: false,
        ),
        Medicamento(
          id: const Uuid().v4(),
          nome: 'Clonazepam',
          tipo: 'Comprimido',
          doseMg: 2.0,
          descricao: 'Ansiolitico e anticonvulsivante. Medicamento controlado.',
          laboratorio: 'Sanofi',
          dataFabricacao: DateTime(2024, 3, 20),
          dataValidade: DateTime(2026, 3, 20),
          lote: 'LOTCLO003',
          quantidade: 50,
          isMedicamentoControlado: true,
        ),
      ];

      _medicamentos.addAll(medicamentosExemplo);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar dados de exemplo: $e');
    }
  }

  Future<Laboratorio?> getLaboratorioById(int id) async {
    try {
      return _laboratorios.where((lab) => lab.id == id).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  Future<void> adicionarLaboratorio(Laboratorio laboratorio) async {
    try {
      laboratorio.id = _laboratorios.length + 1;
      _laboratorios.add(laboratorio);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao adicionar laboratorio: $e');
      rethrow;
    }
  }
}

// Extension para firstOrNull (caso não esteja disponível)
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}
