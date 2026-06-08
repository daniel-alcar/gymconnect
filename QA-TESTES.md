# GymConnect — Roteiro de Testes de QA (foco em erros graves)

Objetivo: encontrar **falhas críticas** — crash do app, logout indevido, perda de
dados, vazamento de permissão, e mau comportamento offline. As categorias abaixo
cobrem os pontos onde o sistema já apresentou problemas sérios.

> Legenda de severidade:
> 🔴 Crítico (crash, logout indevido, perda/corrupção de dados, falha de segurança)
> 🟠 Alto (funcionalidade quebrada) · 🟡 Médio (UX/validação)

Perfis usados nos testes:
- **PROF** = conta professor/academia (CLIENTE)
- **ALUNO** = conta aluno

---

## 1. Autenticação e Sessão 🔴

| # | Cenário | Passos | Resultado esperado |
|---|---------|--------|--------------------|
| 1.1 | Login válido | Logar com e-mail/senha corretos (PROF e ALUNO) | Entra no perfil correto |
| 1.2 | Login inválido | Senha errada | Mensagem de erro clara, **continua na tela de login** (sem crash) |
| 1.3 | Campos vazios | Logar sem e-mail/senha | Validação no formulário, não chama a API |
| 1.4 | **Sessão persiste** | Logar, fechar o app (matar de vez), reabrir | **Continua logado**, sem pedir login de novo |
| 1.5 | **Login offline** | Logado, ativar modo avião, reabrir o app | **Continua logado** (modo offline), NÃO cai no login |
| 1.6 | Logout | Sair pelo menu | Volta ao login; reabrir o app **não** restaura a sessão |
| 1.7 | Token expirado/ inválido | (se possível) adulterar/expirar o token e fazer uma ação | Desloga **somente** nesse caso (401/403 real) com mensagem |
| 1.8 | Cadastro + autologin | Criar conta nova | Cadastra e já entra autenticado |
| 1.9 | Cadastro e-mail duplicado | Cadastrar com e-mail já existente | Mensagem amigável, sem crash |
| 1.10 | Troca de perfil | Logar como ALUNO, sair, logar como PROF | Cada um vê a navbar/telas do seu perfil |

**Regra de ouro:** o app só pode deslogar sozinho em **401/403 real de token**.
Qualquer outro erro (rede, 404, 409, 500) **não** pode deslogar.

---

## 2. Permissões por perfil (segurança) 🔴

| # | Cenário | Resultado esperado |
|---|---------|--------------------|
| 2.1 | ALUNO não acessa telas de PROF | Aluno não vê abas de Exercícios/Alunos/Criar treino |
| 2.2 | ALUNO não cria/edita/exclui exercício | Mesmo via API: 403, **mas isso é só na API** — pelo app o aluno nem tem a tela |
| 2.3 | PROF executa ações de PROF | Criar/editar/excluir exercício, criar treino, gerenciar alunos funcionam |
| 2.4 | Ações com erro de servidor não deslogam | Forçar um 409/500 numa ação do PROF → mostra mensagem, **continua logado** |
| 2.5 | Dados de outro usuário | ALUNO só vê os próprios treinos; PROF só vê seus alunos |

---

## 3. Exercícios (biblioteca do professor) 🔴🟠

| # | Cenário | Resultado esperado |
|---|---------|--------------------|
| 3.1 | Criar exercício | Aparece na lista **imediatamente** (sem precisar recarregar) |
| 3.2 | Criar sem nome | Bloqueia com validação |
| 3.3 | Criar com link inválido/sem link | Não quebra; trata link opcional |
| 3.4 | Editar exercício | Abre com dados preenchidos; salva e reflete na lista |
| 3.5 | **Excluir exercício EM USO num treino** | Mensagem amigável "está em uso..."; **NÃO desloga, NÃO crash** |
| 3.6 | Excluir exercício **não usado** | Remove normalmente |
| 3.7 | Descrição longa (1000+ chars) e emojis/acentos | Salva e exibe sem corromper |
| 3.8 | Campo descrição vazio | Funciona (descrição é opcional) |
| 3.9 | Seed da biblioteca | Após subir o backend, exercícios de exemplo aparecem; não duplica os já existentes |
| 3.10 | Abrir Criar Treino e voltar (FAB) | **Sem crash de "multiple heroes / FAB tag"** |

