# Docker Compose - GymConnect

Este projeto está configurado para rodar com Docker Compose, facilitando o desenvolvimento e deploy.

## Pré-requisitos

- Docker Desktop instalado e rodando
- Docker Compose (geralmente vem com Docker Desktop)

## Configuração

1. **Copie o arquivo de exemplo de variáveis de ambiente:**
   ```bash
   cp .env.example .env
   ```

2. **Edite o arquivo `.env` com suas configurações** (opcional, os valores padrão funcionam)

## Como usar

### Iniciar todos os serviços

```bash
docker-compose up -d
```

Isso irá:
- Criar e iniciar o MySQL
- Buildar e iniciar o backend Spring Boot
- Buildar e iniciar o frontend React (com Nginx)

### Ver logs

```bash
# Todos os serviços
docker-compose logs -f

# Apenas backend
docker-compose logs -f backend

# Apenas frontend
docker-compose logs -f frontend

# Apenas MySQL
docker-compose logs -f mysql
```

### Parar os serviços

```bash
docker-compose down
```

### Parar e remover volumes (apaga dados do banco)

```bash
docker-compose down -v
```

### Rebuild dos containers

```bash
# Rebuild forçado
docker-compose build --no-cache

# Rebuild e restart
docker-compose up -d --build
```

## Acessos

- **Frontend**: http://localhost
- **Backend API**: http://localhost:8080
- **MySQL**: localhost:3306

## Estrutura

```
gymconnect/
├── docker-compose.yml          # Orquestração dos serviços
├── .env                        # Variáveis de ambiente (criar a partir de .env.example)
├── backend/
│   ├── Dockerfile              # Build do backend Spring Boot
│   └── .dockerignore
└── frontend/
    ├── Dockerfile              # Build do frontend React
    ├── nginx.conf              # Configuração do Nginx
    └── .dockerignore
```

## Variáveis de Ambiente

As principais variáveis que podem ser configuradas no arquivo `.env`:

- `MYSQL_ROOT_PASSWORD`: Senha root do MySQL
- `MYSQL_DATABASE`: Nome do banco de dados
- `MYSQL_USER`: Usuário do MySQL
- `MYSQL_PASSWORD`: Senha do usuário MySQL
- `JWT_SECRET`: Chave secreta para JWT (IMPORTANTE: mude em produção!)
- `SPRING_PROFILES_ACTIVE`: Perfil do Spring (prod, dev, etc.)

## Troubleshooting

### Porta já em uso

Se as portas 80, 8080 ou 3306 estiverem em uso, você pode alterar no `docker-compose.yml`:

```yaml
ports:
  - "8081:8080"  # Muda porta externa para 8081
```

### Limpar tudo e começar do zero

```bash
docker-compose down -v
docker system prune -a
docker-compose up -d --build
```

### Verificar se os containers estão rodando

```bash
docker-compose ps
```

### Acessar o MySQL

```bash
docker-compose exec mysql mysql -u root -p
```

### Ver logs de erro

```bash
docker-compose logs backend | grep ERROR
docker-compose logs frontend | grep ERROR
```

## Desenvolvimento

Para desenvolvimento local sem Docker, você ainda pode usar:

- Backend: `cd backend && mvn spring-boot:run`
- Frontend: `cd frontend && npm run dev`

O Docker Compose é mais útil para:
- Testes de integração
- Deploy em produção
- Ambientes consistentes entre desenvolvedores

