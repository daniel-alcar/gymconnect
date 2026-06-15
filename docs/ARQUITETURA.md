# GymConnect — Arquitetura por Módulo (E-V-R-S-C-P)

Versão do app **organizada por módulo**, seguindo a arquitetura em camadas das
aulas (Entity / View / Repository / Service / Controller / Provider).
Funcionalmente idêntica à versão organizada por tipo (`mobile/`).

## Estrutura

```
lib/
├── main.dart                      # Composição de dependências + runApp
└── app/
    ├── core/                      # Infraestrutura compartilhada
    │   ├── client/                #   dio_client.dart (DIO + interceptors JWT)
    │   ├── database/              #   db_helper.dart (Singleton SQLite, DDL externo)
    │   ├── storage/               #   storage_service.dart (SharedPreferences)
    │   ├── network/               #   connectivity_service.dart (connectivity_plus)
    │   ├── errors/                #   app_exception.dart
    │   ├── theme/                 #   app_theme.dart / app_colors.dart
    │   └── constants/             #   app_constants.dart
    ├── shared/
    │   ├── widgets/               # Componentes reutilizáveis
    │   └── utils/                 # Helpers (datas, snackbar, validators)
    ├── routes/                    # app_router.dart + route_names.dart
    └── modules/
        ├── auth/                  # Login, cadastro, sessão (login offline)
        ├── treinos/              # Treinos do aluno (Offline-First) + descrição/execução
        ├── cliente/              # Professor: exercícios (CRUD), treinos, alunos
        ├── chat/                 # GIA (assistente IA)
        ├── perfil/               # Perfil do usuário (foto local)
        └── home/                 # Dashboard, shells, tema, atividades, conclusões
```

Cada módulo subdivide em `models/ services/ repositories/ providers/ views/`.

## Camadas

| Camada      | Onde                       | Responsabilidade                          |
|-------------|----------------------------|-------------------------------------------|
| Entity      | `modules/*/models`         | Dado puro + (de)serialização              |
| Service     | `modules/*/services`       | Comunicação com o backend (DIO)           |
| Repository  | `modules/*/repositories`   | Orquestra service + cache local (SQLite)  |
| Provider    | `modules/*/providers`      | Estado da UI (ChangeNotifier)             |
| View        | `modules/*/views`          | Telas e widgets                           |

## Recursos principais

- **Offline-First**: SQLite (`core/database`), sessão local (login offline) e
  cache de treinos; conclusões de exercício/treino persistidas por usuário.
- **Professor**: biblioteca de exercícios com CRUD (criar/editar/excluir) e
  descrição/execução; ao criar treino, **seleciona** exercícios da biblioteca e
  só informa séries/repetições/carga. Biblioteca pré-populada (seed no backend).
- **Aluno**: vídeo + descrição de execução; marcar/desmarcar exercício e treino
  com estado persistente.
- **Pausa de vídeo por aba**: `AlunoTabNotifier` (em `home/views/aluno_shell.dart`)
  é um `ValueNotifier<int>` injetado via `ChangeNotifierProvider`. `ExercicioCard`
  registra um listener e pausa o player ao sair da aba Treinos, salvando a posição
  atual (`inSeconds`); ao pressionar play novamente o vídeo retoma do mesmo ponto
  via `YoutubePlayerFlags.startAt`.
- **Chat IA (GIA)**: histórico de mensagens persistido localmente por usuário via
  `StorageService.salvarHistoricoChat` (SharedPreferences + JSON). O backend é
  stateless — cada POST `/chat/coach` recebe apenas a mensagem atual + contexto
  de treino montado no servidor.
- **Tema**: `app_theme.dart` re-exporta `app_colors.dart`; as telas importam
  somente `app_theme.dart` e acessam `AppColors` sem import adicional.
