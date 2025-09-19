import 'package:flutter/material.dart';
import '../models/agente_model.dart';
import '../repositories/agente_repository.dart';

class AgenteViewModel extends ChangeNotifier {
  final AgenteRepository repository;

  bool isLoading = false; // Tela de loading
  AgenteModel? agente; // Agente consultado
  double? massaKg; // Resultado do cálculo

  AgenteViewModel({required this.repository});

  // Sincronização inicial da API
  Future<void> sincronizar() async {
    isLoading = true;
    notifyListeners();

    await repository.sincronizarAgentes();

    isLoading = false;
    notifyListeners();
  }

  // Buscar agente por CNPJ
  Future<void> buscarAgente(String cnpj) async {
    agente = await repository.getAgenteByCnpj(cnpj);
    notifyListeners();
  }

  // Calcular massa do álcool: quantidade (m³) x densidade (kg/m³)
  void calcularMassa(double quantidadeM3, double densidade) {
    massaKg = quantidadeM3 * densidade;
    notifyListeners();
  }
}
