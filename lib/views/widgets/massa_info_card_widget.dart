import 'package:flutter/material.dart';

/// Exibe o resultado da massa calculada em quilogramas.
class MassaInfoCardWidget extends StatelessWidget {
  final double massaKg;

  /// Cria o card com o valor de [massaKg] a ser exibido.
  const MassaInfoCardWidget({super.key, required this.massaKg});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: ListTile(
        leading: const Icon(Icons.scale),
        title: const Text("Peso Calculado (KG)"),
        subtitle: Text("${massaKg.toStringAsFixed(2)} kg"),
      ),
    );
  }
}
