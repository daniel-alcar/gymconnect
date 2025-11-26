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

import br.com.gymconnect.model.Cronograma;
import br.com.gymconnect.service.CronogramaService;



@RestController
@RequestMapping("/cronograma")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3000"})
public class CronogramaController {
    
    @Autowired
    private CronogramaService cs;

    @PostMapping
    public ResponseEntity<?> cadastrar(@RequestBody Cronograma cronograma){

        return cs.cadastrar(cronograma);
    }

    @DeleteMapping("/{idCronograma}")
    public ResponseEntity<?> remover(@PathVariable Long idCronograma){

        return cs.remover(idCronograma);
    }

    @GetMapping("/{idAluno}")
    public ResponseEntity<?> listar(@PathVariable Long idAluno){
        return cs.listar(idAluno);
    }

}
