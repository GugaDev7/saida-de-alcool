import 'package:flutter/material.dart';

/// Botão e indicadores para acionar sincronização com feedback de progresso.
class SyncButtonWidget extends StatelessWidget {
  final VoidCallback onSincronizar;
  final bool isLoading;
  final String? progressText;

  /// Cria o widget de sincronização, desabilitando o botão quando [isLoading].
  const SyncButtonWidget({
    super.key,
    required this.onSincronizar,
    required this.isLoading,
    required this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: isLoading ? null : onSincronizar,
          icon: const Icon(Icons.sync),
          label: const Text("Limpar e Sincronizar"),
        ),
        const SizedBox(height: 16),
        if (isLoading) ...[
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 8),
          if (progressText != null) Center(child: Text(progressText!)),
        ],
      ],
    );
  }
}
