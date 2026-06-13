package br.com.gymconnect.service;

import java.util.List;
import java.util.stream.StreamSupport;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import br.com.gymconnect.dto.UsuarioResponseDTO;
import br.com.gymconnect.exception.ConflictException;
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

    public List<UsuarioResponseDTO> listar() {
        return StreamSupport.stream(ur.findAll().spliterator(), false)
                .map(UsuarioResponseDTO::from)
                .toList();
    }

    public void remover(Long idUsuario) {
        if (cr.existsByAlunoIdUsuario(idUsuario)) {
            throw new ConflictException(
                    "Não é possível remover este aluno pois ele possui treinos ou registros associados.");
        }
        pr.findByUsuario_IdUsuario(idUsuario).ifPresent(pr::delete);
        ur.deleteById(idUsuario);
    }
}
