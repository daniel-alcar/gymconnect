package br.com.gymconnect.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import br.com.gymconnect.model.Cronograma;
import br.com.gymconnect.model.CronogramaExecucao;
import br.com.gymconnect.model.ResponseModel;
import br.com.gymconnect.model.StatusExecucao;
import br.com.gymconnect.repository.CronogramaExecucaoRepository;
import br.com.gymconnect.repository.CronogramaRepository;

@Service
public class CronogramaExecucaoService {

    @Autowired
    private CronogramaExecucaoRepository execucaoRepository;

    @Autowired
    private CronogramaRepository cronogramaRepository;

    public ResponseEntity<?> cadastrar(CronogramaExecucao execucaoBody, long idUsuarioAluno) {
        ResponseModel rm = new ResponseModel();

        if (execucaoBody.getCronograma() == null || execucaoBody.getCronograma().getIdCronograma() == null) {
            rm.setMensagem("Cronograma obrigatório.");
            return new ResponseEntity<>(rm, HttpStatus.BAD_REQUEST);
        }
        if (execucaoBody.getStatus() == null) {
            rm.setMensagem("Status obrigatório.");
            return new ResponseEntity<>(rm, HttpStatus.BAD_REQUEST);
        }

        Optional<Cronograma> cronogramaOpt = cronogramaRepository.findById(execucaoBody.getCronograma().getIdCronograma());
        if (cronogramaOpt.isEmpty()) {
            rm.setMensagem("Cronograma não encontrado.");
            return new ResponseEntity<>(rm, HttpStatus.NOT_FOUND);
        }

        Cronograma cronograma = cronogramaOpt.get();
        if (cronograma.getAluno().getIdUsuario() != idUsuarioAluno) {
            rm.setMensagem("Cronograma não pertence ao usuário logado.");
            return new ResponseEntity<>(rm, HttpStatus.FORBIDDEN);
        }

        CronogramaExecucao novo = new CronogramaExecucao();
        novo.setCronograma(cronograma);
        novo.setStatus(execucaoBody.getStatus());

        CronogramaExecucao salvo = execucaoRepository.save(novo);
        return new ResponseEntity<>(salvo, HttpStatus.OK);
    }

    public ResponseEntity<?> atualizarStatus(Long idExecucao, StatusExecucao status, long idUsuarioAluno) {
        ResponseModel rm = new ResponseModel();

        Optional<CronogramaExecucao> opt = execucaoRepository.findById(idExecucao);
        if (opt.isEmpty()) {
            rm.setMensagem("Execução não encontrada.");
            return new ResponseEntity<>(rm, HttpStatus.NOT_FOUND);
        }

        CronogramaExecucao execucao = opt.get();
        if (execucao.getCronograma().getAluno().getIdUsuario() != idUsuarioAluno) {
            rm.setMensagem("Execução não pertence ao usuário logado.");
            return new ResponseEntity<>(rm, HttpStatus.FORBIDDEN);
        }

        execucao.setStatus(status);
        CronogramaExecucao salvo = execucaoRepository.save(execucao);
        return new ResponseEntity<>(salvo, HttpStatus.OK);
    }

    public ResponseEntity<?> listarPorCronograma(Long idCronograma, long idUsuarioAluno) {
        ResponseModel rm = new ResponseModel();

        Optional<Cronograma> cronogramaOpt = cronogramaRepository.findById(idCronograma);
        if (cronogramaOpt.isEmpty()) {
            rm.setMensagem("Cronograma não encontrado.");
            return new ResponseEntity<>(rm, HttpStatus.NOT_FOUND);
        }

        Cronograma cronograma = cronogramaOpt.get();
        if (cronograma.getAluno().getIdUsuario() != idUsuarioAluno) {
            rm.setMensagem("Cronograma não pertence ao usuário logado.");
            return new ResponseEntity<>(rm, HttpStatus.FORBIDDEN);
        }

        List<CronogramaExecucao> lista = execucaoRepository.findByCronograma_IdCronograma(idCronograma);
        return ResponseEntity.ok(lista);
    }
}
