import 'package:flutter/material.dart';
import '../models/agente_model.dart';
import '../repositories/agente_repository.dart';

/// ViewModel responsável por orquestrar sincronização, busca e cálculos de massa.
class AgenteViewModel extends ChangeNotifier {
  final AgenteRepository repository;

  bool isLoading = false;
  bool isInitializing = false;
  String? syncProgress;
  AgenteModel? agente;
  double? massaKg;

  /// Cria um [AgenteViewModel] com o [repository] injetado.
  AgenteViewModel({required this.repository});

  /// Executa a sincronização completa com feedback de progresso.
  Future<void> sincronizar() async {
    isLoading = true;
    syncProgress = null;
    notifyListeners();

    await repository.sincronizarAgentes(
      onProgress: (inserted, total) {
        syncProgress = "Inserindo $inserted de $total...";
        notifyListeners();
      },
    );

    isLoading = false;
    syncProgress = null;
    notifyListeners();
  }

  /// Busca um agente no banco pelo CNPJ e atualiza o estado.
  Future<void> buscarAgente(String cnpj) async {
    agente = await repository.getAgenteByCnpj(cnpj);
    notifyListeners();
  }

  /// Calcula a massa (kg) a partir de quantidade em m³ e densidade (kg/m³).
  void calcularMassa(double quantidadeM3, double densidade) {
    massaKg = quantidadeM3 * densidade;
    notifyListeners();
  }

  /// Limpa os resultados da consulta (agente e massa).
  void limparResultados() {
    agente = null;
    massaKg = null;
    notifyListeners();
  }
}
