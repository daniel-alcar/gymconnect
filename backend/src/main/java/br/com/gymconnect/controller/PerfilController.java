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

import br.com.gymconnect.model.PerfilModel;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.repository.PerfilRepository;
import br.com.gymconnect.service.PerfilService;

@RestController
@RequestMapping("/perfil")
@CrossOrigin(origins = { "http://localhost:5173", "http://localhost:3000", "http://localhost" })
public class PerfilController {
    
    @Autowired
    private PerfilService ps;

    @Autowired
    private PerfilRepository pr;

    @PostMapping("/me")
    public ResponseEntity<?> cadastrarPerfilDoUsuarioLogado(@RequestBody PerfilModel perfil) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated() || !(authentication.getPrincipal() instanceof Usuario)) {
            return ResponseEntity.status(401).build();
        }

        Usuario usuarioLogado = (Usuario) authentication.getPrincipal();

        if (pr.existsByUsuario_IdUsuario(usuarioLogado.getIdUsuario())) {
            return ResponseEntity.badRequest().body("Usuario ja possui perfil cadastrado.");
        }

        perfil.setIdPerfil(null);
        perfil.setUsuario(usuarioLogado);

        return ps.cadastrar(perfil);
    }
}
