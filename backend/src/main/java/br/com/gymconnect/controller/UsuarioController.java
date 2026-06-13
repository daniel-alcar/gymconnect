package br.com.gymconnect.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.gymconnect.dto.ApiMessageResponse;
import br.com.gymconnect.dto.UsuarioResponseDTO;
import br.com.gymconnect.service.UsuarioService;

@RestController
@RequestMapping("/usuarios")
@CrossOrigin(origins = { "http://localhost:5173", "http://localhost:3000", "http://localhost" })
public class UsuarioController {

    @Autowired
    private UsuarioService us;

    @DeleteMapping("/{idUsuario}")
    public ResponseEntity<ApiMessageResponse> remover(@PathVariable long idUsuario) {
        us.remover(idUsuario);
        return ResponseEntity.ok(new ApiMessageResponse("O aluno foi removido com sucesso!"));
    }

    @GetMapping
    public ResponseEntity<Iterable<UsuarioResponseDTO>> listar() {
        return ResponseEntity.ok(us.listar());
    }
}
