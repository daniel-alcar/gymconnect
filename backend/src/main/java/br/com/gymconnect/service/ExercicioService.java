package br.com.gymconnect.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import br.com.gymconnect.model.Exercicio;
import br.com.gymconnect.model.ResponseModel;
import br.com.gymconnect.repository.ExercicioRepository;

@Service
public class ExercicioService {
    
    @Autowired
    private ResponseModel rm;

    @Autowired
    private ExercicioRepository er;

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

    public ResponseEntity<ResponseModel> remover(Long idExercicio){

        er.deleteById(idExercicio);
        
        rm.setMensagem("Exercicio deletado");
        return new ResponseEntity<>(rm, HttpStatus.OK);
    }

    public ResponseEntity<?> listar() {

        List<Exercicio> exercicios = er.findAll();

        return ResponseEntity.ok(exercicios);
    }

    
}
