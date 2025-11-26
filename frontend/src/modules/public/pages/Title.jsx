import styles from "./styles.module.css";
import { useNavigate } from "react-router-dom";

export default function Title() {
  const navigate = useNavigate();

  return (
    <>
      <h1>Bem-vindo ao GymConnect</h1>
      <h2>Entre na sua conta ou crie uma nova</h2>
      <div className={styles.buttonGroup}>
        <button onClick={() => navigate("/login")}>Login</button>
        <button onClick={() => navigate("/cadastro")}>Cadastrar</button>
      </div>
    </>
  );
}
