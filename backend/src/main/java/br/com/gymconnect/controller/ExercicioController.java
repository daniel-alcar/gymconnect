package br.com.gymconnect.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.gymconnect.dto.ApiMessageResponse;
import br.com.gymconnect.dto.ExercicioRequestDTO;
import br.com.gymconnect.model.Exercicio;
import br.com.gymconnect.service.ExercicioService;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/exercicios")
@CrossOrigin(origins = { "http://localhost:5173", "http://localhost:3000", "http://localhost" })
public class ExercicioController {

    @Autowired
    private ExercicioService es;

    @GetMapping
    public ResponseEntity<Iterable<Exercicio>> listar() {
        return ResponseEntity.ok(es.listar());
    }

    @PostMapping
    public ResponseEntity<Exercicio> cadastrar(@RequestBody @Valid ExercicioRequestDTO dto) {
        return ResponseEntity.ok(es.cadastrar(dto));
    }

    @PutMapping("{idExercicio}")
    public ResponseEntity<Exercicio> atualizar(
            @PathVariable Long idExercicio,
            @RequestBody @Valid ExercicioRequestDTO dto) {
        return ResponseEntity.ok(es.atualizar(idExercicio, dto));
    }

    @DeleteMapping("{idExercicio}")
    public ResponseEntity<ApiMessageResponse> remover(@PathVariable Long idExercicio) {
        es.remover(idExercicio);
        return ResponseEntity.ok(new ApiMessageResponse("Exercicio deletado"));
    }
}
