package br.com.gymconnect.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ExercicioRequestDTO(
        @NotBlank(message = "O campo nome exercicio precisa ser preenchido!")
        @Size(max = 150)
        String nome,

        @NotBlank(message = "O campo Link não foi preenchido!")
        @Size(max = 264)
        String linkYoutube,

        @Size(max = 2000)
        String descricao) {
}
