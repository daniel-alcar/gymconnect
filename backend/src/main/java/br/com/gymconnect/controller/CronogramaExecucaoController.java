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

import br.com.gymconnect.model.CronogramaExecucao;
import br.com.gymconnect.model.StatusExecucao;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.service.CronogramaExecucaoService;

@RestController
@RequestMapping("/cronogramaexecucao")
@CrossOrigin(origins = { "http://localhost:5173", "http://localhost:3000", "http://localhost" })
public class CronogramaExecucaoController {

    @Autowired
    private CronogramaExecucaoService cronogramaExecucaoService;

    @PostMapping("/me")
    public ResponseEntity<?> cadastrar(@RequestBody CronogramaExecucao execucao) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated() || !(authentication.getPrincipal() instanceof Usuario)) {
            return ResponseEntity.status(401).build();
        }

        Usuario usuarioLogado = (Usuario) authentication.getPrincipal();
        execucao.setIdExecucao(null);
        return cronogramaExecucaoService.cadastrar(execucao, usuarioLogado.getIdUsuario());
    }

    @PutMapping("/me/{idExecucao}")
    public ResponseEntity<?> atualizarStatus(@PathVariable Long idExecucao, @RequestBody AtualizarStatusDTO body) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated() || !(authentication.getPrincipal() instanceof Usuario)) {
            return ResponseEntity.status(401).build();
        }

        if (body == null || body.status() == null) {
            return ResponseEntity.badRequest().build();
        }

        Usuario usuarioLogado = (Usuario) authentication.getPrincipal();
        return cronogramaExecucaoService.atualizarStatus(idExecucao, body.status(), usuarioLogado.getIdUsuario());
    }

    @GetMapping("/me/cronograma/{idCronograma}")
    public ResponseEntity<?> listarPorCronograma(@PathVariable Long idCronograma) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated() || !(authentication.getPrincipal() instanceof Usuario)) {
            return ResponseEntity.status(401).build();
        }

        Usuario usuarioLogado = (Usuario) authentication.getPrincipal();
        return cronogramaExecucaoService.listarPorCronograma(idCronograma, usuarioLogado.getIdUsuario());
    }

    public record AtualizarStatusDTO(StatusExecucao status) {
    }
}
