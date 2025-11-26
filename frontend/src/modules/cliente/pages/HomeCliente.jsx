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
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "2rem" }}>
        <div>
          <h1>ACADEMIA</h1>
          <p>Olá, {user?.nome || "Cliente"} - Gerencie seus alunos e treinos</p>
        </div>
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

      <div className={styles.btnGroup}>
        <button onClick={abrirAlunos}>Gerenciar Alunos</button>
        <button onClick={abrirTreinos}>Gerenciar Treinos</button>
      </div>

      {mostrarAlunos && <GerenciarAlunos />}

      {mostrarTreinos && <GerenciarTreinos />}
    </div>
  );
}
