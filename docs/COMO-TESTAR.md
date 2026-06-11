# GymConnect — Guia completo para testar

Explica, do zero, como configurar o ambiente, subir o backend e executar o app Flutter — cobrindo Docker, dispositivo físico, emulador e cenários de teste.

> Esta branch (`ryan`) contém a solução mobile:
> - **`backend/`** → API Java (Spring Boot) + MySQL
> - **`mobile/`** → app Flutter (Android)
>
> O projeto web original em React não faz parte desta branch.

---

## Sumário

1. [Pré-requisitos](#1-pré-requisitos)
2. [Clonar e configurar o .env](#2-clonar-e-configurar-o-env)
3. [Backend com Docker (recomendado)](#3-backend-com-docker-recomendado)
4. [Backend sem Docker](#4-backend-sem-docker)
5. [App Flutter](#5-app-flutter)
6. [Fluxos de teste](#6-fluxos-de-teste)
7. [Testes automatizados](#7-testes-automatizados)
8. [Trocar de conta / reiniciar estado](#8-trocar-de-conta--reiniciar-estado)
9. [Troubleshooting](#9-troubleshooting)
10. [Stack técnica](#10-stack-técnica)

---

## 1. Pré-requisitos

| Ferramenta | Versão mínima | Observação |
|---|---|---|
| Git | qualquer | |
| Docker Desktop | 4.x | para a opção Docker; modo Linux Containers |
| Flutter SDK | 3.19.0 | [flutter.dev/get-started](https://docs.flutter.dev/get-started/install) |
| Android Studio | atual | SDK Android + emulador |
| JDK 21 | 21 | apenas para rodar o backend **sem** Docker |
| MySQL 8 | 8.0 | apenas para rodar o backend **sem** Docker |

**Confirme as instalações:**
```bash
git --version
flutter --version
flutter doctor       # resolva todos os itens [✗] antes de continuar
java -version        # precisa mostrar openjdk 21 (só se for usar sem Docker)
```

**Flutter no Windows — se `flutter` não for reconhecido:**
1. Localize onde está o SDK (ex.: `C:\flutter\bin`).
2. Pesquise "Variáveis de Ambiente" no Painel de Controle → Variáveis do sistema → **Path** → **Editar** → adicione o caminho `C:\flutter\bin`.
3. Feche e reabra todos os terminais.

---

## 2. Clonar e configurar o .env

```powershell
git clone https://github.com/daniel-alcar/gymconnect.git
cd gymconnect
git checkout ryan

# Crie o .env a partir do modelo
Copy-Item .env.example .env
notepad .env   # ou code .env
```

Edite o `.env` com os valores reais:

```dotenv
# Chave do Google AI Studio (Gemini) — gratuita em https://aistudio.google.com/app/apikey
keigemini=AIzaSuaChaveAqui

# Senha do usuário da aplicação no banco
MYSQL_PASSWORD=sua_senha_app

# Senha do root do MySQL
MYSQL_ROOT_PASSWORD=sua_senha_root

# JWT — pode deixar o padrão abaixo para desenvolvimento
JWT_SECRET=my-secret-key-change-in-production
```

> **Importante:** o `.env` está no `.gitignore` — nunca o commite.
> Sem `keigemini`, o app inteiro funciona normalmente; só o Chat IA retorna erro.

---

## 3. Backend com Docker (recomendado)

> Docker Desktop deve estar aberto em modo **Linux Containers**.

```powershell
# Sobe MySQL (porta 3307) + API (porta 8080)
docker compose up -d --build

# Acompanhe até ver: "Started GymconnectApplication in X seconds"
docker compose logs -f backend
```

A API estará em `http://localhost:8080`. As tabelas são criadas automaticamente.

**Comandos úteis:**

```powershell
docker compose ps                  # ver status dos containers
docker compose restart backend     # reiniciar só a API (mantém o banco)
docker compose down                # parar (preserva os dados)
docker compose down -v             # parar e apagar o volume do banco
```

**Testar se a API está respondendo:**
```bash
curl -X POST http://localhost:8080/auth/login \
     -H "Content-Type: application/json" \
     -d "{}"
# Qualquer resposta (mesmo 400/403) confirma que a API está no ar.
```

---

## 4. Backend sem Docker

### 4.1 Criar o banco

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS gymconnect CHARACTER SET utf8mb4;"
```

> No Windows, se `mysql` não for reconhecido, use o caminho completo:
> `"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"`

### 4.2 Iniciar a API

```powershell
cd backend

$env:SPRING_PROFILES_ACTIVE = "prod"
$env:MYSQL_HOST             = "localhost"
$env:MYSQL_PORT             = "3306"
$env:MYSQL_DATABASE         = "gymconnect"
$env:MYSQL_USER             = "root"
$env:MYSQL_PASSWORD         = "sua_senha_do_root"
$env:keigemini               = "sua_chave_gemini"
$env:JWT_SECRET             = "my-secret-key-change-in-production"

.\mvnw.cmd spring-boot:run
```

> **Linux / macOS:** substitua `$env:VAR="x"` por `export VAR=x` e use `./mvnw` no lugar de `.\mvnw.cmd`.

Aguarde a mensagem `Started GymconnectApplication in X seconds`. A API fica em `http://localhost:8080`. **Deixe esse terminal aberto.**

---

## 5. App Flutter

Em outro terminal (com o backend já rodando):

```bash
cd mobile
flutter pub get
flutter devices    # lista emuladores e dispositivos disponíveis
```

### 5.1 Emulador Android

Abra o Android Studio → **Device Manager** → inicie um AVD com API 26 ou superior.

```bash
flutter run
```

O emulador enxerga o host como `10.0.2.2`, então `http://10.0.2.2:8080` é o `localhost` do PC — o app já usa essa URL automaticamente.

### 5.2 Celular físico via USB

1. **Opções do desenvolvedor** no celular (toque 7× em "Número da versão" se precisar liberar).
2. Ative **Depuração USB**.
3. Conecte o cabo e autorize o computador na tela do celular.

```bash
adb reverse tcp:8080 tcp:8080        # encaminha a porta pelo cabo
flutter run
```

### 5.3 Celular físico via Wi-Fi

> PC e celular devem estar na mesma rede.

**Android 11+:**
```bash
# No celular: Opções do desenvolvedor → Depuração sem fio → Parear com código
adb pair <IP_CELULAR>:<PORTA_EMPARELHAMENTO>
adb connect <IP_CELULAR>:<PORTA_DEPURACAO>
adb reverse tcp:8080 tcp:8080
flutter run
```

**Android 10 ou inferior (com USB primeiro):**
```bash
adb tcpip 5555
adb connect <IP_CELULAR>:5555
# Desconecte o USB e encaminhe a porta
adb reverse tcp:8080 tcp:8080
flutter run
```

Descubra o IP do PC com `ipconfig` (Windows) ou `ifconfig` (Linux/macOS). Alternativamente, informe o IP direto:

```bash
flutter run --dart-define=API_BASE_URL=http://<IP_DO_PC>:8080
```

> Pode ser necessário liberar a porta 8080 no firewall do PC.

---

## 6. Fluxos de teste

### 6.1 Perfil Aluno

**Cadastro e login**
1. Na tela de login, toque em **Cadastrar**.
2. Preencha nome, e-mail, senha e selecione perfil **Aluno** → confirmar.
3. Faça login — em caso de erro, o app exibe "E-mail ou senha incorretos" com opção de ir para o cadastro.

**Visualizar e concluir treinos**
1. No dashboard, selecione o dia da semana.
2. Os exercícios do dia aparecem com séries, repetições e carga.
3. Toque na thumbnail do vídeo para abrir o player YouTube embutido.
4. Expanda **"Como executar"** para ver a descrição do exercício.
5. Toque em **Marcar como Feito** — o card muda para verde (Concluído).
6. Toque em **Desmarcar** para reverter.

**Chat IA**
1. Acesse o ícone de chat no menu inferior.
2. Envie uma pergunta sobre treino ou nutrição.
3. A resposta é gerada pelo Gemini 2.5 Flash.

**Perfil e logout**
1. Acesse a aba **Perfil** e confirme seus dados.
2. Toque em **Sair** — deve redirecionar para a tela de login.

### 6.2 Perfil Cliente (professor)

**Cadastro**
1. Cadastre-se com perfil **Cliente**.

**Gerenciar biblioteca de exercícios**
1. Acesse a aba **Exercícios**.
2. Crie um exercício: nome (obrigatório), link YouTube e descrição (opcionais).
3. Edite um exercício existente (ícone de lápis) → confirme que as alterações persistem.
4. Remova um exercício (ícone de lixeira) → confirme o diálogo e que some da lista.

**Criar treino para múltiplos dias**
1. Acesse a aba **Alunos** → selecione um aluno → **Criar Treino**.
2. Selecione o aluno e o primeiro dia da semana.
3. Adicione exercícios com séries, repetições e carga.
4. Toque em **Adicionar dia** para incluir Segunda, Terça, etc. — tudo na mesma tela.
5. Toque em **Salvar Treinos** — todos os dias são criados de uma vez.

**Editar vínculo de exercício**
1. Na lista de treinos de um aluno, toque em um exercício.
2. Altere dia, séries, repetições ou carga → salvar.
3. Confirme que a lista atualiza automaticamente (sem fechar e reabrir).

**Remover vínculo**
1. Na edição do vínculo, toque em **Remover**.
2. O exercício deve sumir da lista do aluno.

**Visualizar alunos**
1. Na aba **Alunos**, a lista mostra todos os alunos cadastrados.
2. Novos alunos aparecem automaticamente após auto-cadastro com perfil Aluno (sem ação do professor).

---

## 7. Testes automatizados

### Análise estática (Flutter)

```bash
cd mobile
flutter analyze
```

Zero erros é o esperado. Warnings de deprecação em versões abaixo de 3.33 podem aparecer.

### Testes unitários e de widget (Flutter)

```bash
cd mobile
flutter test
```

### Testes de integração (Flutter)

```bash
# Se houver arquivos em integration_test/
cd mobile
flutter test integration_test/
```

### Testes do backend (Maven)

```bash
cd backend
.\mvnw.cmd test         # Windows
./mvnw test             # Linux / macOS
```

Os testes de integração do Spring Boot exigem o banco disponível (Docker ou local).

---

## 8. Trocar de conta / reiniciar estado

| Ação | Como fazer |
|---|---|
| Recarregar código sem perder estado | `r` no terminal (hot reload) |
| Reiniciar o app do zero | `R` no terminal ou botão de hot restart no VS Code/Android Studio |
| Fazer logout real | Aba **Perfil** → **Sair** (remove o token JWT) |
| Limpar banco de dados | `docker compose down -v && docker compose up -d --build` |
| Limpar cache Flutter | `flutter clean && flutter pub get` |

---

## 9. Troubleshooting

| Sintoma | Causa provável | Solução |
|---|---|---|
| `flutter: command not found` | Flutter fora do PATH | Adicione `C:\flutter\bin` ao PATH e reabra o terminal |
| App trava na tela de login | Backend não iniciou | `docker compose logs backend` — verifique se apareceu "Started GymconnectApplication" |
| `Connection refused` no celular físico | Porta não encaminhada | Execute `adb reverse tcp:8080 tcp:8080` |
| Banco não conecta no Docker | Porta 3307 já ocupada | Mude `"3307:3306"` no `docker-compose.yml` para outra porta livre |
| `MYSQL_ROOT_PASSWORD not set` | `.env` não foi criado | Copie `.env.example` para `.env` e preencha as variáveis |
| Chat IA retorna 403/502 | Chave Gemini inválida ou ausente | Verifique `keigemini=` no `.env` (formato `AIza...`) e reinicie o backend |
| `flutter pub get` falha | Pub cache corrompido | `flutter clean && flutter pub get` |
| Emulador não aparece em `flutter devices` | AVD não iniciado | Android Studio → Device Manager → Start |
| `adb: device not found` | USB debug desabilitado ou cabo | Ative "Depuração USB"; tente outro cabo USB |
| `java` não reconhecido | JDK fora do PATH | Reinstale o JDK 21 marcando "Add to PATH" e reabra o terminal |
| `mysql` não reconhecido | MySQL fora do PATH | Use o caminho completo `"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"` |
| Docker trava em "engine starting" | Problema do Docker Desktop | Use a opção sem Docker (seção 4) |

---

## 10. Stack técnica

| Componente | Tecnologia |
|---|---|
| App Android | Flutter 3.19+ / Dart 3.3+ |
| Gerenciamento de estado | Provider |
| Navegação | GoRouter |
| HTTP client | Dio |
| UI | Material 3 |
| Backend | Java 21 + Spring Boot 3 |
| Autenticação | JWT (Spring Security) |
| Banco de dados | MySQL 8 / JPA (Hibernate) |
| IA | Google Gemini 2.5 Flash |
| Infraestrutura | Docker + Docker Compose |
