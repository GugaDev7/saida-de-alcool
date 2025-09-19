import 'package:flutter/material.dart';
import '../viewmodels/agente_viewmodel.dart';
import '../database/app_database.dart';
import '../repositories/agente_repository.dart';
import '../services/anp_service.dart';
import '../models/agente_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Controllers para capturar o texto dos campos
  final _cnpjController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _densidadeController = TextEditingController();

  // ViewModel para gerenciar estado
  AgenteViewModel? _viewModel;
  bool _isInitializing = true;

  /// Inicializa o ViewModel
  @override
  void initState() {
    super.initState();
    _initializeViewModel();
  }

  Future<void> _initializeViewModel() async {
    try {
      print('Iniciando inicialização do ViewModel...');

      final database = AppDatabase();
      print('Database criado');

      final agenteDao = await database.getAgenteDao();
      print('DAO obtido');

      final anpService = AnpService();
      print('Service criado');

      final repository = AgenteRepository(api: anpService, dao: agenteDao);
      print('Repository criado');

      _viewModel = AgenteViewModel(repository: repository);
      print('ViewModel criado');

      // Adiciona listener para atualizar a UI quando o ViewModel mudar
      _viewModel!.addListener(_onViewModelChanged);
      print('Listener adicionado');

      // Marca como inicializado primeiro, sem sincronizar
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        print('Estado atualizado - inicialização concluída');
      }

      // Tenta sincronizar em background (sem bloquear a UI)
      _sincronizarEmBackground();
    } catch (e) {
      print('Erro ao inicializar ViewModel: $e');
      print('Stack trace: ${StackTrace.current}');
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao inicializar aplicação: $e")),
        );
      }
    }
  }

  /// Sincroniza dados em background sem bloquear a UI
  Future<void> _sincronizarEmBackground() async {
    try {
      print('Iniciando sincronização em background...');
      await _viewModel!.sincronizar();
      print('Sincronização em background concluída');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dados sincronizados com sucesso!")),
        );
      }
    } catch (e) {
      print('Erro na sincronização em background: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao sincronizar dados: $e")),
        );
      }
    }
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_onViewModelChanged);
    _cnpjController.dispose();
    _quantidadeController.dispose();
    _densidadeController.dispose();
    super.dispose();
  }

  /// Busca empresa no banco pelo CNPJ
  Future<void> _consultarEmpresa() async {
    if (_viewModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aplicação ainda inicializando...")),
      );
      return;
    }

    final cnpj = _cnpjController.text.trim();

    if (cnpj.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Digite um CNPJ válido")));
      return;
    }

    try {
      await _viewModel!.buscarAgente(cnpj);

      if (_viewModel!.agente == null) {
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

  /// Calcula o peso (M³ × Densidade)
  void _calcularPeso() {
    if (_viewModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aplicação ainda inicializando...")),
      );
      return;
    }

    final quantidade = double.tryParse(_quantidadeController.text);
    final densidade = double.tryParse(_densidadeController.text);

    if (quantidade != null && densidade != null) {
      _viewModel!.calcularMassa(quantidade, densidade);
    } else {
      // Se valores forem inválidos, alerta o usuário
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Digite valores válidos")));
    }
  }

  /// Testa se o banco está funcionando
  Future<void> _testarBanco() async {
    if (_viewModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aplicação ainda inicializando...")),
      );
      return;
    }

    try {
      // Primeiro, adiciona dados de teste se não existirem
      await _adicionarDadosTeste();

      // Testa com um CNPJ conhecido
      await _viewModel!.buscarAgente("53629021000137");

      if (_viewModel!.agente != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Banco funcionando! Empresa encontrada."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Banco funcionando, mas empresa não encontrada."),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro no banco: $e")));
    }
  }

  /// Adiciona dados de teste ao banco
  Future<void> _adicionarDadosTeste() async {
    try {
      final database = AppDatabase();
      final agenteDao = await database.getAgenteDao();

      // Verifica se já existem dados
      final agentes = await agenteDao.getAllAgentes();
      if (agentes.isNotEmpty) {
        print('Dados já existem no banco: ${agentes.length} registros');
        return;
      }

      // Adiciona dados de teste
      final agenteTeste = AgenteModel(
        codigo: 1302227,
        cnpj: "53629021000137",
        razaoSocial: "JR DISTRIBUIDORA GAS LTDA",
        cep: "75250000",
        municipio: "SENADOR CANEDO",
        estado: "GO",
        status: "ABERTO",
      );

      await agenteDao.insertAgente(agenteTeste);
      print('Dados de teste adicionados ao banco');
    } catch (e) {
      print('Erro ao adicionar dados de teste: $e');
    }
  }

  /// Sincroniza dados manualmente
  Future<void> _sincronizarManual() async {
    if (_viewModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aplicação ainda inicializando...")),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Sincronizando dados...")));

      await _viewModel!.sincronizar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dados sincronizados com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao sincronizar: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostra loading enquanto inicializa
    if (_isInitializing || _viewModel == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Inicializando aplicação..."),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      // Centraliza o conteúdo no meio da janela (desktop style)
      body: Center(
        child: SizedBox(
          width: 500, // largura fixa para o formulário
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min, // só ocupa o necessário
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título da tela
                Text(
                  "Consulta ANP",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),

                // Campo de entrada do CNPJ
                TextField(
                  controller: _cnpjController,
                  decoration: const InputDecoration(
                    labelText: "CNPJ",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // Campo de quantidade em m³
                TextField(
                  controller: _quantidadeController,
                  decoration: const InputDecoration(
                    labelText: "Quantidade (m³)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // Campo de densidade
                TextField(
                  controller: _densidadeController,
                  decoration: const InputDecoration(
                    labelText: "Densidade",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Botão para consultar empresa
                ElevatedButton.icon(
                  onPressed: () {
                    _consultarEmpresa();
                    _calcularPeso();
                  },
                  icon: const Icon(Icons.search),
                  label: const Text("Consultar Empresa"),
                ),
                const SizedBox(height: 8),

                // Botão para calcular peso
                // ElevatedButton.icon(
                //   onPressed: _calcularPeso,
                //   icon: const Icon(Icons.calculate),
                //   label: const Text("Calcular Peso (kg)"),
                // ),
                // const SizedBox(height: 8),

                // Botão para testar banco
                // ElevatedButton.icon(
                //   onPressed: _testarBanco,
                //   icon: const Icon(Icons.storage),
                //   label: const Text("Testar Banco"),
                // ),
                // const SizedBox(height: 8),

                // Botão para sincronizar manualmente
                ElevatedButton.icon(
                  onPressed: _sincronizarManual,
                  icon: const Icon(Icons.sync),
                  label: const Text("Sincronizar Dados"),
                ),
                const SizedBox(height: 16),

                // Card mostrando dados da empresa (se achou)
                if (_viewModel!.agente != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.factory),
                      title: Text(_viewModel!.agente!.razaoSocial),
                      subtitle: Text(
                        "Cód. Instalação: ${_viewModel!.agente!.codigo}\n"
                        "Município: ${_viewModel!.agente!.municipio} - ${_viewModel!.agente!.estado}",
                      ),
                    ),
                  ),

                // Card mostrando o peso calculado
                if (_viewModel!.massaKg != null)
                  Card(
                    color: Colors.blue.shade50,
                    child: ListTile(
                      leading: const Icon(Icons.scale),
                      title: const Text("Peso Calculado"),
                      subtitle: Text(
                        "${_viewModel!.massaKg!.toStringAsFixed(2)} kg",
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
