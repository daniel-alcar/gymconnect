# GymConnect

Aplicativo mobile de treinos personalizados, desenvolvido como Projeto Integrador.

Um **professor (Cliente)** monta cronogramas de treino para seus **alunos**, que acompanham os exercícios, assistem aos vídeos e marcam cada série como concluída — tudo pelo app Android.

---

## Visão geral

| Camada | Tecnologia |
|--------|-----------|
| Mobile (Android) | Flutter 3.19+ · Dart 3.3+ · Provider · Dio · GoRouter · Material 3 |
| Backend (API REST) | Java 21 · Spring Boot 3 · Spring Security · JWT |
| Banco de dados | MySQL 8 |
| IA (Chat) | Google Gemini 2.5 Flash |
| Infraestrutura | Docker · Docker Compose |

---

## Estrutura do repositório

```
gymconnect/
├── backend/               # API Java (Spring Boot)
├── mobile/                # App Flutter (Android)
├── docs/
│   ├── COMO-TESTAR.md     # Guia detalhado de execução e testes
│   ├── API.md             # Documentação completa das rotas REST
│   ├── ARQUITETURA.md     # Arquitetura do app mobile por módulo
│   ├── QA-TESTES.md       # Roteiro de testes de QA
│   └── QA-TESTES.xlsx     # Planilha de resultados de QA
├── docker-compose.yml
├── .env.example           # Modelo de variáveis de ambiente
└── README.md
```

> A pasta `old/mobile/` contém a versão anterior do app e pode ser ignorada.

---

## Início rápido (Docker)

> Pré-requisito: [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado e rodando em modo **Linux Containers**.

```powershell
# 1. Clone e entre na branch correta
git clone https://github.com/daniel-alcar/gymconnect.git
cd gymconnect
git checkout ryan

# 2. Crie o .env a partir do modelo
Copy-Item .env.example .env
# Edite o .env e preencha keigemini= com sua chave do Google AI Studio

# 3. Suba MySQL + backend
docker compose up -d --build

# 4. Aguarde a API inicializar (~30s) e confirme
docker compose logs -f backend   # aguarde "Started GymconnectApplication"
```

A API estará disponível em `http://localhost:8080`.

---

## Início rápido (sem Docker)

> Pré-requisitos: JDK 21 instalado e MySQL 8 rodando localmente.

```powershell
# Crie o banco
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS gymconnect;"

# Suba a API (perfil prod com variáveis)
cd backend
$env:SPRING_PROFILES_ACTIVE="prod"
$env:MYSQL_HOST="localhost"
$env:MYSQL_DATABASE="gymconnect"
$env:MYSQL_USER="root"
$env:MYSQL_PASSWORD="sua_senha"
$env:keigemini="sua_chave_gemini"
.\mvnw.cmd spring-boot:run
```

---

## App mobile

```bash
cd mobile
flutter pub get
flutter run        # emulador Android ou celular via USB
```

Para celular físico via USB, encaminhe a porta antes:
```bash
adb reverse tcp:8080 tcp:8080
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

---

## Documentação

- **[docs/COMO-TESTAR.md](docs/COMO-TESTAR.md)** — guia completo: pré-requisitos, variáveis, backend, Flutter, fluxos de teste e troubleshooting
- **[docs/API.md](docs/API.md)** — referência completa das rotas REST (payloads, autenticação JWT, códigos de retorno)
- **[docs/ARQUITETURA.md](docs/ARQUITETURA.md)** — arquitetura do app mobile por módulo
- **[docs/QA-TESTES.md](docs/QA-TESTES.md)** — roteiro de testes de QA
