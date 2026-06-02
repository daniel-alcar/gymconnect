# 🏋️ GymConnect — Guia completo para testar

Este guia explica, do zero, como rodar o **backend (API Java)** e o **app mobile (Flutter/Android)**.

> A solução mobile usa duas pastas do repositório:
> - **`backend/`** → API Java (Spring Boot) + MySQL.
> - **`mobile/`** → app Flutter (Android).
>
> A pasta `frontend/` (React) é o projeto web original, mantido **apenas como referência** — não precisa rodar.

---

## ✅ Pré-requisitos

Instale antes de começar:

| Ferramenta | Versão | Link |
|---|---|---|
| **Git** | qualquer | https://git-scm.com/downloads |
| **JDK 21** | 21 | https://adoptium.net/temurin/releases/?version=21 (marque "Set JAVA_HOME" e "Add to PATH") |
| **MySQL 8** | 8.x | https://dev.mysql.com/downloads/installer/ (porta 3306; anote a senha do root) |
| **Flutter SDK** | 3.19+ | https://docs.flutter.dev/get-started/install |
| **Android Studio** | atual | para o emulador e SDK Android (ou use um celular físico) |
| Docker Desktop *(opcional)* | atual | só se for usar o caminho com Docker |

Confirme no terminal:
```bash
git --version
java -version      # precisa mostrar 21
flutter --version
flutter doctor      # resolva os itens marcados com [x]
```

---

## 1️⃣ Obter o código

```bash
git clone https://github.com/daniel-alcar/gymconnect.git
cd gymconnect
git checkout ryan
```

---

## 2️⃣ Configurar a chave do Gemini (para o Chat IA)

A tela **Chat IA** usa o Gemini. Crie uma chave gratuita em
**https://aistudio.google.com/app/apikey** (formato `AIza...`).

Copie o modelo de variáveis e preencha:

```bash
# Windows (PowerShell)
Copy-Item .env.example .env

# Linux / macOS
cp .env.example .env
```

Abra o `.env` e coloque sua chave em `keigemini=`:
```
keigemini=AIzaSuaChaveAqui
```
> O `.env` está no `.gitignore` — sua chave não vai para o Git. Sem a chave, todo o resto funciona; só o Chat IA retorna erro.

---

## 3️⃣ Subir o backend (escolha A **ou** B)

### 🅰️ Opção A — Sem Docker (recomendada)

**1. Crie o banco de dados** (vai pedir a senha do root do MySQL):
```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS teste_gymconnect;"
```
> As tabelas são criadas automaticamente pelo backend (Hibernate) na 1ª execução.
> Se `mysql` não for reconhecido, use o caminho completo, ex.:
> `"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p -e "CREATE DATABASE IF NOT EXISTS teste_gymconnect;"`

**2. Suba a API.** O perfil padrão usa usuário `root` e senha `123456`.

- **Se a senha do seu root é `123456`** (Windows PowerShell):
  ```powershell
  cd backend
  $env:keigemini="SUA_CHAVE_DO_GEMINI"
  .\mvnw.cmd spring-boot:run
  ```
- **Se a senha do root é OUTRA**, rode no perfil `prod` informando as credenciais:
  ```powershell
  cd backend
  $env:SPRING_PROFILES_ACTIVE="prod"
  $env:MYSQL_HOST="localhost"
  $env:MYSQL_DATABASE="teste_gymconnect"
  $env:MYSQL_USER="root"
  $env:MYSQL_PASSWORD="SUA_SENHA_DO_ROOT"
  $env:JWT_SECRET="my-secret-key"
  $env:keigemini="SUA_CHAVE_DO_GEMINI"
  .\mvnw.cmd spring-boot:run
  ```
  > Linux/macOS: troque `$env:VAR="x"` por `export VAR=x` e use `./mvnw` no lugar de `.\mvnw.cmd`.

**3. Aguarde** aparecer no log: **`Started GymconnectApplication in X seconds`**.
A API está em `http://localhost:8080`. **Deixe esse terminal aberto.**

### 🅱️ Opção B — Com Docker

