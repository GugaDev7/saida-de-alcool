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

  /// Busca empresa no banco pelo CNPJ informado no formulário.
  Future<void> _consultarEmpresa() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final cnpj = _cnpjController.text.trim();
    final viewModel = context.read<AgenteViewModel>();

    try {
      await viewModel.buscarAgente(cnpj);

      if (viewModel.agente == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Empresa não encontrada")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao consultar empresa: $e")));
    }
  }

  /// Calcula o peso (M³ × Densidade) a partir dos campos do formulário.
  void _calcularPeso() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final quantidade = double.tryParse(_quantidadeController.text) ?? 0;
    final densidade = double.tryParse(_densidadeController.text) ?? 0;
    context.read<AgenteViewModel>().calcularMassa(quantidade, densidade);
  }

  /// Inicia sincronização manual e exibe feedback na UI.
  Future<void> _sincronizarManual() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Limpando e sincronizando dados...")),
      );

      await context.read<AgenteViewModel>().sincronizar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Banco limpo e dados sincronizados!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao sincronizar: $e")));
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
                  "Consulta ANP",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: ConsultaFormWidget(
                    cnpjController: _cnpjController,
                    quantidadeController: _quantidadeController,
                    densidadeController: _densidadeController,
                    onConsultar: () {
                      _consultarEmpresa();
                      _calcularPeso();
                    },
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
