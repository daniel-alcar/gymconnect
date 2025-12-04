package br.com.gymconnect.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.gymconnect.model.ResponseModel;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.service.UsuarioService;

@RestController
@RequestMapping("/usuarios")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3000", "http://localhost"})
public class UsuarioController {

    @Autowired
    private UsuarioService us;

    @DeleteMapping("/{idUsuario}")
    public ResponseEntity<ResponseModel> remover(@PathVariable long idUsuario){
        return us.remover(idUsuario);
    }

    @GetMapping
    public Iterable<Usuario> listar() {
        return us.listar();
    }
    

    

}
