# Análise do Documento Acadêmico — GymConnect

> Revisão do documento "ADS5 Projeto de Software GymConnect.docx.pdf" comparado ao estado real do repositório.
>
> Data da análise: 14 de junho de 2026

---

## Pontos INCORRETOS

### 1. Firebase Cloud Messaging (FCM) — não implementado

**No documento:** A Ficha Técnica lista "Firebase Cloud Messaging (notificações push)" como dependência Flutter.

**Na realidade:** O arquivo `mobile/pubspec.yaml` não contém nenhuma dependência do Firebase. As dependências Flutter reais são:

| Pacote | Finalidade |
|--------|-----------|
| `provider` | Gerenciamento de estado |
| `dio` | HTTP client + interceptors JWT |
| `go_router` | Navegação declarativa com rotas protegidas |
| `shared_preferences` | Persistência local do JWT/sessão |
| `youtube_player_flutter` | Player de vídeo embutido |
| `intl` | Formatação de datas |
| `image_picker` | Foto de perfil (câmera/galeria) |
| `sqflite` + `path` | Banco local SQLite (Offline-First) |
| `connectivity_plus` | Detecção de conectividade de rede |

**Agravante:** A seção 3.3 do próprio documento lista "Notificações push" como *"Não Incluso (futuro)"*, criando uma contradição interna.

---

### 2. "Supabase" no Diagrama de Arquitetura — não existe no projeto

**No documento:** A Figura 2 (Diagrama de Arquitetura) exibe o componente "Supabase".

**Na realidade:** O projeto não utiliza Supabase. A persistência de dados é feita com:
- **Backend:** MySQL rodando via Docker, acessado pelo Spring Boot com JPA/Hibernate
- **Mobile:** SQLite local via `sqflite` (cache Offline-First por usuário)

---

### 3. "Painel Web Administrativo" no Diagrama — não existe no projeto

**No documento:** A Figura 2 mostra um componente "Painel Web Administrativo".

**Na realidade:** Não existe painel web. O Professor (role `CLIENTE` no backend) utiliza o mesmo aplicativo mobile que o Aluno, com telas exclusivas para:
- Criar/editar/excluir exercícios da biblioteca
- Criar treinos semanais por aluno
- Visualizar alunos cadastrados

---

### 4. Inconsistência interna no requisito de tempo de resposta

**Seção 3.2:** "tempo de resposta inferior a **2 segundos**"

**RNF01 (seção 5.2):** "carregar cronograma em menos de **5 segundos**"

São dois valores distintos para o mesmo tipo de requisito de performance. Precisam ser unificados.

---

## Pontos FALTANDO (implementados mas não documentados)

### 5. Nenhum Requisito Funcional para o assistente GIA / Chat IA

A seção 9.7 descreve a tela de chat com a GIA (integração Google Gemini API), que está completamente implementada — incluindo backend com persistência de histórico por usuário. No entanto, a seção 5.1 (Requisitos Funcionais) não possui nenhum RF correspondente a essa funcionalidade.

**Sugestão de RF a incluir:**
> "O aluno deve poder enviar perguntas ao assistente de inteligência artificial (GIA) e receber respostas contextualizadas sobre treinos, exercícios e nutrição."

---

### 6. Arquitetura Offline-First não documentada

O aplicativo implementa uma estratégia Offline-First completa:
- Cache de treinos e exercícios em **SQLite local** (`core/database/db_helper.dart`)
- Detecção de conectividade via `connectivity_plus` (`core/network/connectivity_service.dart`)
- **Login offline** — sessão persiste localmente, o aluno acessa o app sem internet
- Conclusões de exercícios/treinos persistidas localmente por usuário

Nenhuma dessas funcionalidades é mencionada no documento.

---

### 7. Google Gemini API não está na Ficha Técnica

O backend consome a API `https://generativelanguage.googleapis.com` em `GeminiGenerateContentClient.java`. A chave de API (`GEMINI_API_KEY`) é uma variável de ambiente **obrigatória** para o sistema funcionar. Não há menção ao Google Gemini ou à sua integração em nenhuma seção do documento.

---

### 8. springdoc-openapi / Swagger não está na Ficha Técnica

O backend expõe documentação interativa da API REST em `/swagger-ui.html` via a dependência `springdoc-openapi`. Essa dependência não aparece na lista de tecnologias do documento.

---

### 9. Dependências Flutter ausentes da Ficha Técnica

As seguintes bibliotecas estão em `pubspec.yaml`, são ativamente utilizadas, mas não aparecem no documento:

| Pacote | Uso no projeto |
|--------|---------------|
| `go_router` | Navegação com rotas protegidas por JWT |
| `sqflite` | Banco SQLite local (Offline-First) |
| `path` | Utilitário de caminhos para o SQLite |
| `connectivity_plus` | Verifica conectividade antes de requisições |
| `image_picker` | Seleção de foto de perfil |

---

### 10. Histórico de chat persistido por usuário

O chat da GIA persiste o histórico de mensagens tanto no backend (endpoint dedicado de histórico) quanto localmente no mobile. Essa funcionalidade implementada não aparece nas seções de requisitos ou arquitetura.

---

## O que está CORRETO

| Item | Verificação |
|------|-------------|
| Spring Boot 3.5.6 | ✓ confirmado em `pom.xml` |
| Java 21 | ✓ confirmado em `pom.xml` |
| MySQL como banco de dados backend | ✓ |
| JWT para autenticação | ✓ (`java-jwt` em `pom.xml`) |
| Flutter / Dart | ✓ |
| Papel "Professor" na interface | ✓ alinhado com o frontend |
| Descrição das telas (seções 9.1–9.7) | ✓ coerente com o app |
| Diagrama de casos de uso | ✓ em linhas gerais |
| Cronograma (entrega MVP mobile em junho) | ✓ |

---

## Sugestões de Melhoria

1. **Atualizar Figura 2 (Diagrama de Arquitetura):** Remover Supabase e Painel Web. Incluir SQLite mobile, Gemini API e camada Offline-First.

2. **Adicionar RF para o chat GIA** e RF explícito para "marcar exercício como feito" (ambos estão implementados mas não têm RF correspondente).

3. **Corrigir a Ficha Técnica:**
   - Remover: Firebase Cloud Messaging (não implementado)
   - Adicionar: Google Gemini API, `springdoc-openapi`
   - Corrigir: dependências Flutter conforme tabela acima

4. **Unificar requisito de tempo de resposta** (2s vs 5s) para um único valor consistente.

5. **Seção 3.3 — "Não Incluso":** Garantir que FCM não apareça em nenhuma lista de dependências enquanto não for implementado.

6. **Documentar a abordagem Offline-First** como diferencial arquitetural do projeto.
