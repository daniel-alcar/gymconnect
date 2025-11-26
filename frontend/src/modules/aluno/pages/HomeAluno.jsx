import { useState, useEffect } from "react";
import { useAuth } from "../../../context/AuthContext";
import { cronogramaAPI, cronogramaExercicioAPI } from "../../../services/api";
import styles from "./styles.module.css";

export default function HomeAluno() {
  const { user, logout } = useAuth();
  const [mostrarTreino, setMostrarTreino] = useState(false);
  const [treinos, setTreinos] = useState([]);
  const [treinoSelecionado, setTreinoSelecionado] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    if (user?.idUsuario) {
      carregarTreinos();
    }
  }, [user]);

  async function carregarTreinos() {
    try {
      setLoading(true);
      setError("");

      console.log("Buscando treinos para aluno ID:", user.idUsuario);

      const exercicios = await cronogramaExercicioAPI.listarPorAluno(
        user.idUsuario
      );

      console.log("Exercícios recebidos:", exercicios);

      if (!exercicios || exercicios.length === 0) {
        setTreinos([]);
        return;
      }

      const treinosPorDia = exercicios.reduce((acc, ex) => {
        if (!ex || !ex.exercicio) {
          console.warn("Exercício sem dados completos:", ex);
          return acc;
        }

        let dia = "Sem dia";
        if (ex.diaSemana) {
          if (typeof ex.diaSemana === "string") {
            dia = ex.diaSemana;
          } else if (ex.diaSemana.name) {
            dia = ex.diaSemana.name;
          } else {
            dia = String(ex.diaSemana);
          }
        }

        if (!acc[dia]) {
          acc[dia] = [];
        }

        acc[dia].push({
          id: ex.idCronogramaExercicio,
          nome: ex.exercicio.nome || "Exercício sem nome",
          series: ex.serie,
          repeticoes: ex.repeticao,
          carga: ex.carga,
          videoUrl: ex.exercicio.linkYoutube,
        });

        return acc;
      }, {});

      console.log("Treinos agrupados por dia:", treinosPorDia);

      const treinosLista = Object.keys(treinosPorDia).map((dia) => ({
        id: `treino-${dia}`,
        diaSemana: dia,
        exercicios: treinosPorDia[dia],
        nomeTreino: `Treino - ${dia}`,
      }));

      console.log("Lista final de treinos:", treinosLista);

      setTreinos(treinosLista);
    } catch (err) {
      console.error("Erro completo ao carregar treinos:", err);
      setError("Erro ao carregar treinos: " + err.message);
    } finally {
      setLoading(false);
    }
  }

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
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          marginBottom: "2rem",
        }}
      >
        <div>
          <h1>Olá, {user?.nome || "Aluno"}</h1>
          <p>Seus treinos personalizados estão prontos</p>
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

      <span>Cronograma semanal</span>

      {error && (
        <div style={{ color: "red", marginBottom: "1rem" }}>{error}</div>
      )}

      {loading ? (
        <p>Carregando treinos...</p>
      ) : treinos.length === 0 ? (
        <p>Nenhum treino cadastrado ainda.</p>
      ) : (
        <div>
          <ul className={styles.treinosSemanais}>
            <div className={styles.diaTreino}>
              <li>
                {treinos.map((t) => (
                  <div key={t.id} className={styles.treinoCard}>
                    <h3>{t.diaSemana}</h3>
                    <p>{t.exercicios.length} exercício(s)</p>
                    <button onClick={() => abrirModelTreino(t)}>Treinar</button>
                  </div>
                ))}
              </li>
            </div>
          </ul>
        </div>
      )}

      {mostrarTreino && treinoSelecionado && (
        <div className={styles.modalOverlay}>
          <div className={styles.modalContainer}>
            <h2>{treinoSelecionado.nomeTreino}</h2>
            <p>{treinoSelecionado.diaSemana}</p>

            {treinoSelecionado.exercicios?.map((ex, index) => (
              <div key={index} className={styles.exercicioCard}>
                <h3>{ex.nome}</h3>
                <p>
                  {ex.series && `${ex.series} séries`}
                  {ex.repeticoes && ` × ${ex.repeticoes} repetições`}
                  {ex.carga && ` • Carga: ${ex.carga}kg`}
                </p>

                {ex.videoUrl && (
                  <button onClick={() => window.open(ex.videoUrl, "_blank")}>
                    Ver Vídeo
                  </button>
                )}
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
