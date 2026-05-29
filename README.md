# GymConnect

## Documentação da API (frontend / Flutter)

Toda a referência de rotas, JSON de entrada/saída e autenticação JWT está em:

**[backend/API.md](backend/API.md)**

- **URL base da API:** `http://localhost:8080`
- **Login:** `POST /auth/login` → header `Authorization: Bearer <token>` nas demais rotas

---

# Como rodar o projeto com Docker Compose

Siga os passos abaixo para configurar e executar o projeto GymConnect utilizando Docker Compose.
---

## 1. Preparação do ambiente

Caso você já tenha baixado alguma versão anterior do sistema:

**Exclua completamente todas as pastas antigas do projeto.**

Agora siga os passos:

1. Crie uma nova pasta vazia para armazenar o projeto.  
2. Abra o CMD do Windows como administrador.

---

## 2. Executando os comandos

Execute os comandos abaixo na ordem indicada.

### 1. Acesse a pasta criada

```bash
cd "CAMINHO-DA-SUA-PASTA"
```

### 2. Clone o repositório

```bash
git clone https://github.com/daniel-alcar/gymconnect.git gymconnect
```

### 3. Entre no diretório do projeto

```bash
cd gymconnect
```

### 4. Faça o build dos containers

```bash
docker compose build
```

Observação: Esta etapa pode demorar.  
Quando finalizar, devem aparecer mensagens como:

```
gymconnect-backend Built
gymconnect-frontend Built
```

### 5. Inicie os serviços

```bash
docker compose up -d
```

---

## 3. Acessando o sistema

Abra o navegador e acesse:

```
http://localhost
```

O sistema estará disponível.
