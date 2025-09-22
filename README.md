# Utilitário de Consulta ANP e Cálculo de Massa

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?style=for-the-badge&logo=dart)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Platforms](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey?style=for-the-badge)

---

## Visão Geral

Este é um aplicativo desktop multiplaforma (Windows, macOS, Linux) desenvolvido em **Flutter**. Ele serve como uma ferramenta de produtividade para consultar agentes econômicos da **Agência Nacional do Petróleo (ANP)** e realizar cálculos de massa de álcool.

O projeto foi concebido como um estudo de caso para a aplicação de **arquitetura limpa**, gerenciamento de estado avançado e técnicas de performance em um ambiente de desktop.

## Destaques Técnicos

Este projeto demonstra competência nas seguintes áreas:

* **Arquitetura Limpa (MVVM + Repository)**: O código é estritamente separado em camadas (View, ViewModel, Repository, Service, DAO), promovendo baixo acoplamento, testabilidade e manutenibilidade.

* **Gerenciamento de Estado com `Provider`**: Utilização idiomática do `Provider` para injeção de dependências (`ChangeNotifierProvider`) e reconstrução eficiente da UI (`context.watch` e `context.read`).

* **Persistência de Dados Offline com SQLite**: Implementação de uma estratégia de cache "offline-first". Os dados da ANP são sincronizados para um banco de dados **SQLite** local, permitindo consultas instantâneas e o funcionamento do app sem conexão com a internet.

* **Performance de Banco de Dados**:
    * **Inserção em Lote (`batch`)**: Para popular o banco de dados com dezenas de milhares de registros de forma eficiente.
    * **Indexação de Tabela**: Criação de um índice na coluna `cnpj` para garantir que as buscas sejam executadas em tempo O(log n), em vez de O(n).
    * **Modo WAL (`PRAGMA journal_mode=WAL`)**: Para otimizar operações de escrita concorrente.

* **Consumo de API REST**: Comunicação com a API pública da ANP usando o pacote `http`, com tratamento de `timeout` e erros.

* **UI Reativa e Componentizada**: A `HomeView` foi refatorada em pequenos widgets reutilizáveis (`ConsultaFormWidget`, `SyncButtonWidget`, etc.), cada um com sua própria responsabilidade, tornando o código da UI declarativo e fácil de manter.

* **Compatibilidade Multiplataforma (Desktop)**: O projeto utiliza `sqflite_common_ffi` e `window_manager` para garantir a funcionalidade nativa em Windows, macOS e Linux.

## Arquitetura Aplicada

O fluxo de dados segue um padrão unidirecional, garantindo previsibilidade e facilitando o debug.

1.  **View**: Captura eventos do usuário e os delega ao ViewModel.
2.  **ViewModel**: Executa a lógica de apresentação e atualiza seu estado.
3.  **Provider**: Notifica a View sobre a mudança de estado, causando uma reconstrução da UI.
4.  **Repository**: Orquestra a obtenção de dados, seja da API ou do cache local (SQLite).

## Como Executar e Compilar

### Pré-requisitos

* Flutter SDK (versão 3.24.0 ou superior).
* **Para Windows**: Visual Studio 2022+ com a carga de trabalho **"Desenvolvimento para desktop com C++"**.

### Execução em Modo de Desenvolvimento

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/gugadev7/saida-de-alcool.git](https://github.com/gugadev7/saida-de-alcool.git)
    cd saida-de-alcool
    ```

2.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```

3.  **Execute o aplicativo:**
    ```bash
    flutter run -d windows  # Ou -d macos, -d linux
    ```

### Compilando para Produção (Windows)

1.  **Garanta que o ambiente está correto:**
    ```bash
    flutter doctor
    ```

2.  **Execute o build:**
    ```bash
    flutter build windows
    ```

3.  **Distribua:** O aplicativo final estará em `build\windows\runner\Release\`. Compacte esta pasta inteira para distribuição.
