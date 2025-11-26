import { useState } from "react";
import styles from "./styles.module.css";
import GerenciarAlunos from "./GerenciarAlunos";
import GerenciarTreinos from "./GerenciarTreinos";

export default function HomeCliente() {
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
      <h1>ACADEMIA</h1>
      <p>Gerencie seus alunos e treinos</p>

      <div className={styles.btnGroup}>
        <button onClick={abrirAlunos}>Gerenciar Alunos</button>
        <button onClick={abrirTreinos}>Gerenciar Treinos</button>
      </div>

      {mostrarAlunos && <GerenciarAlunos />}

      {mostrarTreinos && <GerenciarTreinos />}
    </div>
  );
}
