import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../../context/AuthContext";
import styles from "./styles.module.css";
import Title from "./Title.jsx";

export default function Cadastro() {
  const [nome, setNome] = useState("");
  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");
  const [tipo, setTipo] = useState("aluno");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [loading, setLoading] = useState(false);
  const { cadastrar, login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setSuccess("");
    setLoading(true);

    const tipoUsuario = tipo === "cliente" ? "CLIENTE" : "ALUNO";

    const result = await cadastrar(nome, email, senha, tipoUsuario);

    if (result.success) {
      setSuccess("Conta criada com sucesso! Fazendo login...");

      try {
        const loginResult = await login(email, senha);
        if (loginResult.success) {
          if (loginResult.user.tipo === "CLIENTE") {
            navigate("/home-cliente");
          } else {
            navigate("/home-aluno");
          }
        } else {
          setSuccess("Conta criada com sucesso! Redirecionando para login...");
          setTimeout(() => {
            navigate("/login");
          }, 2000);
        }
      } catch (loginError) {
        setSuccess("Conta criada com sucesso! Redirecionando para login...");
        setTimeout(() => {
          navigate("/login");
        }, 2000);
      }
    } else {
      setError(result.error || "Erro ao cadastrar");
    }

    setLoading(false);
  };

  return (
    <div className={styles.container}>
      <Title />
      <form className={styles.formCard} onSubmit={handleSubmit}>
        <div>
          <h2>Criar Conta</h2>
          <p>Preencha os dados para criar sua conta</p>
        </div>
        {error && (
          <div style={{ color: "red", marginBottom: "1rem" }}>{error}</div>
        )}
        {success && (
          <div style={{ color: "green", marginBottom: "1rem" }}>{success}</div>
        )}
        <div>
          <label htmlFor="tipo">Tipo de conta</label>
          <select
            id="tipo"
            value={tipo}
            onChange={(e) => setTipo(e.target.value)}
            disabled={loading}
          >
            <option value="cliente">Academia</option>
            <option value="aluno">Aluno</option>
          </select>
        </div>
        <div>
          <label htmlFor="nome">Nome</label>
          <input
            type="text"
            id="nome"
            value={nome}
            onChange={(e) => setNome(e.target.value)}
            required
            disabled={loading}
          />
        </div>
        <div>
          <label htmlFor="email">Email</label>
          <input
            type="email"
            id="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            disabled={loading}
          />
        </div>
        <div>
          <label htmlFor="senha">Senha</label>
          <input
            type="password"
            id="senha"
            value={senha}
            onChange={(e) => setSenha(e.target.value)}
            required
            disabled={loading}
          />
        </div>
        <button
          type="submit"
          className={styles.btnEstilizado}
          disabled={loading}
        >
          {loading ? "Criando conta..." : "Criar Conta"}
        </button>
        <p style={{ marginTop: "1rem", textAlign: "center" }}>
          Já tem uma conta? <a href="/login">Faça login</a>
        </p>
      </form>
    </div>
  );
}
