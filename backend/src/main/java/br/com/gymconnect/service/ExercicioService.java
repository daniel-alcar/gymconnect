package br.com.gymconnect.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import br.com.gymconnect.model.Exercicio;
import br.com.gymconnect.model.ResponseModel;
import br.com.gymconnect.repository.CronogramaExercicioRepository;
import br.com.gymconnect.repository.ExercicioRepository;

@Service
public class ExercicioService {

    @Autowired
    private ResponseModel rm;

    @Autowired
    private ExercicioRepository er;

    @Autowired
    private CronogramaExercicioRepository cer;

    public ResponseEntity<?> cadastrar(Exercicio ex){

        if (ex.getNome().equals("")) {
            rm.setMensagem("O campo nome exercicio precisa ser preenchido!");
            return new ResponseEntity<>(rm, HttpStatus.BAD_REQUEST);
        } else if (ex.getLinkYoutube() == null || ex.getLinkYoutube().isBlank()) {
            rm.setMensagem("O campo Link não foi preenchido!");
            return new ResponseEntity<>(rm, HttpStatus.BAD_REQUEST);
        } else {
            return new ResponseEntity<>(er.save(ex), HttpStatus.OK);
        }

    }

    public ResponseEntity<?> atualizar(Long idExercicio, Exercicio dados){

        if (dados.getNome() == null || dados.getNome().isBlank()) {
            rm.setMensagem("O campo nome exercicio precisa ser preenchido!");
            return new ResponseEntity<>(rm, HttpStatus.BAD_REQUEST);
        }
        if (dados.getLinkYoutube() == null || dados.getLinkYoutube().isBlank()) {
            rm.setMensagem("O campo Link não foi preenchido!");
            return new ResponseEntity<>(rm, HttpStatus.BAD_REQUEST);
        }

        var opt = er.findById(idExercicio);
        if (opt.isEmpty()) {
            rm.setMensagem("Exercicio não encontrado");
            return new ResponseEntity<>(rm, HttpStatus.NOT_FOUND);
        }

        Exercicio ex = opt.get();
        ex.setNome(dados.getNome());
        ex.setLinkYoutube(dados.getLinkYoutube());
        ex.setDescricao(dados.getDescricao());
        return new ResponseEntity<>(er.save(ex), HttpStatus.OK);
    }

    public ResponseEntity<ResponseModel> remover(Long idExercicio){

        // Evita violar a FK: exercicio em uso em algum treino nao pode ser
        // removido (retorna mensagem amigavel em vez de estourar erro -> 403).
        if (cer.existsByExercicio_IdExercicio(idExercicio)) {
            rm.setMensagem(
                "Nao e possivel excluir: este exercicio esta em uso em um ou "
                + "mais treinos. Remova-o dos treinos primeiro.");
            return new ResponseEntity<>(rm, HttpStatus.CONFLICT);
        }

        er.deleteById(idExercicio);

        rm.setMensagem("Exercicio deletado");
        return new ResponseEntity<>(rm, HttpStatus.OK);
    }

    public ResponseEntity<?> listar() {

        List<Exercicio> exercicios = er.findAll();

        return ResponseEntity.ok(exercicios);
    }

    
}
