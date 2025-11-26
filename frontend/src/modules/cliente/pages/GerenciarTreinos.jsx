import { useState } from "react";
import styles from "./styles.module.css";

export default function GerenciarTreinos() {
  const [modalOpen, setModalOpen] = useState(false);

  const [aluno, setAluno] = useState("");
  const [diaSemana, setDiaSemana] = useState("");
  const [tituloTreino, setTituloTreino] = useState("");

  const [exercicios, setExercicios] = useState([
    { nome: "", series: "", repeticoes: "", carga: "", video: "" },
  ]);

  function abrirModal() {
    setModalOpen(true);
  }

  function fecharModal() {
    setModalOpen(false);
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

  function cadastrarTreino(e) {
    e.preventDefault();

    const novoTreino = {
      id: Date.now(),
      aluno,
      diaSemana,
      tituloTreino,
      exercicios,
    };

    console.log("TREINO CADASTRADO:", novoTreino);

    fecharModal();
  }

  return (
    <div className={styles.listAlunos}>
      <div className={styles.topoLista}>
        <h2>Treinos Cadastrados</h2>
        <button className={styles.btnEstilizado} onClick={abrirModal}>
          Criar Treino
        </button>
      </div>

      {modalOpen && (
        <div className={styles.modalOverlay}>
          <div className={styles.modalBoxGrande}>
            <h2>Criar Novo Treino</h2>
            <p>Defina os exercícios e detalhes do treino</p>

            <form onSubmit={cadastrarTreino}>
              <div className={styles.alertaCampos}>
                Preencha todos os campos obrigatórios (*) para criar o treino
              </div>

              <div className={styles.row}>
                <div className={styles.col}>
                  <label>Aluno *</label>
                  <select
                    value={aluno}
                    onChange={(e) => setAluno(e.target.value)}
                    required
                  >
                    <option value="">Selecione...</option>
                    <option value="1">João Silva</option>
                    <option value="2">Maria Santos</option>
                  </select>
                </div>

                <div className={styles.col}>
                  <label>Dia da Semana *</label>
                  <select
                    value={diaSemana}
                    onChange={(e) => setDiaSemana(e.target.value)}
                    required
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

                  <div className={styles.row}>
                    <div className={styles.col}>
                      <label>Nome do Exercício *</label>
                      <input
                        type="text"
                        placeholder="Ex: Supino Reto"
                        value={ex.nome}
                        onChange={(e) =>
                          atualizarExercicio(index, "nome", e.target.value)
                        }
                        required
                      />
                    </div>

                    <div className={styles.colMini}>
                      <label>Séries *</label>
                      <input
                        type="number"
                        placeholder="Ex: 4"
                        value={ex.series}
                        onChange={(e) =>
                          atualizarExercicio(index, "series", e.target.value)
                        }
                        required
                      />
                    </div>
                  </div>

                  <div className={styles.row}>
                    <div className={styles.col}>
                      <label>Repetições *</label>
                      <input
                        type="text"
                        placeholder="Ex: 8-10"
                        value={ex.repeticoes}
                        onChange={(e) =>
                          atualizarExercicio(
                            index,
                            "repeticoes",
                            e.target.value
                          )
                        }
                        required
                      />
                    </div>

                    <div className={styles.col}>
                      <label>Carga (opcional)</label>
                      <input
                        type="text"
                        placeholder="Ex: 20kg"
                        value={ex.carga}
                        onChange={(e) =>
                          atualizarExercicio(index, "carga", e.target.value)
                        }
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
                  />

                  <button
                    type="button"
                    className={styles.btnRemover}
                    onClick={() => removerExercicio(index)}
                  >
                    🗑 Remover
                  </button>
                </div>
              ))}

              <div className={styles.modalButtons}>
                <button type="submit" className={styles.modalButton}>
                  Salvar Treino
                </button>

                <button
                  type="button"
                  className={styles.modalButtonCancelar}
                  onClick={fecharModal}
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
