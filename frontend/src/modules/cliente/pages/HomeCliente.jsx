import { useState } from "react";
import styles from "./styles.module.css";

export default function HomeCliente() {
  const [modalOpen, setModalOpen] = useState(false);

  const [nome, setNome] = useState("");
  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");

  const [alunos, setAlunos] = useState([]);

  function abrirModal() {
    setModalOpen(true);
  }

  function fecharModal() {
    setModalOpen(false);
  }

  function cadastrarAluno(e) {
    e.preventDefault();

    const novoAluno = {
      id: Date.now(),
      nome,
      email,
    };

    setAlunos([...alunos, novoAluno]);

    // limpa campos
    setNome("");
    setEmail("");
    setSenha("");

    fecharModal();
  }

  return (
    <div className={styles.container}>
      <h1>ACADEMIA</h1>
      <p>Gerencie seus alunos e treinos</p>

      <div className={styles.btnGroup}>
        <button>Gerenciar Alunos</button>
        <button>Gerenciar treinos</button>
      </div>

      <div className={styles.listAlunos}>
        <div className={styles.topoLista}>
          <h2>Alunos Cadastrados</h2>

          <button className={styles.btnEstilizado} onClick={abrirModal}>
            Adicionar Aluno
          </button>
        </div>

        <p>Gerencie os alunos da sua academia</p>

        <table>
          <thead>
            <tr>
              <th>Nome</th>
              <th>Email</th>
            </tr>
          </thead>
          <thead>
            {alunos.map((aluno) => (
              <tr key={aluno.id}>
                <td>{aluno.nome}</td>
                <td>{aluno.email}</td>
              </tr>
            ))}
          </thead>
        </table>
      </div>

      {modalOpen && (
        <div className={styles.modalOverlay}>
          <div className={styles.modalBox}>
            <h2>Novo Aluno</h2>

            <form onSubmit={cadastrarAluno}>
              <input
                type="text"
                placeholder="Nome"
                value={nome}
                onChange={(e) => setNome(e.target.value)}
                required
              />

              <input
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />

              <input
                type="password"
                placeholder="Senha"
                value={senha}
                onChange={(e) => setSenha(e.target.value)}
                required
              />

              <div className={styles.modalButtons}>
                <button type="submit" className={styles.modalButton}>
                  Cadastrar
                </button>
                <button
                  type="button"
                  className={styles.modalButton}
                  onClick={fecharModal}
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
