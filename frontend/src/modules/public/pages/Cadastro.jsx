import styles from "./styles.module.css";
import Title from "./Title.jsx";
export default function App() {
  return (
    <div className={styles.container}>
      <Title />
      <form className={styles.formCard}>
        <div>
          <h2>Criar Conta</h2>
          <p>Preencha os dados para criar sua conta</p>
        </div>
        <div>
          <label htmlFor="tipo">Tipo de conta</label>
          <select id="tipo">
            <option value="cliente">Academia</option>
            <option value="aluno">Aluno</option>
          </select>
        </div>
        <div>
          <label htmlFor="nome">Nome</label>
          <input type="text" id="nome" />
        </div>
        <div>
          <label htmlFor="email">Email</label>
          <input type="email" id="email" />
        </div>
        <div>
          <label htmlFor="senha">Senha</label>
          <input type="password" id="senha" />
        </div>
        <button className={styles.btnEstilizado}>Criar Conta</button>
      </form>
    </div>
  );
}
