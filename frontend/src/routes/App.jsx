import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { AuthProvider, useAuth } from "../context/AuthContext";
import Login from "../modules/public/pages/Login";
import Cadastro from "../modules/public/pages/Cadastro";
import HomeCliente from "../modules/cliente/pages/HomeCliente";
import HomeAluno from "../modules/aluno/pages/HomeAluno";

function ProtectedClienteRoute({ children }) {
  const { isCliente, loading, isAuthenticated } = useAuth();

  if (loading) {
    return <div>Carregando...</div>;
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (!isCliente()) {
    return <Navigate to="/home-aluno" replace />;
  }

  return children;
}

function ProtectedAlunoRoute({ children }) {
  const { isAluno, loading, isAuthenticated } = useAuth();

  if (loading) {
    return <div>Carregando...</div>;
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (!isAluno()) {
    return <Navigate to="/home-cliente" replace />;
  }

  return children;
}

function PublicRoute({ children }) {
  const { isAuthenticated, loading, user } = useAuth();

  if (loading) {
    return <div>Carregando...</div>;
  }

  if (isAuthenticated && user) {
    const isCliente = user.tipo === "CLIENTE";
    return (
      <Navigate to={isCliente ? "/home-cliente" : "/home-aluno"} replace />
    );
  }

  return children;
}

function AppRoutes() {
  return (
    <BrowserRouter>
      <Routes>
        <Route
          path="/"
          element={
            <PublicRoute>
              <Login />
            </PublicRoute>
          }
        />
        <Route
          path="/login"
          element={
            <PublicRoute>
              <Login />
            </PublicRoute>
          }
        />
        <Route
          path="/cadastro"
          element={
            <PublicRoute>
              <Cadastro />
            </PublicRoute>
          }
        />
        <Route
          path="/home-cliente"
          element={
            <ProtectedClienteRoute>
              <HomeCliente />
            </ProtectedClienteRoute>
          }
        />
        <Route
          path="/home-aluno"
          element={
            <ProtectedAlunoRoute>
              <HomeAluno />
            </ProtectedAlunoRoute>
          }
        />
      </Routes>
    </BrowserRouter>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <AppRoutes />
    </AuthProvider>
  );
}
