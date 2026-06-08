# GymConnect — Arquitetura por Módulo (E-V-R-S-C-P)

Esta é a versão do app **organizada por módulo**, seguindo a arquitetura em
camadas ensinada nas aulas (Entity / View / Repository / Service / Controller /
Provider). É funcionalmente idêntica à versão organizada por tipo — apenas a
disposição das pastas muda.

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
    │   ├── widgets/               # Componentes reutilizáveis (logo, campos, etc.)
    │   └── utils/                 # Helpers (datas, snackbar, validators)
    ├── routes/                    # app_router.dart + route_names.dart
    └── modules/
        ├── auth/                  # Login, cadastro, sessão (inclui login offline)
        │   ├── models/            #   usuario, tipo_usuario, login_response, session_model
        │   ├── services/          #   auth_service (backend)
        │   ├── repositories/      #   auth_repository, session_local_repository (SQLite)
        │   ├── providers/         #   auth_provider (estado)
        │   └── views/             #   login_screen, cadastro_screen
        ├── treinos/               # Treinos do aluno (Offline-First)
        │   ├── models/            #   cronograma(+exercicio/execucao), exercicio, dia_semana...
        │   ├── services/          #   treino_service, execucao_service, registro_service
        │   ├── repositories/      #   treino_repository, treino_cache_repository (SQLite)
        │   ├── providers/         #   treino_provider
        │   └── views/             #   treinos_screen + widgets
        ├── cliente/               # Perfil professor/academia (gestão)
        │   ├── services/          #   exercicio_service, gestao_service, usuario_service
        │   ├── repositories/      #   cliente_repository
        │   ├── providers/         #   cliente_provider
        │   └── views/             #   exercícios, criar/editar treino, alunos, shell
        ├── chat/                  # GIA (assistente IA)
        │   ├── models/ services/ repositories/ providers/ views/
        ├── perfil/                # Perfil do usuário (foto local, dados)
        │   └── models/ services/ repositories/ providers/ views/
        └── home/                  # Dashboard, navegação (shells), tema, atividades
            ├── models/            #   atividade
            ├── providers/         #   atividade_provider, theme_provider
            └── views/             #   dashboard, shells, splash, inicial, configurações
```

## Camadas (responsabilidade)

| Camada            | Onde                         | Responsabilidade                              |
|-------------------|------------------------------|-----------------------------------------------|
| Entity (Model)    | `modules/*/models`           | Dado puro + (de)serialização                  |
| Service           | `modules/*/services`         | Comunicação com o backend (via DIO)           |
| Repository        | `modules/*/repositories`     | Orquestra service + cache local (SQLite)      |
| Provider          | `modules/*/providers`        | Estado da UI (ChangeNotifier)                 |
| View              | `modules/*/views`            | Telas e widgets                               |

## Offline-First

- `core/database/db_helper.dart`: Singleton SQLite, DDL externo em
  `assets/sql/create_tables.sql` lido via `rootBundle`.
- `auth/repositories/session_local_repository.dart`: sessão local → login offline.
- `treinos/repositories/treino_cache_repository.dart`: cache dos treinos →
  treinos visíveis sem internet.
- `core/network/connectivity_service.dart`: decide entre backend e cache.

> Observação: a única diferença para a versão "por tipo" é a localização dos
> arquivos e os `import` (agora `package:gymconnect/app/...`). Nenhuma regra de
> negócio ou chamada de backend mudou.
