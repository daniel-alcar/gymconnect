package br.com.gymconnect.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.gymconnect.model.Exercicio;
import br.com.gymconnect.model.ResponseModel;
import br.com.gymconnect.service.ExercicioService;



@RestController
@RequestMapping("/exercicios")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3000", "http://localhost"})
public class ExercicioController {
    
    @Autowired
    private ExercicioService es;

    @GetMapping
    public ResponseEntity<?> listar(){

        return es.listar();
        
    }

    @PostMapping
    public ResponseEntity<?> cadastrar(@RequestBody Exercicio ex) {

        return es.cadastrar(ex);

    }

    @DeleteMapping("{idExercicio}")
    public ResponseEntity<ResponseModel> remover (@PathVariable Long idExercicio){

        return es.remover(idExercicio);
    }
    
}
