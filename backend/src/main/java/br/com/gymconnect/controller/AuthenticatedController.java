package br.com.gymconnect.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.gymconnect.infra.security.TokenService;
import br.com.gymconnect.model.AutorizationDTO;
import br.com.gymconnect.model.CadastrarDTO;
import br.com.gymconnect.model.LoginResponseDTO;
import br.com.gymconnect.model.TipoUsuario;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.repository.UsuarioRepository;

@RestController
@RequestMapping("auth") 
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3000", "http://localhost"})
public class AuthenticatedController {
    
    @Autowired
    private AuthenticationManager authenticationManager;
    
    @Autowired
    private TokenService tokenService;

    @Autowired
    private UsuarioRepository ur;

    @PostMapping("/login")
    public ResponseEntity<LoginResponseDTO> login(@RequestBody @Validated AutorizationDTO data){
        var usernamePassword = new UsernamePasswordAuthenticationToken(data.email(), data.senha());
        var auth = this.authenticationManager.authenticate(usernamePassword);

        var token = tokenService.generateToken((Usuario) auth.getPrincipal());

        return ResponseEntity.ok(new LoginResponseDTO(token));
    }

    @PostMapping("/cadastrar")
    public ResponseEntity<?> cadastrar(@RequestBody @Validated CadastrarDTO data){

        if (this.ur.findByEmail(data.email()) != null) {
            return ResponseEntity.badRequest().build(); 
        } 

        String encryptedSenha = new BCryptPasswordEncoder().encode(data.senha());
        Usuario newUsuario = new Usuario(data.nome(), data.email(), encryptedSenha, data.tipo());

        this.ur.save(newUsuario);

        return ResponseEntity.ok().build();
    }

    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(){
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).build();
        }

        Usuario usuario = (Usuario) authentication.getPrincipal();
        
        // Criar um DTO sem a senha
        UsuarioDTO usuarioDTO = new UsuarioDTO(
            usuario.getIdUsuario(),
            usuario.getNome(),
            usuario.getEmail(),
            usuario.getTipo()
        );

        return ResponseEntity.ok(usuarioDTO);
    }

    public record UsuarioDTO(Long idUsuario, String nome, String email, TipoUsuario tipo) {
    }
    
}
