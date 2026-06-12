package br.com.gymconnect.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import br.com.gymconnect.model.ResponseModel;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.repository.UsuarioRepository;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository ur;

    public Iterable<Usuario> listar(){
        return ur.findAll();
    }

    public ResponseEntity<ResponseModel> remover(Long idUsuario){
        ResponseModel rm = new ResponseModel();
        try {
            ur.deleteById(idUsuario);
            rm.setMensagem("O Usuario foi removido com sucesso!");
            return new ResponseEntity<>(rm, HttpStatus.OK);
        } catch (DataIntegrityViolationException e) {
            rm.setMensagem("Não é possível remover este aluno pois ele possui dados associados (treinos, registros, etc.).");
            return new ResponseEntity<>(rm, HttpStatus.CONFLICT);
        }
    }

}
