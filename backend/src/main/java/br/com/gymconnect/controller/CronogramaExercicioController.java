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

import br.com.gymconnect.model.CronogramaExercicio;
import br.com.gymconnect.service.CronogramaExercicioService;

@RestController
@RequestMapping("/cronogramaexercicio")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3000", "http://localhost"})

public class CronogramaExercicioController {
    
    @Autowired
    private CronogramaExercicioService ces;

    @PostMapping
    public ResponseEntity<?> cadastrar(@RequestBody CronogramaExercicio cronogExerc) {

        return ces.cadastrar(cronogExerc);

    }

    @DeleteMapping("/{idCronogramaExercicio}")
    public ResponseEntity<?> remover(@PathVariable Long idCronogramaExercicio) {

        return ces.remover(idCronogramaExercicio);
    }

    @GetMapping("/aluno/{idAluno}")
    public ResponseEntity<?> listarPorAluno(@PathVariable Long idAluno) {

        return ces.listar(idAluno);

    }
}
