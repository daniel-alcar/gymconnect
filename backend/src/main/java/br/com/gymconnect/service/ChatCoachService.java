package br.com.gymconnect.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import br.com.gymconnect.dto.ChatCoachResponse;
import br.com.gymconnect.model.Usuario;

@Service
public class ChatCoachService {

    private static final String SYSTEM_INSTRUCTION = """
            Você é um assistente de musculação e condicionamento do app GymConnect.
            Use o bloco "Contexto do sistema" como fonte de verdade sobre cronogramas e exercícios do aluno.
            Se o contexto não tiver a informação, diga que não há dado cadastrado e sugira falar com o profissional.
            Responda em português do Brasil, de forma clara e segura (sem prescrever medicamentos).
            """;

    private final TreinoContextoService treinoContextoService;
    private final GeminiGenerateContentClient geminiClient;

    public ChatCoachService(
            TreinoContextoService treinoContextoService,
            GeminiGenerateContentClient geminiClient) {
        this.treinoContextoService = treinoContextoService;
        this.geminiClient = geminiClient;
    }

    public ChatCoachResponse responder(Usuario usuarioLogado, String message) {
        if (message == null || message.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Campo message é obrigatório.");
        }

        String contextoMysql = treinoContextoService.montarResumoParaPrompt(usuarioLogado);
        String userPrompt = "Contexto do sistema (dados do MySQL, somente leitura):\n"
                + contextoMysql
                + "\n\nPergunta do aluno:\n"
                + message.strip();

        try {
            String reply = geminiClient.generate(SYSTEM_INSTRUCTION, userPrompt);
            return new ChatCoachResponse(reply);
        } catch (IllegalStateException e) {
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, e.getMessage(), e);
        }
    }
}
