# GymConnect

Plataforma mobile de treinos personalizados para academias, desenvolvida como Projeto Integrador do Curso Superior de Tecnologia em Análise e Desenvolvimento de Sistemas — SENAI FATESG, 2026.

Um **professor (Instrutor)** monta cronogramas semanais com exercícios e vídeos para seus **alunos**, que acompanham os treinos, assistem aos vídeos e marcam cada exercício como concluído — tudo pelo app Android, inclusive sem internet.

---

## Visão geral

| Camada | Tecnologia |
|--------|-----------|
| Mobile (Android) | Flutter 3.19+ · Dart 3.3+ · Provider · Dio · GoRouter · Material 3 |
| Backend (API REST) | Java 21 · Spring Boot 3.5 · Spring Security · JWT |
| Banco de dados | MySQL 8 · JPA/Hibernate |
| IA (Chat GIA) | Google Gemini 2.5 Flash |
| Infraestrutura | Docker · Docker Compose |
| Documentação API | SpringDoc OpenAPI (Swagger UI) |

---

## Funcionalidades

### Perfil Aluno
- Cadastro e login com e-mail e senha
- Dashboard com acesso rápido a treinos, perfil e IA
- Cronograma semanal agrupado por dia da semana
- Player de vídeo YouTube embutido (thumbnail + play em 1 clique)
- Vídeo pausa automaticamente ao trocar de aba e retoma do mesmo ponto
- Descrição de execução ("Como executar") expansível por exercício
- Marcar/desmarcar exercício como feito (persiste entre sessões)
- Concluir treino do dia (persiste entre sessões)
- Perfil pessoal com foto (câmera ou galeria), altura, data de nascimento e objetivo
- Chat com assistente virtual **GIA** (Google Gemini 2.5 Flash)
- Acesso **Offline-First**: treinos e sessão persistem localmente via SQLite

### Perfil Instrutor (Professor)
- Biblioteca de exercícios: criar, editar e excluir (com nome, link YouTube e descrição)
- Criar cronograma semanal para qualquer aluno — múltiplos dias na mesma tela
- Editar vínculo de treino (dia, séries, repetições, carga)
- Gerenciar lista de alunos cadastrados (visualizar e remover)

---

## Estrutura do repositório

```
gymconnect/
├── backend/                   # API Java (Spring Boot)
│   ├── src/
│   └── Dockerfile
├── mobile/                    # App Flutter (Android)
│   ├── lib/
│   │   ├── main.dart
│   │   └── app/
│   │       ├── core/          # Infra: DIO, SQLite, SharedPrefs, tema, erros
│   │       ├── shared/        # Widgets, utils e formatadores reutilizáveis
│   │       ├── routes/        # GoRouter com rotas protegidas por JWT
│   │       └── modules/       # auth · treinos · cliente · chat · perfil · home
│   └── assets/
├── docs/
│   ├── API.md                 # Referência completa das rotas REST
│   ├── ARQUITETURA.md         # Arquitetura do app mobile por módulo
│   ├── COMO-TESTAR.md         # Guia de setup e execução
│   ├── QA-TESTES.md           # Roteiro detalhado de QA
│   └── QA-TESTES.xlsx         # Planilha de resultados de QA
├── docker-compose.yml
├── .env.example               # Modelo de variáveis de ambiente
└── README.md
```

> A pasta `old/` contém a versão anterior do app e pode ser ignorada.

---

## Início rápido com Docker (recomendado)

