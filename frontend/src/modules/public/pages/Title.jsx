import styles from "./styles.module.css";

export default function Title() {
  return (
    <>
      <h1>Bem-vindo ao GymConnect</h1>
      <h2>Entre na sua conta ou crie uma nova</h2>
      <div className={styles.buttonGroup}>
        <button>Login</button>
        <button>Cadastrar</button>
      </div>
    </>
  );
}
