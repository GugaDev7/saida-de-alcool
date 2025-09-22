import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/agente_viewmodel.dart';

class ConsultaFormWidget extends StatelessWidget {
  final TextEditingController cnpjController;
  final TextEditingController quantidadeController;
  final TextEditingController densidadeController;
  final VoidCallback onConsultar;

  const ConsultaFormWidget({
    super.key,
    required this.cnpjController,
    required this.quantidadeController,
    required this.densidadeController,
    required this.onConsultar,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AgenteViewModel>().isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Campo de entrada do CNPJ
        TextFormField(
          controller: cnpjController,
          decoration: const InputDecoration(
            labelText: "CNPJ",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            final v = (value ?? '').replaceAll(RegExp(r'\D'), '');
            if (v.length != 14) return 'CNPJ deve ter 14 dígitos';
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Campo de quantidade em m³
        TextFormField(
          controller: quantidadeController,
          decoration: const InputDecoration(
            labelText: "Quantidade (m³)",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            final v = double.tryParse((value ?? '').replaceAll(',', '.'));
            if (v == null || v <= 0) return 'Informe um número válido (> 0)';
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Campo de densidade
        TextFormField(
          controller: densidadeController,
          decoration: const InputDecoration(
            labelText: "Densidade",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            final v = double.tryParse((value ?? '').replaceAll(',', '.'));
            if (v == null || v <= 0) return 'Informe um número válido (> 0)';
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Botão para consultar empresa
        ElevatedButton.icon(
          onPressed: isLoading ? null : onConsultar,
          icon: const Icon(Icons.search),
          label: const Text("Consultar Empresa"),
        ),
      ],
    );
  }
}
