package br.com.gymconnect.model;

import br.com.gymconnect.validation.SenhaForte;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CadastrarDTO(
        @NotBlank(message = "Nome obrigatório.")
        @Size(max = 150)
        String nome,

        @NotBlank(message = "E-mail obrigatório.")
        @Email(message = "E-mail inválido.")
        @Size(max = 150)
        String email,

        @NotBlank(message = "Senha obrigatória.")
        @SenhaForte
        String senha,

        @NotNull(message = "Tipo de usuário obrigatório.")
        TipoUsuario tipo) {
}
