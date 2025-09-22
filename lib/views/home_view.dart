import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/agente_viewmodel.dart';
import './widgets/consulta_form_widget.dart';
import './widgets/sync_button_widget.dart';
import './widgets/agente_info_card_widget.dart';
import './widgets/massa_info_card_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _cnpjController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _densidadeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _cnpjController.dispose();
    _quantidadeController.dispose();
    _densidadeController.dispose();
    super.dispose();
  }

  /// Valida o formulário, executa a consulta do agente e o cálculo da massa.
  ///
  /// Após ler os dados, os campos de texto são limpos e o teclado é
  /// recolhido para uma melhor experiência de usuário, exibindo apenas os
  /// resultados da consulta.
  Future<void> _processarConsulta() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final cnpj = _cnpjController.text.trim();
    final quantidade =
        double.tryParse(_quantidadeController.text.replaceAll(',', '.')) ?? 0;
    final densidade =
        double.tryParse(_densidadeController.text.replaceAll(',', '.')) ?? 0;
    final viewModel = context.read<AgenteViewModel>();

    _cnpjController.clear();
    _quantidadeController.clear();
    _densidadeController.clear();
    FocusScope.of(context).unfocus();

    try {
      await viewModel.buscarAgente(cnpj);
      viewModel.calcularMassa(quantidade, densidade);

      if (mounted && viewModel.agente == null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text("Empresa não encontrada")),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text("Erro ao consultar empresa: $e")),
          );
      }
    }
  }

  /// Inicia a sincronização manual dos dados da ANP.
  ///
  /// Antes de iniciar, limpa todos os campos de texto e os resultados
  /// de consultas anteriores para fornecer um feedback claro de que
  /// uma nova operação começou.
  Future<void> _sincronizarManual() async {
    _cnpjController.clear();
    _quantidadeController.clear();
    _densidadeController.clear();
    context.read<AgenteViewModel>().limparResultados();

    try {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text("Limpando e sincronizando dados...")),
        );

      await context.read<AgenteViewModel>().sincronizar();

      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text("Banco limpo e dados sincronizados!")),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text("Erro ao sincronizar: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AgenteViewModel>();

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "SAÍDA DE ÁLCOOL",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: ConsultaFormWidget(
                    cnpjController: _cnpjController,
                    quantidadeController: _quantidadeController,
                    densidadeController: _densidadeController,
                    onConsultar: _processarConsulta,
                  ),
                ),
                const SizedBox(height: 8),
                SyncButtonWidget(
                  onSincronizar: _sincronizarManual,
                  isLoading: viewModel.isLoading,
                  progressText: viewModel.syncProgress,
                ),
                const SizedBox(height: 8),
                if (viewModel.agente != null)
                  AgenteInfoCardWidget(agente: viewModel.agente!),
                if (viewModel.massaKg != null)
                  MassaInfoCardWidget(massaKg: viewModel.massaKg!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
