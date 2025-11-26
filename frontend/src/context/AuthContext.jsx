import { createContext, useContext, useState, useEffect } from "react";
import { authAPI } from "../services/api";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const savedToken = localStorage.getItem("token");
    const savedUser = localStorage.getItem("user");

    if (savedToken && savedUser) {
      try {
        setToken(savedToken);
        setUser(JSON.parse(savedUser));
        setLoading(false);

        authAPI
          .getCurrentUser()
          .then((userData) => {
            setUser(userData);
            localStorage.setItem("user", JSON.stringify(userData));
          })
          .catch(() => {
            localStorage.removeItem("token");
            localStorage.removeItem("user");
            setToken(null);
            setUser(null);
          });
      } catch (error) {
        localStorage.removeItem("token");
        localStorage.removeItem("user");
        setLoading(false);
      }
    } else {
      setLoading(false);
    }
  }, []);

  const login = async (email, senha) => {
    try {
      const data = await authAPI.login(email, senha);
      const token = data.token;

      setToken(token);
      localStorage.setItem("token", token);

      const userData = await authAPI.getCurrentUser();
      setUser(userData);
      localStorage.setItem("user", JSON.stringify(userData));

      return { success: true, user: userData };
    } catch (error) {
      return { success: false, error: error.message };
    }
  };

  const cadastrar = async (nome, email, senha, tipo) => {
    try {
      await authAPI.cadastrar(nome, email, senha, tipo);
      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    localStorage.removeItem("token");
    localStorage.removeItem("user");
  };

  const isCliente = () => user?.tipo === "CLIENTE";
  const isAluno = () => user?.tipo === "ALUNO";
  const isAuthenticated = !!token && !!user;

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        loading,
        login,
        cadastrar,
        logout,
        isCliente,
        isAluno,
        isAuthenticated,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth deve ser usado dentro de AuthProvider");
  }
  return context;
}