---

## 4. Criar / editar treino (professor) 🟠

| # | Cenário | Resultado esperado |
|---|---------|--------------------|
| 4.1 | Criar treino selecionando exercício da lista | Salva e aparece para o aluno |
| 4.2 | Criar treino com biblioteca vazia | Mostra aviso pedindo cadastrar exercícios antes |
| 4.3 | Sem selecionar aluno / sem dia | Validação bloqueia |
| 4.4 | Vários exercícios no mesmo treino | Todos vinculados corretamente |
| 4.5 | Séries/reps/carga não numéricos ou negativos | Trata sem crash (ignora/valida) |
| 4.6 | Editar vínculo (carga/rep/dia) | Atualiza e reflete na visão do aluno |
| 4.7 | Excluir vínculo de treino | Remove só aquele item |
| 4.8 | Editar/excluir aparecem no menu (⋮) | Ambas as opções visíveis |

---

## 5. Treinos do aluno + conclusão 🔴🟠

| # | Cenário | Resultado esperado |
|---|---------|--------------------|
| 5.1 | Ver treinos do dia | Lista agrupada por dia, com séries/reps/carga |
| 5.2 | Vídeo do exercício | Thumbnail aparece; toca e reproduz |
| 5.3 | Descrição "Como executar" | Expande/recolhe e mostra o texto definido pelo PROF |
| 5.4 | Marcar exercício como feito | Vira "Concluído"; entra na Atividade Recente |
| 5.5 | **Conclusão persiste** | Marcar exercício/treino, **fechar e reabrir o app** → continua concluído |
| 5.6 | Desmarcar | "Desmarcar" volta para pendente; persiste após reabrir |
| 5.7 | Marcar com peso | Registra peso; com vírgula e ponto (1,5 / 1.5) |
| 5.8 | Concluir treino do dia | Vira selo "Treino concluído"; persiste |
| 5.9 | Conclusão é por usuário | Concluído do ALUNO A não aparece para o ALUNO B |

---

## 6. Offline-First (rede) 🔴

| # | Cenário | Resultado esperado |
|---|---------|--------------------|
| 6.1 | Abrir treinos online e depois offline | Treinos continuam visíveis (cache local) |
| 6.2 | Abrir app offline sem cache (1ª vez) | Mensagem amigável "offline e sem treinos salvos"; **sem crash/logout** |
| 6.3 | Backend desligado | Telas mostram erro com botão "Tentar novamente"; **sem logout** |
| 6.4 | Voltar a ficar online | "Tentar novamente"/refresh recarrega do servidor |
| 6.5 | Marcar feito offline | Trata o erro de rede sem deslogar (não consegue gravar no servidor) |
| 6.6 | Internet lenta / timeout | Mostra loading e depois erro tratável (sem travar a tela) |

---

## 7. Banco local / dados (SQLite + SharedPreferences) 🔴

| # | Cenário | Resultado esperado |
|---|---------|--------------------|
| 7.1 | 1ª execução (app recém-instalado) | Cria o banco local sem erro; login funciona |
| 7.2 | Limpar dados do app (Android) e reabrir | Recria tudo; pede login; sem crash |
| 7.3 | Reinstalar o app | Sem resíduo que quebre a criação do banco |
| 7.4 | Uso prolongado / muitos treinos | Cache não corrompe nem trava |

---

## 8. GIA (chat IA) 🟠

