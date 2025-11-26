const API_BASE_URL = "http://localhost:8080";

async function fetchWithAuth(url, options = {}) {
  const token = localStorage.getItem("token");

  const headers = {
    "Content-Type": "application/json",
    ...options.headers,
  };

  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }

  const response = await fetch(`${API_BASE_URL}${url}`, {
    ...options,
    headers,
  });

  if (!response.ok) {
    const error = await response
      .json()
      .catch(() => ({ mensagem: "Erro na requisição" }));
    throw new Error(error.mensagem || `Erro: ${response.status}`);
  }

  const contentType = response.headers.get("content-type");
  if (contentType && contentType.includes("application/json")) {
    const text = await response.text();
    return text ? JSON.parse(text) : null;
  }

  return null;
}

export const authAPI = {
  async login(email, senha) {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ email, senha }),
    });

    if (!response.ok) {
      const error = await response
        .json()
        .catch(() => ({ mensagem: "Erro ao fazer login" }));
      throw new Error(error.mensagem || "Erro ao fazer login");
    }

    return response.json();
  },

  async cadastrar(nome, email, senha, tipo) {
    const response = await fetch(`${API_BASE_URL}/auth/cadastrar`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ nome, email, senha, tipo }),
    });

    if (!response.ok) {
      const error = await response
        .json()
        .catch(() => ({ mensagem: "Erro ao cadastrar" }));
      throw new Error(error.mensagem || "Erro ao cadastrar");
    }

    const contentType = response.headers.get("content-type");
    if (contentType && contentType.includes("application/json")) {
      const text = await response.text();
      return text ? JSON.parse(text) : {};
    }

    return {};
  },

  async getCurrentUser() {
    return fetchWithAuth("/auth/me", {
      method: "GET",
    });
  },
};

export const usuarioAPI = {
  async listar() {
    return fetchWithAuth("/usuarios", {
      method: "GET",
    });
  },

  async remover(idUsuario) {
    return fetchWithAuth(`/usuarios/${idUsuario}`, {
      method: "DELETE",
    });
  },
};

export const exercicioAPI = {
  async listar() {
    return fetchWithAuth("/exercicios", {
      method: "GET",
    });
  },

  async cadastrar(nome, linkYoutube) {
    return fetchWithAuth("/exercicios", {
      method: "POST",
      body: JSON.stringify({ nome, linkYoutube }),
    });
  },

  async remover(idExercicio) {
    return fetchWithAuth(`/exercicios/${idExercicio}`, {
      method: "DELETE",
    });
  },
};

export const cronogramaAPI = {
  async cadastrar(cronograma) {
    return fetchWithAuth("/cronograma", {
      method: "POST",
      body: JSON.stringify(cronograma),
    });
  },

  async remover(idCronograma) {
    return fetchWithAuth(`/cronograma/${idCronograma}`, {
      method: "DELETE",
    });
  },

  async listarPorAluno(idAluno) {
    const result = await fetchWithAuth(`/cronograma/${idAluno}`, {
      method: "GET",
    });

    return Array.isArray(result) ? result : [];
  },
};

export const cronogramaExercicioAPI = {
  async cadastrar(cronogramaExercicio) {
    return fetchWithAuth("/cronogramaexercicio", {
      method: "POST",
      body: JSON.stringify(cronogramaExercicio),
    });
  },

  async remover(idCronogramaExercicio) {
    return fetchWithAuth(`/cronogramaexercicio/${idCronogramaExercicio}`, {
      method: "DELETE",
    });
  },

  async listarPorAluno(idAluno) {
    const result = await fetchWithAuth(
      `/cronogramaexercicio/aluno/${idAluno}`,
      {
        method: "GET",
      }
    );
    return Array.isArray(result) ? result : [];
  },
};
