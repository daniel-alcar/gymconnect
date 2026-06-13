package br.com.gymconnect.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import br.com.gymconnect.exception.BadRequestException;
import br.com.gymconnect.exception.ResourceNotFoundException;
import br.com.gymconnect.model.Cronograma;
import br.com.gymconnect.model.CronogramaExercicio;
import br.com.gymconnect.model.Exercicio;
import br.com.gymconnect.repository.CronogramaExercicioRepository;
import br.com.gymconnect.repository.CronogramaRepository;
import br.com.gymconnect.repository.ExercicioRepository;

@Service
public class CronogramaExercicioService {

    @Autowired
    private CronogramaExercicioRepository csr;

    @Autowired
    private CronogramaRepository cr;

    @Autowired
    private ExercicioRepository exr;

    public CronogramaExercicio cadastrar(CronogramaExercicio cronogExerc) {
        Cronograma cronograma = resolveCronograma(cronogExerc);
        Exercicio exercicio = resolveExercicio(cronogExerc);

        cronogExerc.setCronograma(cronograma);
        cronogExerc.setExercicio(exercicio);
        return csr.save(cronogExerc);
    }

    public void remover(Long idCronogramaExercicio) {
        CronogramaExercicio vinculo = csr.findById(idCronogramaExercicio)
                .orElseThrow(() -> new ResourceNotFoundException("Cronograma de exercicios não encontrado!"));
        csr.delete(vinculo);
    }

    public List<CronogramaExercicio> listar(Long idAluno) {
        return csr.findByCronograma_Aluno_IdUsuario(idAluno);
    }

    public CronogramaExercicio atualizar(Long idCronogramaExercicio, CronogramaExercicio dados) {
        CronogramaExercicio existente = csr.findById(idCronogramaExercicio)
                .orElseThrow(() -> new ResourceNotFoundException("Cronograma de exercicios não encontrado!"));

        Cronograma cronograma = resolveCronograma(dados);
        Exercicio exercicio = resolveExercicio(dados);

        existente.setCronograma(cronograma);
        existente.setExercicio(exercicio);
        existente.setDiaSemana(dados.getDiaSemana());
        existente.setSerie(dados.getSerie());
        existente.setRepeticao(dados.getRepeticao());
        existente.setCarga(dados.getCarga());

        return csr.save(existente);
    }

    private Cronograma resolveCronograma(CronogramaExercicio dto) {
        if (dto.getCronograma() == null || dto.getCronograma().getIdCronograma() == null) {
            throw new BadRequestException("Campo cronograma precisa ser preenchido!");
        }
        return cr.findById(dto.getCronograma().getIdCronograma())
                .orElseThrow(() -> new BadRequestException("Campo cronograma precisa ser preenchido!"));
    }

    private Exercicio resolveExercicio(CronogramaExercicio dto) {
        if (dto.getExercicio() == null || dto.getExercicio().getIdExercicio() == null) {
            throw new BadRequestException("Exercicio não preenchido!");
        }
        return exr.findById(dto.getExercicio().getIdExercicio())
                .orElseThrow(() -> new BadRequestException("Exercicio não preenchido!"));
    }
}