> **Pré-requisito:** [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado e rodando em modo **Linux Containers**.

```powershell
# 1. Clone e entre na branch correta
git clone https://github.com/daniel-alcar/gymconnect.git
cd gymconnect
git checkout ryan

# 2. Crie o .env a partir do modelo
Copy-Item .env.example .env
# Edite .env: preencha keigemini= com sua chave do Google AI Studio
# (gratuita em https://aistudio.google.com/app/apikey)

# 3. Suba MySQL + backend
docker compose up -d --build

# 4. Aguarde a API inicializar (~30 s)
docker compose logs -f backend   # aguarde "Started GymconnectApplication"
```

A API ficará disponível em `http://localhost:8080`.  
Documentação interativa: `http://localhost:8080/swagger-ui.html`

### Comandos úteis do Docker

```powershell
docker compose ps                  # status dos containers
docker compose restart backend     # reiniciar só a API (mantém o banco)
docker compose down                # parar (preserva os dados)
docker compose down -v             # parar e apagar o volume do banco
```

---

## Início rápido sem Docker

> **Pré-requisitos:** JDK 21 e MySQL 8 instalados e rodando localmente.

```powershell
# Crie o banco
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS gymconnect CHARACTER SET utf8mb4;"

# Configure as variáveis e inicie a API
cd backend
$env:SPRING_PROFILES_ACTIVE = "prod"
$env:MYSQL_HOST             = "localhost"
$env:MYSQL_PORT             = "3306"
$env:MYSQL_DATABASE         = "gymconnect"
$env:MYSQL_USER             = "root"
$env:MYSQL_PASSWORD         = "sua_senha"
$env:keigemini               = "sua_chave_gemini"
$env:JWT_SECRET             = "my-secret-key-change-in-production"
.\mvnw.cmd spring-boot:run
```

---

## App Flutter (Android)

Com o backend já rodando, em outro terminal:

```bash
cd mobile
flutter pub get
flutter run        # emulador Android ou celular via USB
```

### Celular físico via USB

```bash
adb reverse tcp:8080 tcp:8080   # encaminha a porta pelo cabo
flutter run
```

### Celular físico via Wi-Fi (Android 11+)

```bash
# No celular: Opções do desenvolvedor → Depuração sem fio → Parear com código
adb pair <IP_CELULAR>:<PORTA_EMPARELHAMENTO>
adb connect <IP_CELULAR>:<PORTA_DEPURACAO>
adb reverse tcp:8080 tcp:8080
flutter run
```

---

## Variáveis de ambiente (`.env`)

| Variável | Descrição | Exemplo |
|---|---|---|
| `keigemini` | Chave da Google Gemini API | `AIzaSy...` |
| `MYSQL_PASSWORD` | Senha do usuário da aplicação | `senha_app` |
| `MYSQL_ROOT_PASSWORD` | Senha do root do MySQL | `senha_root` |
| `JWT_SECRET` | Segredo para assinar os tokens JWT | `my-secret-key` |

> O arquivo `.env` está no `.gitignore` — **nunca o commite**.  
> Sem `keigemini`, o app funciona normalmente; apenas o Chat GIA retorna erro.

---

## Testes

### Análise estática Flutter

```bash
cd mobile
flutter analyze
```

### Testes unitários Flutter

```bash
cd mobile
flutter test
```

### Testes do backend (Maven)

```bash
cd backend
.\mvnw.cmd test       # Windows
./mvnw test           # Linux / macOS
```

---

## Arquitetura

O app Flutter segue a arquitetura em camadas por módulo:

```
Entity (models) → Service (HTTP/Dio) → Repository (cache + API) → Provider (estado) → View (UI)
```

- **Offline-First**: SQLite local via `sqflite`; treinos e sessão disponíveis sem internet
- **Autenticação**: JWT stateless; interceptor no Dio renova/expira a sessão automaticamente
- **Provider pattern**: `ChangeNotifier` + `MultiProvider` para estado global; `AlunoTabNotifier` para estado local de aba

Veja [`docs/ARQUITETURA.md`](docs/ARQUITETURA.md) para detalhes completos.

---

## Documentação

| Arquivo | Conteúdo |
|---|---|
| [`docs/API.md`](docs/API.md) | Referência completa das rotas REST (payloads, auth JWT, códigos HTTP) |
| [`docs/ARQUITETURA.md`](docs/ARQUITETURA.md) | Arquitetura do app Flutter por módulo e camadas |
| [`docs/COMO-TESTAR.md`](docs/COMO-TESTAR.md) | Guia completo: pré-requisitos, Docker, Flutter, fluxos e troubleshooting |
| [`docs/QA-TESTES.md`](docs/QA-TESTES.md) | Roteiro de QA com casos de teste por categoria |
| [`docs/QA-TESTES.xlsx`](docs/QA-TESTES.xlsx) | Planilha de resultados (Pendente / Passou / Falhou / Bloqueado / N/A) |

---

## Troubleshooting rápido

| Sintoma | Solução |
|---|---|
| App trava na splash | Backend não iniciou — `docker compose logs backend` |
| `Connection refused` no celular | `adb reverse tcp:8080 tcp:8080` |
| Chat GIA retorna erro | Verifique `keigemini=` no `.env` e reinicie o backend |
| `flutter pub get` falha | `flutter clean && flutter pub get` |
| Emulador não aparece | Android Studio → Device Manager → Start |

Troubleshooting completo em [`docs/COMO-TESTAR.md`](docs/COMO-TESTAR.md).

---

## Equipe

Stefane Pires Lima · Daniel Alves Carvalho · Francisco Airton N. Filho · Ryan da Silva Doriguetto  
**SENAI FATESG** — ADS 5 · Goiânia, 2026
