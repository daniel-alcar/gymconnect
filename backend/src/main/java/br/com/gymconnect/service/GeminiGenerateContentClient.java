package br.com.gymconnect.service;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

import br.com.gymconnect.config.GeminiProperties;

@Service
public class GeminiGenerateContentClient {

    private static final String BASE_URL = "https://generativelanguage.googleapis.com";

    private final RestClient restClient;
    private final ObjectMapper objectMapper;
    private final GeminiProperties geminiProperties;

    public GeminiGenerateContentClient(
            RestClient.Builder restClientBuilder,
            ObjectMapper objectMapper,
            GeminiProperties geminiProperties) {
        this.restClient = restClientBuilder.baseUrl(BASE_URL).build();
        this.objectMapper = objectMapper;
        this.geminiProperties = geminiProperties;
    }

    public String generate(String systemInstructionText, String userText) {
        String apiKey = normalizarChaveApi(geminiProperties.getApiKey());
        if (apiKey.isBlank()) {
            throw new IllegalStateException("Configure gemini.api-key ou a variável GEMINI_API_KEY.");
        }

        String model = geminiProperties.getModel();
        ObjectNode body = objectMapper.createObjectNode();
        ObjectNode systemInstruction = body.putObject("systemInstruction");
        ArrayNode systemParts = systemInstruction.putArray("parts");
        systemParts.addObject().put("text", systemInstructionText);

        ObjectNode userContent = objectMapper.createObjectNode();
        userContent.put("role", "user");
        ArrayNode userParts = userContent.putArray("parts");
        userParts.addObject().put("text", userText);

        body.putArray("contents").add(userContent);

        ObjectNode generationConfig = body.putObject("generationConfig");
        generationConfig.put("temperature", 0.7);
        generationConfig.put("maxOutputTokens", 2048);

        String path = "/v1beta/models/" + model + ":generateContent";

        String uriCompleta = BASE_URL + path + "?key=" + URLEncoder.encode(apiKey, StandardCharsets.UTF_8);

        try {
            String json = restClient.post()
                    .uri(URI.create(uriCompleta))
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(body)
                    .retrieve()
                    .body(String.class);

            return extrairTexto(json);
        } catch (RestClientResponseException e) {
            throw new IllegalStateException(
                    "Falha ao chamar Gemini (" + e.getStatusCode().value() + "): " + e.getResponseBodyAsString(),
                    e);
        }
    }

    private String extrairTexto(String json) {
        try {
            JsonNode root = objectMapper.readTree(json);
            JsonNode candidates = root.path("candidates");
            if (!candidates.isArray() || candidates.isEmpty()) {
                throw new IllegalStateException("Resposta sem candidates: " + root.path("promptFeedback"));
            }
            JsonNode parts = candidates.get(0).path("content").path("parts");
            if (!parts.isArray() || parts.isEmpty()) {
                throw new IllegalStateException("Resposta sem texto em content.parts");
            }
            StringBuilder out = new StringBuilder();
            for (JsonNode p : parts) {
                if (p.has("text")) {
                    out.append(p.get("text").asText());
                }
            }
            String text = out.toString().trim();
            if (text.isEmpty()) {
                throw new IllegalStateException("Resposta vazia do modelo");
            }
            return text;
        } catch (IOException e) {
            throw new IllegalStateException("JSON inválido retornado pelo Gemini", e);
        }
    }

    private static String normalizarChaveApi(String raw) {
        if (raw == null) {
            return "";
        }
        String t = raw.trim();
        if ((t.startsWith("\"") && t.endsWith("\"")) || (t.startsWith("'") && t.endsWith("'"))) {
            t = t.substring(1, t.length() - 1).trim();
        }
        if (t.startsWith("{") && t.endsWith("}") && t.length() > 2) {
            t = t.substring(1, t.length() - 1).trim();
        }
        return t;
    }
}
