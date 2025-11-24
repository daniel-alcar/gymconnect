import styles from "./styles.module.css";
import Title from "./Title.jsx";

export default function Login() {
  return (
    <div className={styles.container}>
      <Title />
      <form>
        <div>
          <h2>Fazer Login</h2>
          <p>Entre com suas credenciais para acessar sua conta</p>
        </div>
        <div>
          <label htmlFor="email">Email</label>
          <input type="email" id="email" />
        </div>
        <div>
          <label htmlFor="senha">Senha</label>
          <input type="password" id="senha" />
        </div>
        <button className={styles.btnEstilizado}>Login</button>
      </form>
    </div>
  );
}
