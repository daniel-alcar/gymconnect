package br.com.gymconnect.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.gymconnect.exception.UnauthorizedException;
import br.com.gymconnect.model.CronogramaExecucao;
import br.com.gymconnect.model.StatusExecucao;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.service.CronogramaExecucaoService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;

@RestController
@RequestMapping("/cronogramaexecucao")
@CrossOrigin(origins = { "http://localhost:5173", "http://localhost:3000", "http://localhost" })
public class CronogramaExecucaoController {

    @Autowired
    private CronogramaExecucaoService cronogramaExecucaoService;

    @PostMapping("/me")
    public ResponseEntity<CronogramaExecucao> cadastrar(@RequestBody CronogramaExecucao execucao) {
        Usuario usuarioLogado = requireUsuarioLogado();
        execucao.setIdExecucao(null);
        return ResponseEntity.ok(cronogramaExecucaoService.cadastrar(execucao, usuarioLogado.getIdUsuario()));
    }

    @PutMapping("/me/{idExecucao}")
    public ResponseEntity<CronogramaExecucao> atualizarStatus(
            @PathVariable Long idExecucao,
            @RequestBody @Valid AtualizarStatusDTO body) {
        Usuario usuarioLogado = requireUsuarioLogado();
        return ResponseEntity.ok(
                cronogramaExecucaoService.atualizarStatus(idExecucao, body.status(), usuarioLogado.getIdUsuario()));
    }

    @GetMapping("/me/cronograma/{idCronograma}")
    public ResponseEntity<Iterable<CronogramaExecucao>> listarPorCronograma(@PathVariable Long idCronograma) {
        Usuario usuarioLogado = requireUsuarioLogado();
        return ResponseEntity.ok(
                cronogramaExecucaoService.listarPorCronograma(idCronograma, usuarioLogado.getIdUsuario()));
    }

    private Usuario requireUsuarioLogado() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()
                || !(authentication.getPrincipal() instanceof Usuario usuarioLogado)) {
            throw new UnauthorizedException("Usuário não autenticado.");
        }
        return usuarioLogado;
    }

    public record AtualizarStatusDTO(@NotNull(message = "Status obrigatório.") StatusExecucao status) {
    }
}
