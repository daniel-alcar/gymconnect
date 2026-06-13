package br.com.gymconnect.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import br.com.gymconnect.exception.BadRequestException;
import br.com.gymconnect.exception.ResourceNotFoundException;
import br.com.gymconnect.model.Cronograma;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.repository.CronogramaRepository;
import br.com.gymconnect.repository.UsuarioRepository;

@Service
public class CronogramaService {

    @Autowired
    private CronogramaRepository cr;

    @Autowired
    private UsuarioRepository ur;

    public Cronograma cadastrar(Cronograma cronograma) {
        if (cronograma.getAluno() == null) {
            throw new BadRequestException("Aluno obrigatório.");
        }

        Usuario aluno = ur.findById(cronograma.getAluno().getIdUsuario())
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não cadastrado!"));

        cronograma.setAluno(aluno);
        return cr.save(cronograma);
    }

    public void remover(Long idCronograma) {
        Cronograma cronograma = cr.findById(idCronograma)
                .orElseThrow(() -> new ResourceNotFoundException("Cronograma não encontrado!"));
        cr.delete(cronograma);
    }

    public List<Cronograma> listar(Long idAluno) {
        if (!ur.existsById(idAluno)) {
            throw new ResourceNotFoundException("Cronograma não encontrado!");
        }
        return cr.findByAlunoIdUsuario(idAluno);
    }

    public Cronograma atualizar(Long idCronograma, Cronograma dados) {
        Cronograma existente = cr.findById(idCronograma)
                .orElseThrow(() -> new ResourceNotFoundException("Cronograma não encontrado!"));

        if (dados.getAluno() == null) {
            throw new BadRequestException("Aluno obrigatório.");
        }

        Usuario aluno = ur.findById(dados.getAluno().getIdUsuario())
                .orElseThrow(() -> new ResourceNotFoundException("Aluno não cadastrado!"));

        existente.setAluno(aluno);
        existente.setDiasTotais(dados.getDiasTotais());
        return cr.save(existente);
    }
}
