package br.com.gymconnect.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record RegistroDiarioRequestDTO(
        @NotNull(message = "Execução obrigatória.")
        @Valid
        ExecucaoRef execucao,

        @NotNull(message = "Peso obrigatório.")
        @Positive(message = "Peso deve ser maior que zero.")
        Double peso) {

    public record ExecucaoRef(
            @NotNull(message = "id_execucao obrigatorio.")
            Long idExecucao) {
    }
}
