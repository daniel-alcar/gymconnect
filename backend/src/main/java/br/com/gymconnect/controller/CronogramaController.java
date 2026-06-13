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
import br.com.gymconnect.model.Cronograma;
import br.com.gymconnect.service.CronogramaService;

@RestController
@RequestMapping("/cronograma")
@CrossOrigin(origins = { "http://localhost:5173", "http://localhost:3000", "http://localhost" })
public class CronogramaController {

    @Autowired
    private CronogramaService cs;

    @PostMapping
    public ResponseEntity<Cronograma> cadastrar(@RequestBody Cronograma cronograma) {
        return ResponseEntity.ok(cs.cadastrar(cronograma));
    }

    @PutMapping("/{idCronograma}")
    public ResponseEntity<Cronograma> atualizar(
            @PathVariable Long idCronograma,
            @RequestBody Cronograma cronograma) {
        return ResponseEntity.ok(cs.atualizar(idCronograma, cronograma));
    }

    @DeleteMapping("/{idCronograma}")
    public ResponseEntity<ApiMessageResponse> remover(@PathVariable Long idCronograma) {
        cs.remover(idCronograma);
        return ResponseEntity.ok(new ApiMessageResponse("Cronograma deletado"));
    }

    @GetMapping("/{idAluno}")
    public ResponseEntity<Iterable<Cronograma>> listar(@PathVariable Long idAluno) {
        return ResponseEntity.ok(cs.listar(idAluno));
    }
}
