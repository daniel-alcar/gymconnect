# GymConnect — App Android (Flutter)

Aplicativo Android do **GymConnect**, migrado do frontend React/Vite para **Flutter/Dart**,
consumindo **exclusivamente** as APIs REST já existentes no backend Java (Spring Boot + MySQL + Gemini).

> O backend **não foi alterado**. Todo o trabalho está no app Flutter.

---

## 🧱 Arquitetura (Clean Architecture + SOLID)

```
lib/
├── main.dart                 # Composição de dependências + MaterialApp.router
├── core/
│   ├── constants/            # URL base da API, chaves de storage, timeouts
│   ├── errors/               # AppException (mensagens padronizadas)
│   └── theme/                # Tema Material 3
├── models/                   # Serialização espelhando o JSON do backend
├── services/                 # Camada HTTP (Dio) por domínio + DioClient + Storage
├── repositories/             # Orquestram services + regras de negócio do app
├── providers/                # Estado (ChangeNotifier): Auth, Treino, Perfil, Chat
├── routes/                   # GoRouter + rotas protegidas
├── screens/                  # Telas (1 a 7) + widgets específicos de cada tela
├── widgets/                  # Componentes reutilizáveis (logo, loading, empty...)
└── utils/                    # Validadores, snackbars, datas
```

**Fluxo de dados:** `Screen → Provider → Repository → Service → Dio → Backend`.

---

## 📱 Telas implementadas

| # | Tela | Endpoints consumidos |
|---|------|----------------------|
| 1 | Inicial (logo, Entrar/Cadastrar) | — |
| 2 | Login | `POST /auth/login`, `GET /auth/me` |
| 3 | Cadastro (Cliente/Aluno) | `POST /auth/cadastrar` + login automático |
| 4 | Dashboard (grade 2 colunas) | — |
| 5 | Treinos (vídeo embutido, peso, marcar feito) | `GET /cronograma/{idAluno}`, `POST /cronogramaexecucao/me`, `POST /registrodiario/me` |
| 6 | Perfil | `POST /perfil/me` |
| 7 | Chat IA (Gemini) | `POST /chat/coach` |

---

## 🔐 Segurança

- `AuthProvider` com controle de sessão e logout.
- JWT persistido em `SharedPreferences`.
- **Interceptor do Dio** injeta `Authorization: Bearer <token>` automaticamente.
- **Logout automático** em `401/403` (token inválido/expirado) via `onUnauthorized`.
- **Rotas protegidas** com `GoRouter.redirect` baseado no estado de autenticação.

---

## ▶️ Como executar (Android)

### Pré-requisitos
- Flutter SDK 3.19+ (`flutter --version`)
- Android Studio / SDK + um emulador Android **ou** dispositivo físico
- O **backend Java rodando** (porta `8080`)

### 1. Suba o backend
No projeto Java original:
```bash
cd backend
./mvnw spring-boot:run
# garanta a variável GEMINI_API_KEY configurada para o Chat IA
```

### 2. Configure a URL da API
O backend só libera CORS para `localhost`. No **emulador Android**, `localhost` do
aparelho é `10.0.2.2`, então o padrão já é:

```
http://10.0.2.2:8080
```
(definido em `lib/core/constants/app_constants.dart`)

- **Dispositivo físico:** rode passando o IP da sua máquina na mesma rede Wi‑Fi:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080
  ```

### 3. Instale dependências e rode
```bash
cd gymconnect_flutter
flutter pub get
flutter run            # com emulador/dispositivo conectado (flutter devices)
```

### 4. Gerar o APK
```bash
flutter build apk --release
# saída: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧪 Qualidade

```bash
flutter analyze   # 0 issues
flutter test      # teste de widget do logo
```

---

## 🛠️ Tecnologias

Flutter · Dart · Provider · Dio · GoRouter · SharedPreferences · youtube_player_flutter · intl · Material 3
