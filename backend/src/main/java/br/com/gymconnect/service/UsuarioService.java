package br.com.gymconnect.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import br.com.gymconnect.model.ResponseModel;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.repository.CronogramaRepository;
import br.com.gymconnect.repository.PerfilRepository;
import br.com.gymconnect.repository.UsuarioRepository;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository ur;

    @Autowired
    private CronogramaRepository cr;

    @Autowired
    private PerfilRepository pr;

    public Iterable<Usuario> listar(){
        return ur.findAll();
    }

    public ResponseEntity<ResponseModel> remover(Long idUsuario){
        ResponseModel rm = new ResponseModel();

        if (cr.existsByAlunoIdUsuario(idUsuario)) {
            rm.setMensagem("Não é possível remover este aluno pois ele possui treinos ou registros associados.");
            return new ResponseEntity<>(rm, HttpStatus.CONFLICT);
        }

        // Perfil tem FK para usuarios — deve ser removido antes
        pr.findByUsuario_IdUsuario(idUsuario).ifPresent(pr::delete);

        ur.deleteById(idUsuario);
        rm.setMensagem("O aluno foi removido com sucesso!");
        return new ResponseEntity<>(rm, HttpStatus.OK);
    }

}
