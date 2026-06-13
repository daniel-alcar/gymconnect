package br.com.gymconnect.service;

import java.util.List;
import java.util.stream.StreamSupport;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import br.com.gymconnect.dto.ExercicioRequestDTO;
import br.com.gymconnect.dto.UsuarioResponseDTO;
import br.com.gymconnect.exception.ConflictException;
import br.com.gymconnect.exception.ResourceNotFoundException;
import br.com.gymconnect.model.Exercicio;
import br.com.gymconnect.repository.CronogramaExercicioRepository;
import br.com.gymconnect.repository.ExercicioRepository;

@Service
public class ExercicioService {

    @Autowired
    private ExercicioRepository er;

    @Autowired
    private CronogramaExercicioRepository cer;

    public List<Exercicio> listar() {
        return er.findAll();
    }

    public Exercicio cadastrar(ExercicioRequestDTO dto) {
        Exercicio ex = toEntity(dto);
        return er.save(ex);
    }

    public Exercicio atualizar(Long idExercicio, ExercicioRequestDTO dto) {
        Exercicio ex = er.findById(idExercicio)
                .orElseThrow(() -> new ResourceNotFoundException("Exercicio não encontrado"));
        applyDto(ex, dto);
        return er.save(ex);
    }

    public void remover(Long idExercicio) {
        if (!er.existsById(idExercicio)) {
            throw new ResourceNotFoundException("Exercicio não encontrado");
        }
        if (cer.existsByExercicio_IdExercicio(idExercicio)) {
            throw new ConflictException(
                    "Nao e possivel excluir: este exercicio esta em uso em um ou "
                            + "mais treinos. Remova-o dos treinos primeiro.");
        }
        er.deleteById(idExercicio);
    }

    private static Exercicio toEntity(ExercicioRequestDTO dto) {
        Exercicio ex = new Exercicio();
        applyDto(ex, dto);
        return ex;
    }

    private static void applyDto(Exercicio ex, ExercicioRequestDTO dto) {
        ex.setNome(dto.nome());
        ex.setLinkYoutube(dto.linkYoutube());
        ex.setDescricao(dto.descricao());
    }
}
