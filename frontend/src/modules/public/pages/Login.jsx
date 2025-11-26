import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../../context/AuthContext";
import styles from "./styles.module.css";
import Title from "./Title.jsx";

export default function Login() {
  const [email, setEmail] = useState("");
  const [senha, setSenha] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    const result = await login(email, senha);

    if (result.success) {
      if (result.user.tipo === "CLIENTE") {
        navigate("/home-cliente");
      } else {
        navigate("/home-aluno");
      }
    } else {
      setError(result.error || "Erro ao fazer login");
    }

    setLoading(false);
  };

  return (
    <div className={styles.container}>
      <Title />
      <form onSubmit={handleSubmit}>
        <div>
          <h2>Fazer Login</h2>
          <p>Entre com suas credenciais para acessar sua conta</p>
        </div>
        {error && (
          <div style={{ color: "red", marginBottom: "1rem" }}>{error}</div>
        )}
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
          {loading ? "Entrando..." : "Login"}
        </button>
        <p style={{ marginTop: "1rem", textAlign: "center" }}>
          Não tem uma conta? <a href="/cadastro">Cadastre-se</a>
        </p>
      </form>
    </div>
  );
}
