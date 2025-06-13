import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../model/medicamento.dart'; 

class MedicamentoProvider with ChangeNotifier {
  final List<Medicamento> _medicamentos = [
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

  List<Medicamento> get medicamentos => _medicamentos;

  void adicionarMedicamento(Medicamento medicamento) {
    _medicamentos.add(medicamento);
    notifyListeners();
  }

  void removerMedicamentos(List<Medicamento> medicamentosParaRemover) {
    _medicamentos.removeWhere((med) => medicamentosParaRemover.contains(med));
    notifyListeners();
  }
}
