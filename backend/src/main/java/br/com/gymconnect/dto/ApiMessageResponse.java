package br.com.gymconnect.dto;

/**
 * Resposta JSON padrão para mensagens ({@code "mensagem": "..."}).
 * Substitui o antigo {@code ResponseModel} singleton.
 */
public record ApiMessageResponse(String mensagem) {
}
