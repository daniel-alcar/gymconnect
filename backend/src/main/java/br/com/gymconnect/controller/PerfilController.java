package br.com.gymconnect.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.gymconnect.dto.PerfilRequestDTO;
import br.com.gymconnect.exception.BadRequestException;
import br.com.gymconnect.exception.UnauthorizedException;
import br.com.gymconnect.model.PerfilModel;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.repository.PerfilRepository;
import br.com.gymconnect.service.PerfilService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/perfil")
@CrossOrigin(origins = { "http://localhost:5173", "http://localhost:3000", "http://localhost" })
public class PerfilController {

    @Autowired
    private PerfilService ps;

    @Autowired
    private PerfilRepository pr;

    @PostMapping("/me")
    public ResponseEntity<PerfilModel> cadastrarPerfilDoUsuarioLogado(@RequestBody @Valid PerfilRequestDTO dto) {
        Usuario usuarioLogado = requireUsuarioLogado();

        if (pr.existsByUsuario_IdUsuario(usuarioLogado.getIdUsuario())) {
            throw new BadRequestException("Usuario ja possui perfil cadastrado.");
        }

        return ResponseEntity.ok(ps.cadastrar(dto, usuarioLogado));
    }

    private Usuario requireUsuarioLogado() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()
                || !(authentication.getPrincipal() instanceof Usuario usuarioLogado)) {
            throw new UnauthorizedException("Usuário não autenticado.");
        }
        return usuarioLogado;
    }
}
