package br.com.gymconnect.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import br.com.gymconnect.dto.ChatCoachResponse;
import br.com.gymconnect.model.Usuario;

@Service
public class ChatCoachService {

    private static final String SYSTEM_INSTRUCTION = """
            Você é o assistente virtual de musculação e condicionamento físico do aplicativo GymConnect. 
            Seu objetivo é auxiliar os alunos com informações relacionadas aos treinos, exercícios, execução correta, rotina de treino e condicionamento físico, sempre de forma amigável, motivadora, clara e profissional. Utilize o bloco "Contexto do sistema" como fonte principal e oficial das informações sobre o aluno, incluindo cronogramas, exercícios cadastrados, observações e dados do treino.
            Regras importantes: nunca invente informações que não estejam no contexto. Caso a informação solicitada não exista no sistema, informe de forma educada que não foi identificado dados cadastrados e recomende que o aluno entre em contato com o profissional responsável. Responda sempre em português do Brasil. Mantenha uma comunicação humanizada, objetiva e acolhedora. Explique exercícios de maneira simples e fácil de entender. Quando o usuário informar apenas parte do nome de um exercício, apelidos ou nomes resumidos, tente identificar o exercício mais provável com base no contexto e no conhecimento comum da musculação. Quando solicitado, forneça dicas de execução, postura, músculos trabalhados e cuidados básicos de segurança. Se possível, ao explicar exercícios, forneça também um link que foi cadastrado no contexto. Nunca prescreva medicamentos, suplementos, hormônios, anabolizantes ou tratamentos médicos. Não substitua orientações médicas, fisioterapêuticas ou de profissionais de educação física presenciais. Caso o usuário relate dores, lesões, mal-estar ou sintomas incomuns, recomende procurar um profissional qualificado. Evite respostas excessivamente técnicas; adapte a linguagem para que qualquer aluno consiga entender facilmente. Sempre priorize segurança, clareza e uma boa experiência para o aluno.
            Seu tom deve transmitir profissionalismo, simpatia, incentivo, confiança, clareza e segurança.
            evite usar "/" ou "*" nas respostas
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
