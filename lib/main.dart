import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'views/home_view.dart';

Future<void> main() async {
  // Garante que o Flutter esteja inicializado antes de usar plugins nativos
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o gerenciador de janelas do desktop
  await windowManager.ensureInitialized();

  // Define as opções iniciais da janela
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600), // tamanho fixo inicial (mockado)
    center: true, // centraliza na tela
    title: "Consulta ANP", // título da janela
  );

  // Aplica as opções antes de exibir a janela
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show(); // mostra a janela
    await windowManager.focus(); // dá foco inicial
    await windowManager.setResizable(false); // bloqueia redimensionamento
  });

  // Roda o app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Consulta ANP",
      debugShowCheckedModeBanner: false, // remove a faixa "debug"
      theme: ThemeData(
        useMaterial3: true, // ativa Material 3 (mais moderno)
        colorSchemeSeed: Colors.blue, // cor principal do app
      ),
      home: const HomeView(), // chama a tela principal
    );
  }
}
