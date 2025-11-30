import { useState, useEffect } from "react";
import { useAuth } from "../../../context/AuthContext";
import { cronogramaExercicioAPI } from "../../../services/api";
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

      const exercicios = await cronogramaExercicioAPI.listarPorAluno(
        user.idUsuario
      );

      if (!exercicios || exercicios.length === 0) {
        setTreinos([]);
        return;
      }

      const treinosPorDia = exercicios.reduce((acc, ex) => {
        if (!ex || !ex.exercicio) return acc;

        let dia = "Sem dia";
        if (ex.diaSemana) {
          if (typeof ex.diaSemana === "string") dia = ex.diaSemana;
          else if (ex.diaSemana.name) dia = ex.diaSemana.name;
          else dia = String(ex.diaSemana);
        }

        if (!acc[dia]) acc[dia] = [];

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

      const treinosLista = Object.keys(treinosPorDia).map((dia) => ({
        id: `treino-${dia}`,
        diaSemana: dia,
        exercicios: treinosPorDia[dia],
        nomeTreino: `Treino - ${dia}`,
      }));

      setTreinos(treinosLista);
    } catch (err) {
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
        <h2>Olá, {user?.nome || "Aluno"}</h2>
        <p>Seus treinos personalizados estão prontos</p>
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
        <ul className={styles.diasTreinos}>
          {treinos.map((t) => (
            <li key={t.id} className={styles.treinoCard}>
              <h3>{t.diaSemana}</h3>
              <p>{t.exercicios.length} exercício(s)</p>
              <button onClick={() => abrirModelTreino(t)}>Treinar</button>
            </li>
          ))}
        </ul>
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
