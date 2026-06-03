package br.com.gymconnect.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import br.com.gymconnect.model.Cronograma;
import br.com.gymconnect.model.ResponseModel;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.repository.CronogramaRepository;
import br.com.gymconnect.repository.UsuarioRepository;

@Service
public class CronogramaService {
    
    @Autowired
    private CronogramaRepository cr;

    @Autowired
    private UsuarioRepository ur;

    public ResponseEntity<?> cadastrar(Cronograma cronograma){

        ResponseModel rm = new ResponseModel();
        
        Long idAluno = cronograma.getAluno().getIdUsuario();
        
        Optional<Usuario> alunoOpt = ur.findById(idAluno);
        if (alunoOpt.isEmpty()) {
            rm.setMensagem("Aluno não cadastrado!");
            return new ResponseEntity<ResponseModel>(rm, HttpStatus.NOT_FOUND);
        }

        cronograma.setAluno(alunoOpt.get());

        Cronograma salvo = cr.save(cronograma);
        return new ResponseEntity<>(salvo, HttpStatus.OK);
        
    }

    public ResponseEntity<?> remover(Long idCronograma){

        ResponseModel rm = new ResponseModel();

        Optional<Cronograma> cronogramaOpt = cr.findById(idCronograma);
        if (cronogramaOpt.isEmpty()) {
            rm.setMensagem("Cronograma não encontrado!");
            return new ResponseEntity<ResponseModel>(rm, HttpStatus.NOT_FOUND);
        } 

        cr.delete(cronogramaOpt.get());
        rm.setMensagem("Cronograma deletado");
        return new ResponseEntity<>(rm, HttpStatus.OK);
    }

    public ResponseEntity<?> listar(Long idAluno) {

        ResponseModel rm = new ResponseModel();

        Optional<Usuario> alunoOpt = ur.findById(idAluno);

        if (alunoOpt.isEmpty()) {
            rm.setMensagem("Cronograma não encontrado!");
            return new ResponseEntity<ResponseModel>(rm, HttpStatus.NOT_FOUND);
        }

        List<Cronograma> cronogramas = cr.findByAlunoIdUsuario(idAluno);
        return ResponseEntity.ok(cronogramas);
    }

    public ResponseEntity<?> atualizar(Long idCronograma, Cronograma dados) {
        ResponseModel rm = new ResponseModel();

        Optional<Cronograma> cronogramaOpt = cr.findById(idCronograma);
        if (cronogramaOpt.isEmpty()) {
            rm.setMensagem("Cronograma não encontrado!");
            return new ResponseEntity<>(rm, HttpStatus.NOT_FOUND);
        }

        if (dados.getAluno() == null) {
            rm.setMensagem("Aluno obrigatório.");
            return new ResponseEntity<>(rm, HttpStatus.BAD_REQUEST);
        }

        Optional<Usuario> alunoOpt = ur.findById(dados.getAluno().getIdUsuario());
        if (alunoOpt.isEmpty()) {
            rm.setMensagem("Aluno não cadastrado!");
            return new ResponseEntity<>(rm, HttpStatus.NOT_FOUND);
        }

        Cronograma existente = cronogramaOpt.get();
        existente.setAluno(alunoOpt.get());
        existente.setDiasTotais(dados.getDiasTotais());

        Cronograma salvo = cr.save(existente);
        return new ResponseEntity<>(salvo, HttpStatus.OK);
    }
}