| # | Cenário | Resultado esperado |
|---|---------|--------------------|
| 8.1 | Enviar pergunta | Recebe resposta; tela inicial mostra a mascote |
| 8.2 | Mensagem vazia | Não envia |
| 8.3 | Offline / backend fora | Erro tratável, sem crash/logout |
| 8.4 | Mensagem muito longa / caracteres especiais | Sem quebra de layout |
| 8.5 | Enviar várias seguidas | Não duplica nem trava |

---

## 9. Perfil e foto 🟡🟠

| # | Cenário | Resultado esperado |
|---|---------|--------------------|
| 9.1 | Tirar foto (câmera) e escolher da galeria | Foto aparece; persiste após reabrir |
| 9.2 | Negar permissão de câmera | Mensagem amigável, sem crash |
| 9.3 | Foto é por usuário | Foto do A não aparece para o B |

---

## 10. UI / Tema / Navegação 🟡

| # | Cenário | Resultado esperado |
|---|---------|--------------------|
| 10.1 | Alternar tema claro/escuro | Tudo legível nos dois; mascote/ícones visíveis |
| 10.2 | Tema persiste | Reabrir mantém a preferência |
| 10.3 | Navbar (todas as abas) | Ícones do tamanho certo, sem sobreposição |
| 10.4 | Rotação / fontes grandes do sistema | Layout não estoura (overflow) |
| 10.5 | Botão "voltar" do Android | Navega corretamente, sem fechar o app sem querer |
| 10.6 | Abrir/fechar teclado em formulários | Campos não ficam escondidos; sem overflow |

---

## 11. Robustez de entrada (inputs maliciosos/extremos) 🟠

| # | Cenário | Resultado esperado |
|---|---------|--------------------|
| 11.1 | Textos enormes em nome/descrição | Trunca/aceita sem corromper |
| 11.2 | Emojis e acentuação em todos os campos | Salva e exibe corretamente |
| 11.3 | Números: negativos, zero, decimais, texto | Validados; não quebram a API |
| 11.4 | Espaços em branco / só espaços | Tratados como vazio onde aplicável |
| 11.5 | Toques repetidos rápidos (duplo clique no salvar) | Não cria duplicado; botão desabilita durante o envio |

---

## Checklist de "erros graves" que NUNCA podem acontecer
- [ ] App **deslogar** por qualquer erro que não seja 401/403 de token real.
- [ ] **Crash** (tela vermelha / app fecha) em qualquer fluxo.
- [ ] Ação destrutiva (excluir) que **derruba a sessão** ou apaga dado errado.
- [ ] Conclusão de treino/exercício **sumir** após reabrir o app.
- [ ] Aluno enxergar/alterar dados de **outro** usuário.
- [ ] App **inutilizável offline** (cair no login ou travar).
- [ ] Excluir item **em uso** quebrar o app em vez de avisar.

---

## 12. Testes Visuais / UI / UX 🟠🟡

Sempre repetir os checks visuais **nos dois temas (claro e escuro)** e **nos dois
perfis (PROF e ALUNO)**. Procurar por: texto cortado, elementos sobrepostos,
imagem invisível/esticada, contraste ruim, e estados (carregando/vazio/erro).

### 12.1 Identidade visual e imagens
| # | Cenário | Resultado esperado |
|---|---------|--------------------|
| 12.1.1 | Logo no topo (claro × escuro) | Versão certa em cada tema; nítida, sem distorção |
| 12.1.2 | Mascote da GIA (tela do chat) | **Visível e legível nos dois temas** (não some no claro) |
| 12.1.3 | Mascote da GIA na navbar | Mesmo tamanho dos outros ícones, **centralizada**, não minúscula |
| 12.1.4 | Ícone GIA no card do Dashboard | Proporcional, sem cortar |
| 12.1.5 | Thumbnails de vídeo (YouTube) | Carregam; placeholder enquanto carrega; fallback se falhar |
| 12.1.6 | Foto de perfil | Recorte circular correto, sem esticar/achatar |
| 12.1.7 | Ícones em geral | Cor adequada ao tema (sem ícone "sumido" por contraste) |

