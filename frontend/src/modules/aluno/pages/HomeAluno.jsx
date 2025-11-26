import { useState } from "react";
import styles from "./styles.module.css";

export default function HomeAluno() {
  const [mostrarTreino, setMostrarTreino] = useState(false);
  const [treino, setTreino] = useState([]); // lista vinda do banco
  const [treinoSelecionado, setTreinoSelecionado] = useState(null);

  function abrirModelTreino(t) {
    setTreinoSelecionado(t);
    setMostrarTreino(true);
  }

  function fecharModal() {
    setMostrarTreino(false);
    setTreinoSelecionado(null);
  }

  return (
    <div>
      <h1>Olá, ~Aluno</h1>
      <p>Seus treinos personalizados estão prontos</p>
      <span>Cronograma semanal</span>

      <div>
        <ul className={styles.treinosSemanais}>
          <div className={styles.diaTreino}>
            <li>
              {treino.map((t) => (
                <div key={t.id} className={styles.treinoCard}>
                  <h3>{t.diaSemana}</h3>
                  <p>{t.exercicio}</p>
                  <button onClick={() => abrirModelTreino(t)}>Treinar</button>
                </div>
              ))}
            </li>
          </div>
        </ul>
      </div>

      {mostrarTreino && treinoSelecionado && (
        <div className={styles.modalOverlay}>
          <div className={styles.modalContainer}>
            <h2>{treinoSelecionado.nomeTreino}</h2>
            <p>{treinoSelecionado.diaSemana}</p>

            {treinoSelecionado.exercicios?.map((ex, index) => (
              <div key={index} className={styles.exercicioCard}>
                <h3>{ex.nome}</h3>
                <p>
                  {ex.series} séries × {ex.repeticoes} repetições • Carga:{" "}
                  {ex.carga}kg
                </p>

                <button onClick={() => window.open(ex.videoUrl, "_blank")}>
                  Ver Vídeo
                </button>
              </div>
            ))}

            <button onClick={fecharModal} className={styles.btnFechar}>
              Fechar
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
