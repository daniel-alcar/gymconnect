package br.com.gymconnect.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import br.com.gymconnect.exception.BadRequestException;
import br.com.gymconnect.exception.ForbiddenException;
import br.com.gymconnect.exception.ResourceNotFoundException;
import br.com.gymconnect.model.Cronograma;
import br.com.gymconnect.model.CronogramaExecucao;
import br.com.gymconnect.model.StatusExecucao;
import br.com.gymconnect.repository.CronogramaExecucaoRepository;
import br.com.gymconnect.repository.CronogramaRepository;

@Service
public class CronogramaExecucaoService {

    @Autowired
    private CronogramaExecucaoRepository execucaoRepository;

    @Autowired
    private CronogramaRepository cronogramaRepository;

    public CronogramaExecucao cadastrar(CronogramaExecucao execucaoBody, long idUsuarioAluno) {
        if (execucaoBody.getCronograma() == null || execucaoBody.getCronograma().getIdCronograma() == null) {
            throw new BadRequestException("Cronograma obrigatório.");
        }
        if (execucaoBody.getStatus() == null) {
            throw new BadRequestException("Status obrigatório.");
        }

        Cronograma cronograma = cronogramaRepository.findById(execucaoBody.getCronograma().getIdCronograma())
                .orElseThrow(() -> new ResourceNotFoundException("Cronograma não encontrado."));

        if (cronograma.getAluno().getIdUsuario() != idUsuarioAluno) {
            throw new ForbiddenException("Cronograma não pertence ao usuário logado.");
        }

        CronogramaExecucao novo = new CronogramaExecucao();
        novo.setCronograma(cronograma);
        novo.setStatus(execucaoBody.getStatus());
        return execucaoRepository.save(novo);
    }

    public CronogramaExecucao atualizarStatus(Long idExecucao, StatusExecucao status, long idUsuarioAluno) {
        CronogramaExecucao execucao = execucaoRepository.findById(idExecucao)
                .orElseThrow(() -> new ResourceNotFoundException("Execução não encontrada."));

        if (execucao.getCronograma().getAluno().getIdUsuario() != idUsuarioAluno) {
            throw new ForbiddenException("Execução não pertence ao usuário logado.");
        }

        execucao.setStatus(status);
        return execucaoRepository.save(execucao);
    }

    public List<CronogramaExecucao> listarPorCronograma(Long idCronograma, long idUsuarioAluno) {
        Cronograma cronograma = cronogramaRepository.findById(idCronograma)
                .orElseThrow(() -> new ResourceNotFoundException("Cronograma não encontrado."));

        if (cronograma.getAluno().getIdUsuario() != idUsuarioAluno) {
            throw new ForbiddenException("Cronograma não pertence ao usuário logado.");
        }

        return execucaoRepository.findByCronograma_IdCronograma(idCronograma);
    }
}
