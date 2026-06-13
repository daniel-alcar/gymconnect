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

import br.com.gymconnect.dto.ChatCoachRequest;
import br.com.gymconnect.dto.ChatCoachResponse;
import br.com.gymconnect.exception.UnauthorizedException;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.service.ChatCoachService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/chat")
@CrossOrigin(origins = { "http://localhost:5173", "http://localhost:3000", "http://localhost" })
public class ChatCoachController {

    @Autowired
    private ChatCoachService chatCoachService;

    @PostMapping("/coach")
    public ResponseEntity<ChatCoachResponse> coach(@RequestBody @Valid ChatCoachRequest request) {
        Usuario usuarioLogado = requireUsuarioLogado();
        ChatCoachResponse body = chatCoachService.responder(usuarioLogado, request.getMessage());
        return ResponseEntity.ok(body);
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
