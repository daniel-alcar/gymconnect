import { useState, useEffect } from "react";
import {
  usuarioAPI,
  exercicioAPI,
  cronogramaAPI,
  cronogramaExercicioAPI,
} from "../../../services/api";
import styles from "./styles.module.css";

export default function GerenciarTreinos() {
  const [modalOpen, setModalOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [alunos, setAlunos] = useState([]);
  const [exerciciosDisponiveis, setExerciciosDisponiveis] = useState([]);

  const [aluno, setAluno] = useState("");
  const [diaSemana, setDiaSemana] = useState("");
  const [tituloTreino, setTituloTreino] = useState("");

  const [exercicios, setExercicios] = useState([
    { nome: "", series: "", repeticoes: "", carga: "", video: "" },
  ]);

  useEffect(() => {
    carregarDados();
  }, []);

  async function carregarDados() {
    try {
      setLoading(true);
      const [usuarios, exercicios] = await Promise.all([
        usuarioAPI.listar(),
        exercicioAPI.listar(),
      ]);

      const alunosFiltrados = usuarios.filter((u) => u.tipo === "ALUNO");
      setAlunos(alunosFiltrados);
      setExerciciosDisponiveis(exercicios);
    } catch (err) {
      setError("Erro ao carregar dados: " + err.message);
    } finally {
      setLoading(false);
    }
  }

  function abrirModal() {
    setModalOpen(true);
    setError("");
    setAluno("");
    setDiaSemana("");
    setTituloTreino("");
    setExercicios([
      { nome: "", series: "", repeticoes: "", carga: "", video: "" },
    ]);
  }

  function fecharModal() {
    setModalOpen(false);
    setError("");
  }

  function adicionarExercicio() {
    setExercicios([
      ...exercicios,
      { nome: "", series: "", repeticoes: "", carga: "", video: "" },
    ]);
  }

  function removerExercicio(index) {
    const novaLista = exercicios.filter((_, i) => i !== index);
    setExercicios(novaLista);
  }

  function atualizarExercicio(index, campo, valor) {
    const novaLista = [...exercicios];
    novaLista[index][campo] = valor;
    setExercicios(novaLista);
  }

  async function cadastrarTreino(e) {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const exerciciosIds = [];
      for (const ex of exercicios) {
        let exercicioExistente = exerciciosDisponiveis.find(
          (e) => e.nome.toLowerCase() === ex.nome.toLowerCase()
        );

        if (!exercicioExistente) {
          const novoExercicio = await exercicioAPI.cadastrar(
            ex.nome,
            ex.video || "https://youtube.com"
          );
          exerciciosIds.push(novoExercicio.idExercicio);

          setExerciciosDisponiveis([...exerciciosDisponiveis, novoExercicio]);
        } else {
          exerciciosIds.push(exercicioExistente.idExercicio);
        }
      }

      const cronograma = await cronogramaAPI.cadastrar({
        aluno: { idUsuario: parseInt(aluno) },
        diasTotais: null,
      });

      for (let i = 0; i < exercicios.length; i++) {
        const ex = exercicios[i];
        const diaSemanaEnum = mapearDiaSemana(diaSemana);

        await cronogramaExercicioAPI.cadastrar({
          cronograma: { idCronograma: cronograma.idCronograma },
          exercicio: { idExercicio: exerciciosIds[i] },
          diaSemana: diaSemanaEnum,
          serie: parseInt(ex.series) || null,
          repeticao: parseInt(ex.repeticoes) || null,
          carga: parseInt(ex.carga) || null,
        });
      }

      await carregarDados();
      fecharModal();
    } catch (err) {
      setError("Erro ao cadastrar treino: " + err.message);
    } finally {
      setLoading(false);
    }
  }

  function mapearDiaSemana(dia) {
    const mapeamento = {
      SEGUNDA: "Segunda",
      TERÇA: "Terca",
      QUARTA: "Quarta",
      QUINTA: "Quinta",
      SEXTA: "Sexta",
      SABADO: "Sabado",
      DOMINGO: "Domingo",
    };
    return mapeamento[dia] || dia;
  }

  return (
    <div className={styles.listAlunos}>
      <div className={styles.topoLista}>
        <h2>Treinos Cadastrados</h2>
        <button
          className={styles.btnEstilizado}
          onClick={abrirModal}
          disabled={loading}
        >
          Criar Treino
        </button>
      </div>

      {error && (
        <div style={{ color: "red", marginBottom: "1rem" }}>{error}</div>
      )}

      {modalOpen && (
        <div className={styles.modalOverlay}>
          <div className={styles.modalBoxGrande}>
            <h2>Criar Novo Treino</h2>
            <p>Defina os exercícios e detalhes do treino</p>

            {error && (
              <div style={{ color: "red", marginBottom: "1rem" }}>{error}</div>
            )}
            <form onSubmit={cadastrarTreino}>
              <div className={styles.alertaCampos}>
                Preencha todos os campos obrigatórios (*) para criar o treino
              </div>

              <div>
                <div>
                  <label>Aluno *</label>
                  <select
                    value={aluno}
                    onChange={(e) => setAluno(e.target.value)}
                    required
                    disabled={loading || alunos.length === 0}
                  >
                    <option value="">Selecione...</option>
                    {alunos.map((a) => (
                      <option key={a.idUsuario} value={a.idUsuario}>
                        {a.nome}
                      </option>
                    ))}
                  </select>
                </div>

                <div className={styles.col}>
                  <label>Dia da Semana *</label>
                  <select
                    value={diaSemana}
                    onChange={(e) => setDiaSemana(e.target.value)}
                    required
                    disabled={loading}
                  >
                    <option value="">Selecione...</option>
                    <option value="SEGUNDA">Segunda-feira</option>
                    <option value="TERÇA">Terça-feira</option>
                    <option value="QUARTA">Quarta-feira</option>
                    <option value="QUINTA">Quinta-feira</option>
                    <option value="SEXTA">Sexta-feira</option>
                    <option value="SABADO">Sábado</option>
                    <option value="DOMINGO">Domingo</option>
                  </select>
                </div>
              </div>

              <label>Título do Treino *</label>
              <input
                type="text"
                placeholder="Ex: Treino de Peito e Tríceps"
                value={tituloTreino}
                onChange={(e) => setTituloTreino(e.target.value)}
                required
                disabled={loading}
              />

              <div className={styles.rowHeader}>
                <label>Exercícios *</label>
                <button
                  type="button"
                  className={styles.btnAdd}
                  onClick={adicionarExercicio}
                >
                  + Adicionar Exercício
                </button>
              </div>

              {exercicios.map((ex, index) => (
                <div key={index} className={styles.exercicioBox}>
                  <h3>Exercício {index + 1}</h3>

                  <div>
                    <div>
                      <label>Nome do Exercício *</label>
                      <input
                        type="text"
                        placeholder="Ex: Supino Reto"
                        value={ex.nome}
                        onChange={(e) =>
                          atualizarExercicio(index, "nome", e.target.value)
                        }
                        required
                        disabled={loading}
                      />
                    </div>

                    <div>
                      <label>Séries *</label>
                      <input
                        type="number"
                        placeholder="Ex: 4"
                        min={0}
                        step={1}
                        value={ex.series}
                        onChange={(e) =>
                          atualizarExercicio(index, "series", e.target.value)
                        }
                        required
                        disabled={loading}
                      />
                    </div>
                  </div>

                  <div>
                    <div>
                      <label>Repetições *</label>
                      <input
                        type="number"
                        placeholder="Ex: 10"
                        min={0}
                        step={1}
                        value={ex.repeticoes}
                        onChange={(e) =>
                          atualizarExercicio(
                            index,
                            "repeticoes",
                            e.target.value
                          )
                        }
                        required
                        disabled={loading}
                      />
                    </div>

                    <div>
                      <label>Carga (opcional)</label>
                      <input
                        type="number"
                        placeholder="Ex: 20"
                        min={0}
                        step={1}
                        value={ex.carga}
                        onChange={(e) =>
                          atualizarExercicio(index, "carga", e.target.value)
                        }
                        disabled={loading}
                      />
                    </div>
                  </div>

                  <label>URL do Vídeo (opcional)</label>
                  <input
                    type="text"
                    placeholder="https://youtube.com/..."
                    value={ex.video}
                    onChange={(e) =>
                      atualizarExercicio(index, "video", e.target.value)
                    }
                    disabled={loading}
                  />

                  <button
                    type="button"
                    className={styles.btnRemover}
                    onClick={() => removerExercicio(index)}
                    disabled={loading}
                  >
                    🗑 Remover
                  </button>
                </div>
              ))}

              <div className={styles.modalButtons}>
                <button
                  type="submit"
                  className={styles.modalButton}
                  disabled={loading}
                >
                  {loading ? "Salvando..." : "Salvar Treino"}
                </button>

                <button
                  type="button"
                  className={styles.modalButtonCancelar}
                  onClick={fecharModal}
                  disabled={loading}
                >
                  Cancelar
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
