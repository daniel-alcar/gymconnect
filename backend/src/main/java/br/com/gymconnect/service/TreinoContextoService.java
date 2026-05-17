package br.com.gymconnect.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import br.com.gymconnect.model.Cronograma;
import br.com.gymconnect.model.CronogramaExercicio;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.repository.CronogramaRepository;


@Service
public class TreinoContextoService {

    private static final int MAX_CONTEXT_CHARS = 12_000;

    private final CronogramaRepository cronogramaRepository;

    public TreinoContextoService(CronogramaRepository cronogramaRepository) {
        this.cronogramaRepository = cronogramaRepository;
    }

    @Transactional(readOnly = true)
    public String montarResumoParaPrompt(Usuario aluno) {
        List<Cronograma> cronogramas = cronogramaRepository.findByAlunoIdUsuario(aluno.getIdUsuario());
        if (cronogramas.isEmpty()) {
            return "O aluno ainda não possui cronograma cadastrado no sistema.";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("Nome do aluno: ").append(aluno.getNome()).append('\n');
        for (Cronograma c : cronogramas) {
            sb.append("\nCronograma id ").append(c.getIdCronograma());
            if (c.getDiasTotais() != null) {
                sb.append(", dias totais: ").append(c.getDiasTotais());
            }
            sb.append('\n');
            if (c.getExercicio() == null || c.getExercicio().isEmpty()) {
                sb.append("  (sem exercícios vinculados)\n");
                continue;
            }
            for (CronogramaExercicio ce : c.getExercicio()) {
                sb.append("  - ");
                if (ce.getExercicio() != null) {
                    sb.append(ce.getExercicio().getNome());
                } else {
                    sb.append("(exercício)");
                }
                if (ce.getDiaSemana() != null) {
                    sb.append(" | dia: ").append(ce.getDiaSemana());
                }
                if (ce.getSerie() != null) {
                    sb.append(" | séries: ").append(ce.getSerie());
                }
                if (ce.getRepeticao() != null) {
                    sb.append(" | repetições: ").append(ce.getRepeticao());
                }
                if (ce.getCarga() != null) {
                    sb.append(" | carga: ").append(ce.getCarga());
                }
                sb.append('\n');
            }
        }

        String full = sb.toString();
        if (full.length() > MAX_CONTEXT_CHARS) {
            return full.substring(0, MAX_CONTEXT_CHARS) + "\n...[contexto truncado por limite de tamanho]";
        }
        return full;
    }
}
