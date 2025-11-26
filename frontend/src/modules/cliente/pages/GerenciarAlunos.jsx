import { useState, useEffect } from "react";
import { usuarioAPI, authAPI } from "../../../services/api";
import styles from "./styles.module.css";

export default function GerenciarAlunos() {
  const [modalOpen, setModalOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const [nome, setNome] = useState("");
  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");

  const [alunos, setAlunos] = useState([]);

  useEffect(() => {
    carregarAlunos();
  }, []);

  async function carregarAlunos() {
    try {
      setLoading(true);
      const usuarios = await usuarioAPI.listar();

      const alunosFiltrados = usuarios.filter((u) => u.tipo === "ALUNO");
      setAlunos(alunosFiltrados);
    } catch (err) {
      setError("Erro ao carregar alunos: " + err.message);
    } finally {
      setLoading(false);
    }
  }

  function abrirModal() {
    setModalOpen(true);
    setError("");
  }

  function fecharModal() {
    setModalOpen(false);
    setNome("");
    setEmail("");
    setSenha("");
    setError("");
  }

  async function cadastrarAluno(e) {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      await authAPI.cadastrar(nome, email, senha, "ALUNO");

      await carregarAlunos();

      setError("");
      fecharModal();

      const successMsg = document.createElement("div");
      successMsg.style.cssText =
        "position: fixed; top: 20px; right: 20px; background: green; color: white; padding: 1rem; border-radius: 4px; z-index: 9999;";
      successMsg.textContent = "Aluno cadastrado com sucesso!";
      document.body.appendChild(successMsg);
      setTimeout(() => {
        document.body.removeChild(successMsg);
      }, 3000);
    } catch (err) {
      setError("Erro ao cadastrar aluno: " + err.message);
    } finally {
      setLoading(false);
    }
  }

  async function removerAluno(idUsuario) {
    if (!window.confirm("Tem certeza que deseja remover este aluno?")) {
      return;
    }

    try {
      setLoading(true);
      await usuarioAPI.remover(idUsuario);
      await carregarAlunos();
    } catch (err) {
      setError("Erro ao remover aluno: " + err.message);
    } finally {
      setLoading(false);
    }
  }
  return (
    <div className={styles.listAlunos}>
      <div className={styles.topoLista}>
        <h2>Alunos Cadastrados</h2>

        <button
          className={styles.btnEstilizado}
          onClick={abrirModal}
          disabled={loading}
        >
          Adicionar Aluno
        </button>
      </div>

      <p>Gerencie os alunos da sua academia</p>

      {error && (
        <div style={{ color: "red", marginBottom: "1rem" }}>{error}</div>
      )}

      {loading && alunos.length === 0 ? (
        <p>Carregando alunos...</p>
      ) : (
        <table>
          <thead>
            <tr>
              <th>Nome</th>
              <th>Email</th>
              <th>Ações</th>
            </tr>
          </thead>
          <tbody>
            {alunos.length === 0 ? (
              <tr>
                <td colSpan="3" style={{ textAlign: "center" }}>
                  Nenhum aluno cadastrado
                </td>
              </tr>
            ) : (
              alunos.map((aluno) => (
                <tr key={aluno.idUsuario}>
                  <td>{aluno.nome}</td>
                  <td>{aluno.email}</td>
                  <td>
                    <button
                      onClick={() => removerAluno(aluno.idUsuario)}
                      disabled={loading}
                      style={{
                        background: "red",
                        color: "white",
                        border: "none",
                        padding: "0.5rem 1rem",
                        cursor: loading ? "not-allowed" : "pointer",
                      }}
                    >
                      Remover
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      )}

      {modalOpen && (
        <div className={styles.modalOverlay}>
          <div className={styles.modalBox}>
            <h2>Novo Aluno</h2>

            {error && (
              <div style={{ color: "red", marginBottom: "1rem" }}>{error}</div>
            )}
            <form onSubmit={cadastrarAluno}>
              <input
                type="text"
                placeholder="Nome"
                value={nome}
                onChange={(e) => setNome(e.target.value)}
                required
                disabled={loading}
              />

              <input
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                disabled={loading}
              />

              <input
                type="password"
                placeholder="Senha"
                value={senha}
                onChange={(e) => setSenha(e.target.value)}
                required
                disabled={loading}
              />

              <div className={styles.modalButtons}>
                <button
                  type="submit"
                  className={styles.modalButton}
                  disabled={loading}
                >
                  {loading ? "Cadastrando..." : "Cadastrar"}
                </button>
                <button
                  type="button"
                  className={styles.modalButton}
                  onClick={fecharModal}
                  disabled={loading}
                >
                  Cancelar
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
