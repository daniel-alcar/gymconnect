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

import br.com.gymconnect.dto.RegistroDiarioRequestDTO;
import br.com.gymconnect.exception.BadRequestException;
import br.com.gymconnect.exception.ForbiddenException;
import br.com.gymconnect.exception.UnauthorizedException;
import br.com.gymconnect.model.CronogramaExecucao;
import br.com.gymconnect.model.RegistroDiarioModel;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.repository.CronogramaExecucaoRepository;
import br.com.gymconnect.service.RegistroService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/registrodiario")
@CrossOrigin(origins = { "http://localhost:5173", "http://localhost:3000", "http://localhost" })
public class RegistroDiarioController {

    @Autowired
    private RegistroService rs;

    @Autowired
    private CronogramaExecucaoRepository cronogramaExecucaoRepository;

    @PostMapping("/me")
    public ResponseEntity<RegistroDiarioModel> cadastrarRegistroDiarioDoUsuarioLogado(
            @RequestBody @Valid RegistroDiarioRequestDTO dto) {
        Usuario usuarioLogado = requireUsuarioLogado();

        CronogramaExecucao execucao = cronogramaExecucaoRepository.findById(dto.execucao().idExecucao())
                .orElseThrow(() -> new BadRequestException("Execucao nao encontrada."));

        if (execucao.getCronograma().getAluno().getIdUsuario() != usuarioLogado.getIdUsuario()) {
            throw new ForbiddenException("Execucao nao pertence ao usuario logado.");
        }

        RegistroDiarioModel registro = new RegistroDiarioModel();
        registro.setExecucao(execucao);
        registro.setPeso(dto.peso());

        return ResponseEntity.ok(rs.cadastrar(registro));
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
