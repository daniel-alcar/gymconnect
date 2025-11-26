import { BrowserRouter, Routes, Route } from "react-router-dom";
import Login from "../modules/public/pages/Login";
import Cadastro from "../modules/public/pages/Cadastro";
import HomeCliente from "../modules/cliente/pages/HomeCliente";
import HomeAluno from "../modules/aluno/pages/HomeAluno";

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login />} />
        {/* mudar futuramente para "/" <Login/> quando adicionar a pagina Home da plataforma */}
        <Route path="/login" element={<Login />} />
        <Route path="/cadastro" element={<Cadastro />} />
        <Route path="/home-cliente" element={<HomeCliente />} />
        <Route path="/home-aluno" element={<HomeAluno />} />
      </Routes>
    </BrowserRouter>
  );
}
