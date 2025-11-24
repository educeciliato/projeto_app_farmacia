import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:controle_estoque/model/medicamento.dart';
import 'package:controle_estoque/model/laboratorio.dart';
import '../dao/medicamento_dao.dart';
import '../dao/laboratorio_dao.dart';

class MedicamentoProvider with ChangeNotifier {
  final MedicamentoDAO _medicamentoDAO = MedicamentoDAO();
  final LaboratorioDAO _laboratorioDAO = LaboratorioDAO();
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
        // Recarrega os medicamentos após adicionar os dados de exemplo
        await _loadMedicamentos();
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
      _medicamentos = await _medicamentoDAO.getAllMedicamentos();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar medicamentos: $e');
    }
  }

  Future<void> _loadLaboratorios() async {
    try {
      _laboratorios = await _laboratorioDAO.getAllLaboratorios();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar laboratorios: $e');
    }
  }

  Future<void> adicionarMedicamento(
      Medicamento medicamento, String nomeLaboratorio) async {
    try {
      // Busca o laboratório pelo nome no banco de dados
      Laboratorio? laboratorio =
          await _laboratorioDAO.getLaboratorioByNome(nomeLaboratorio);

      if (laboratorio == null) {
        // Se não existir, adiciona o laboratório ao banco de dados
        laboratorio = Laboratorio(nome: nomeLaboratorio);
        await _laboratorioDAO.insertLaboratorio(laboratorio);
        // Recarrega os laboratórios para obter o ID gerado
        await _loadLaboratorios();
        laboratorio = await _laboratorioDAO.getLaboratorioByNome(nomeLaboratorio);
      }

      if (laboratorio != null) {
        // Adiciona o medicamento ao banco de dados
        await _medicamentoDAO.insertMedicamento(medicamento, laboratorio.id!);
        // Recarrega a lista de medicamentos
        await _loadMedicamentos();
      } else {
        debugPrint('Erro: Laboratório não encontrado ou não pôde ser criado.');
      }
    } catch (e) {
      debugPrint('Erro ao adicionar medicamento: $e');
      rethrow;
    }
  }

  Future<void> removerMedicamentos(
      List<Medicamento> medicamentosParaRemover) async {
    try {
      final List<String> idsParaRemover =
          medicamentosParaRemover.map((m) => m.id).toList();
      await _medicamentoDAO.deleteMedicamentos(idsParaRemover);
      await _loadMedicamentos();
    } catch (e) {
      debugPrint('Erro ao remover medicamentos: $e');
      rethrow;
    }
  }

  Future<void> atualizarMedicamento(
      Medicamento medicamento, String nomeLaboratorio) async {
    try {
      // Busca o laboratório pelo nome no banco de dados
      Laboratorio? laboratorio =
          await _laboratorioDAO.getLaboratorioByNome(nomeLaboratorio);

      if (laboratorio != null) {
        await _medicamentoDAO.updateMedicamento(medicamento, laboratorio.id!);
        await _loadMedicamentos();
      } else {
        debugPrint('Erro: Laboratório não encontrado.');
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

      for (var med in medicamentosExemplo) {
        // Para os dados de exemplo, vamos assumir que o laboratório já existe no banco
        Laboratorio? laboratorio =
            await _laboratorioDAO.getLaboratorioByNome(med.laboratorio);
        if (laboratorio != null) {
          await _medicamentoDAO.insertMedicamento(med, laboratorio.id!);
        }
      }
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
      await _laboratorioDAO.insertLaboratorio(laboratorio);
      await _loadLaboratorios();
    } catch (e) {
      debugPrint('Erro ao adicionar laboratorio: $e');
      rethrow;
    }
  }
}


