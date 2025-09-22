import 'package:flutter/material.dart';
import '../../models/agente_model.dart';

/// Exibe informações resumidas de um [AgenteModel] em um Card.
class AgenteInfoCardWidget extends StatelessWidget {
  final AgenteModel agente;

  /// Cria o widget com o [agente] a ser exibido.
  const AgenteInfoCardWidget({super.key, required this.agente});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.factory),
        title: Text(agente.razaoSocial),
        subtitle: Text(
          "Cód. Instalação: ${agente.codigo}\n"
          "Município: ${agente.municipio} - ${agente.estado}",
        ),
      ),
    );
  }
}
