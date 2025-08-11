import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../model/medicamento.dart';
import '../model/laboratorio.dart';
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
      debugPrint('Erro ao carregar laboratórios: $e');
    }
  }

  Future<void> adicionarMedicamento(
      Medicamento medicamento, String nomeLataboratorio) async {
    try {
      // Busca o laboratório pelo nome ou cria um novo
      Laboratorio? laboratorio =
          await _laboratorioDAO.getLaboratorioByNome(nomeLataboratorio);

      if (laboratorio == null) {
        // Cria um novo laboratório se não existir
        laboratorio = Laboratorio(nome: nomeLataboratorio);
        await _laboratorioDAO.insertLaboratorio(laboratorio);
        laboratorio =
            await _laboratorioDAO.getLaboratorioByNome(nomeLataboratorio);
        await _loadLaboratorios(); // Recarrega a lista de laboratórios
      }

      if (laboratorio != null && laboratorio.id != null) {
        await _medicamentoDAO.insertMedicamento(medicamento, laboratorio.id!);
        await _loadMedicamentos();
      }
    } catch (e) {
      debugPrint('Erro ao adicionar medicamento: $e');
      rethrow;
    }
  }

  Future<void> removerMedicamentos(
      List<Medicamento> medicamentosParaRemover) async {
    try {
      List<String> ids = medicamentosParaRemover.map((med) => med.id).toList();
      await _medicamentoDAO.deleteMedicamentos(ids);
      await _loadMedicamentos();
    } catch (e) {
      debugPrint('Erro ao remover medicamentos: $e');
      rethrow;
    }
  }

  Future<void> atualizarMedicamento(
      Medicamento medicamento, String nomeLaboratorio) async {
    try {
      Laboratorio? laboratorio =
          await _laboratorioDAO.getLaboratorioByNome(nomeLaboratorio);

      if (laboratorio == null) {
        laboratorio = Laboratorio(nome: nomeLaboratorio);
        await _laboratorioDAO.insertLaboratorio(laboratorio);
        laboratorio =
            await _laboratorioDAO.getLaboratorioByNome(nomeLaboratorio);
        await _loadLaboratorios();
      }

      if (laboratorio != null && laboratorio.id != null) {
        await _medicamentoDAO.updateMedicamento(medicamento, laboratorio.id!);
        await _loadMedicamentos();
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
          descricao: 'Analgésico e antitérmico',
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
          tipo: 'Cápsula',
          doseMg: 250.0,
          descricao: 'Antibiótico de amplo espectro.',
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
          descricao: 'Ansiolítico e anticonvulsivante. Medicamento controlado.',
          laboratorio: 'Sanofi',
          dataFabricacao: DateTime(2024, 3, 20),
          dataValidade: DateTime(2026, 3, 20),
          lote: 'LOTCLO003',
          quantidade: 50,
          isMedicamentoControlado: true,
        ),
      ];

      for (Medicamento med in medicamentosExemplo) {
        await adicionarMedicamento(med, med.laboratorio);
      }
    } catch (e) {
      debugPrint('Erro ao adicionar dados de exemplo: $e');
    }
  }

  Future<Laboratorio?> getLaboratorioById(int id) async {
    return await _laboratorioDAO.getLaboratorioById(id);
  }

  Future<void> adicionarLaboratorio(Laboratorio laboratorio) async {
    try {
      await _laboratorioDAO.insertLaboratorio(laboratorio);
      await _loadLaboratorios();
    } catch (e) {
      debugPrint('Erro ao adicionar laboratório: $e');
      rethrow;
    }
  }
}
