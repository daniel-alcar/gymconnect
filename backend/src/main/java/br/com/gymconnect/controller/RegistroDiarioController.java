package br.com.gymconnect.controller;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.gymconnect.model.CronogramaExecucao;
import br.com.gymconnect.model.RegistroDiarioModel;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.repository.CronogramaExecucaoRepository;
import br.com.gymconnect.service.RegistroService;

@RestController
@RequestMapping("/registrodiario")
@CrossOrigin(origins = { "http://localhost:5173", "http://localhost:3000", "http://localhost" })
public class RegistroDiarioController {

    @Autowired
    private RegistroService rs;

    @Autowired
    private CronogramaExecucaoRepository cronogramaExecucaoRepository;

    @PostMapping("/me")
    public ResponseEntity<?> cadastrarRegistroDiarioDoUsuarioLogado(@RequestBody RegistroDiarioModel registro) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated() || !(authentication.getPrincipal() instanceof Usuario)) {
            return ResponseEntity.status(401).build();
        }

        Usuario usuarioLogado = (Usuario) authentication.getPrincipal();

        if (registro.getExecucao() == null || registro.getExecucao().getIdExecucao() == null) {
            return ResponseEntity.badRequest().body("id_execucao obrigatorio.");
        }

        Optional<CronogramaExecucao> execOpt = cronogramaExecucaoRepository.findById(registro.getExecucao().getIdExecucao());
        if (execOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Execucao nao encontrada.");
        }

        CronogramaExecucao execucao = execOpt.get();
        if (execucao.getCronograma().getAluno().getIdUsuario() != usuarioLogado.getIdUsuario()) {
            return ResponseEntity.status(403).body("Execucao nao pertence ao usuario logado.");
        }

        registro.setIdRegistro(null);
        registro.setExecucao(execucao);

        return rs.cadastrar(registro);
    }
}