### 12.2 Tema claro/escuro (cada tela)
| # | Cenário | Resultado esperado |
|---|---------|--------------------|
| 12.2.1 | Alternar tema com o app aberto | Atualiza na hora, sem reiniciar |
| 12.2.2 | Texto sobre fundo | **Contraste suficiente** em todos os textos (nada cinza-sobre-cinza) |
| 12.2.3 | Campos de formulário | Label, hint, borda e erro legíveis nos dois temas |
| 12.2.4 | Cards e divisórias | Bordas/sombras visíveis sem "vazar" no fundo |
| 12.2.5 | Botões (primário/secundário/perigo) | Cores corretas; texto legível; estado desabilitado perceptível |
| 12.2.6 | SnackBars e diálogos | Fundo/texto legíveis; não somem no tema |

### 12.3 Layout e responsividade
| # | Cenário | Resultado esperado |
|---|---------|--------------------|
| 12.3.1 | Telas pequenas e grandes | Sem **overflow** (faixa listrada amarela/preta) |
| 12.3.2 | Fonte grande do sistema (acessibilidade) | Layout se adapta; texto não corta |
| 12.3.3 | Rotação (retrato/paisagem) | Não quebra nem perde estado |
| 12.3.4 | Teclado aberto | Campo em foco fica visível; nada coberto |
| 12.3.5 | Textos longos (nome/descrição/exercício) | Quebra ou "..." (ellipsis), sem estourar o card |
| 12.3.6 | Notch/recorte e barra de gestos | Conteúdo não fica sob o notch nem sob a navbar |
| 12.3.7 | Listas longas | Rolagem suave; sem cortar último item atrás da navbar/FAB |

### 12.4 Estados de tela (cada listagem)
| # | Cenário | Resultado esperado |
|---|---------|--------------------|
| 12.4.1 | Carregando | Spinner/skeleton centralizado, sem "pular" o layout |
| 12.4.2 | Vazio | Empty state com ícone + texto explicativo (treinos, exercícios, alunos, atividade, chat) |
| 12.4.3 | Erro | Mensagem clara + ação "Tentar novamente" |
| 12.4.4 | Pull-to-refresh | Indicador aparece e some corretamente |

### 12.5 Consistência e microinterações
| # | Cenário | Resultado esperado |
|---|---------|--------------------|
| 12.5.1 | Navbar (PROF e ALUNO) | Ícone selecionado destacado; rótulos não cortados |
| 12.5.2 | FAB | Não sobrepõe conteúdo importante; **sem crash de Hero ao navegar** |
| 12.5.3 | Menu ⋮ (editar/excluir) | Abre alinhado; opções legíveis no tema |
| 12.5.4 | Botão durante envio | Vira loading e **desabilita** (evita duplo toque) |
| 12.5.5 | Selo "Concluído" / "Desmarcar" | Cores e ícones corretos; alinhados |
| 12.5.6 | Espaçamentos/alinhamentos | Padrão consistente entre telas (margens, títulos) |

### 12.6 Varredura tela a tela (passar em todas, claro+escuro)
Inicial · Login · Cadastro · Dashboard · Treinos · Perfil · GIA · Configurações ·
(PROF) Exercícios · Criar/Editar Treino · Alunos.
Para cada uma: sem overflow, contraste ok, imagens ok, estados (load/vazio/erro)
ok, e nada cortado/atrás de barra do sistema.

> Dica: rodar `flutter run` e observar o console — avisos de **RenderFlex
> overflow** e exceções de **Hero/assets** aparecem lá mesmo quando o problema é
> pequeno na tela.

---

### Como reportar um bug (sugestão)
Inclua: perfil (PROF/ALUNO), passos numerados, resultado esperado x obtido,
print/vídeo, e — se possível — o **log do `flutter run`** (a parte do erro) e o
**status HTTP** retornado pelo backend. Isso acelera muito o diagnóstico.
