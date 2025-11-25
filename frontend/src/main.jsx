import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./index.css";
import App from "./modules/cliente/pages/HomeCliente.jsx";

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <App />
  </StrictMode>
);
