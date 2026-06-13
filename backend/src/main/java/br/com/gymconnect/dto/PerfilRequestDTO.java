package br.com.gymconnect.dto;

import java.time.LocalDate;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record PerfilRequestDTO(
        @NotNull(message = "Data de nascimento obrigatória.")
        LocalDate dataNascimento,

        @NotNull(message = "Altura obrigatória.")
        @Positive(message = "Altura deve ser maior que zero.")
        Double altura,

        @NotBlank(message = "Objetivo obrigatório.")
        @Size(max = 50)
        String objetivo) {
}
