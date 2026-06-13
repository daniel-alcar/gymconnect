package br.com.gymconnect.model;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record AutorizationDTO(
        @NotBlank(message = "E-mail obrigatório.")
        @Email(message = "E-mail inválido.")
        String email,

        @NotBlank(message = "Senha obrigatória.")
        String senha) {
}
