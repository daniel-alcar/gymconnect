import { useState } from "react";
import { useAuth } from "../../../context/AuthContext";
import styles from "./styles.module.css";
import GerenciarAlunos from "./GerenciarAlunos";
import GerenciarTreinos from "./GerenciarTreinos";

export default function HomeCliente() {
  const { user, logout } = useAuth();
  const [mostrarAlunos, setMostrarAlunos] = useState(false);
  const [mostrarTreinos, setMostrarTreinos] = useState(false);

  function abrirAlunos() {
    setMostrarAlunos(true);
    setMostrarTreinos(false);
  }

  function abrirTreinos() {
    setMostrarTreinos(true);
    setMostrarAlunos(false);
  }

  return (
    <div className={styles.container}>
      <div className={styles.navbar}>
        <h1>GymConnect - Gerencia</h1>
        <button
          onClick={logout}
          style={{
            padding: "0.5rem 1rem",
            background: "#dc3545",
            color: "white",
            border: "none",
            borderRadius: "4px",
            cursor: "pointer",
          }}
        >
          Sair
        </button>
      </div>
      <div className={styles.title}>
        <p>Olá, {user?.nome || "Cliente"} - Gerencie seus alunos e treinos</p>
      </div>
      <div className={styles.btnGroup}>
        <button onClick={abrirAlunos}>Gerenciar Alunos</button>
        <button onClick={abrirTreinos}>Gerenciar Treinos</button>
      </div>

      {mostrarAlunos && <GerenciarAlunos />}

      {mostrarTreinos && <GerenciarTreinos />}
    </div>
  );
}