Com o `.env` preenchido (passo 2) e o Docker Desktop rodando (modo **Linux Containers**):
```bash
docker-compose up -d --build
docker-compose logs -f backend     # aguarde "Started GymconnectApplication"
```
Sobe MySQL + backend + frontend. API em `http://localhost:8080`.

**Testar se a API respondeu:**
```bash
curl -X POST http://localhost:8080/auth/login -H "Content-Type: application/json" -d "{}"
```
Qualquer resposta (mesmo erro 400/403) significa que a API está no ar. ✅

---

## 4️⃣ Rodar o app mobile (Flutter)

Em **outro terminal** (deixe o backend rodando):
```bash
cd mobile
flutter pub get
flutter devices      # confira se há emulador ou celular conectado
```

### 📱 Opção 1 — Emulador Android
Não precisa configurar URL (já usa `http://10.0.2.2:8080` = localhost do PC):
```bash
flutter run
```

### 📱 Opção 2 — Celular físico (via cabo USB) — recomendado
1. No celular: **Configurações → Sobre → Informações de software →** toque 7x em "Número da versão" para liberar o **Modo desenvolvedor**, depois ative a **Depuração USB**.
2. Conecte o cabo e autorize o computador.
3. Encaminhe a porta pelo cabo e rode apontando para `localhost`:
   ```bash
   adb reverse tcp:8080 tcp:8080
   flutter run --dart-define=API_BASE_URL=http://localhost:8080
   ```

### 📱 Opção 3 — Celular físico (via Wi‑Fi)
PC e celular na mesma rede. Descubra o IP do PC (`ipconfig` / `ifconfig`) e rode:
```bash
flutter run --dart-define=API_BASE_URL=http://IP_DO_PC:8080
```
> Pode ser necessário liberar a porta 8080 no firewall do PC.

---

## 5️⃣ Testar os fluxos

### Como ALUNO
1. **Cadastrar** → escolha o perfil **Aluno** → login automático.
2. **Treinos**: veja o treino do dia, assista ao vídeo (embutido), informe o peso e toque em **Marcar como Feito**.
3. **Perfil**: preencha data de nascimento, altura e objetivo → **Salvar**.
4. **AI Chat**: pergunte sobre seu treino, ex.: *"Quantas séries de supino faço?"*.

### Como CLIENTE (academia/professor)
1. **Cadastrar** → escolha o perfil **Cliente**.
2. **Exercícios**: cadastre exercícios na biblioteca (nome + link do YouTube).
3. **Treinos → Criar Treino**: escolha um aluno, o dia da semana e adicione exercícios (séries, repetições, carga, vídeo) → **Salvar**.
4. **Alunos**: veja e gerencie os alunos cadastrados.

> Dica: crie **uma conta Aluno** antes, para ela aparecer no dropdown de "Criar Treino".

---

## 🛠️ Problemas comuns

| Problema | Solução |
|---|---|
| App abre mas dá **"erro ao conectar ao servidor"** | Backend não está no ar **ou** URL errada. Confira o terminal do backend e, no celular físico, use `adb reverse` + `--dart-define=...localhost:8080`. |
| `mysql` não reconhecido | Use o caminho completo do `mysql.exe` ou adicione a pasta `bin` do MySQL ao PATH. |
| `java` não reconhecido / versão errada | Reinstale o JDK 21 marcando "Add to PATH" e reabra o terminal. |
| Chat IA retorna **502** | A `keigemini` não está definida ou é inválida. Gere uma nova chave (formato `AIza...`) e ajuste o `.env` (ou a variável de ambiente, no modo sem Docker). |
| Build do Android falha por **SDK** | Rode `flutter doctor` e instale o Android SDK indicado. |
| Docker trava em "engine starting" | Use a **Opção A (sem Docker)**. |

---

## 📦 Tecnologias

**Mobile:** Flutter · Dart · Provider · Dio · GoRouter · SharedPreferences · youtube_player_flutter · Material 3
**Backend:** Java 21 · Spring Boot · MySQL 8 · JWT · Gemini
