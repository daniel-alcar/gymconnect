package br.com.gymconnect.dto;

import br.com.gymconnect.model.TipoUsuario;
import br.com.gymconnect.model.Usuario;

public record UsuarioResponseDTO(Long idUsuario, String nome, String email, TipoUsuario tipo) {

    public static UsuarioResponseDTO from(Usuario usuario) {
        return new UsuarioResponseDTO(
                usuario.getIdUsuario(),
                usuario.getNome(),
                usuario.getEmail(),
                usuario.getTipo());
    }
}
