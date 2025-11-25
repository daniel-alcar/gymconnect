# 🩺 Sistema Web de Usuários

## 🧩 Tecnologias Utilizadas

- **Backend:** Spring Boot `5.6.3`
- **Linguagem:** Java SDK `21`
- **Frontend:** React `22`
- **Banco de Dados:** MySQL

## 📋 Descrição do Projeto

O projeto foi desenvolvido com o objetivo de demonstrar a integração entre **Spring Boot**, **React** e **MySQL**.

O sistema possui duas interfaces principais:

- **Tela de Login:** permite que usuários cadastrados acessem o sistema.
- **Tela de Cadastro:** possibilita o registro de novos usuários no banco de dados.

## ⚙️ Funcionalidades

- Cadastro de novos usuários
- Login de usuários existentes
- Integração completa entre frontend e backend
- Persistência de dados no MySQL

## 🚀 Objetivo

O objetivo do projeto é servir como base para aplicações web modernas utilizando **Java**, **Spring Boot**, **React** e **MySQL**, com foco em simplicidade e boas práticas de desenvolvimento.

---

src/modules/cliente/
pages/
DashboardCliente.jsx
GerenciarAlunos.jsx
CriarAluno.jsx
GerenciarTreinos.jsx
CriarTreino.jsx
components/
TabelaAlunos.jsx
FormTreino.jsx
CardAluno.jsx

src/modules/aluno/
pages/
HomeAluno.jsx
CronogramaSemanal.jsx
TreinoDoDia.jsx
components/
CardTreino.jsx
ListaDias.jsx

    src/modules/public/

pages/
Home.jsx
Login.jsx
Cadastro.jsx
components/
FormLogin.jsx

components/
ui/ → Botões, inputs, modal, loader etc.
layout/ → Sidebar, Navbar, Footer

routes/
PublicRoutes.jsx
PrivateAlunoRoutes.jsx
PrivateClienteRoutes.jsx
AppRoutes.jsx
