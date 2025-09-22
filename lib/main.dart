import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'views/home_view.dart';
import 'database/app_database.dart';
import 'repositories/agente_repository.dart';
import 'services/anp_service.dart';
import 'viewmodels/agente_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    title: "Saída de Álcool",
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setResizable(false);
  });

  final database = AppDatabase();
  final agenteDao = await database.getAgenteDao();
  final anpService = AnpService();
  final repository = AgenteRepository(api: anpService, dao: agenteDao);

  runApp(MyApp(repository: repository));
}

/// Raiz do aplicativo com injeção de dependências básicas e tema.
class MyApp extends StatelessWidget {
  final AgenteRepository repository;

  /// Recebe o [repository] que será injetado no [AgenteViewModel].
  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AgenteViewModel>(
      create: (_) => AgenteViewModel(repository: repository),
      child: MaterialApp(
        title: "Saída de Álcool",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        home: const HomeView(),
      ),
    );
  }
}
