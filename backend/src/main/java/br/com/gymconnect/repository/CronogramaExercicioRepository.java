package br.com.gymconnect.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import br.com.gymconnect.model.CronogramaExercicio;

@Repository
public interface CronogramaExercicioRepository extends JpaRepository<CronogramaExercicio, Long>{
    
    List<CronogramaExercicio> findByCronograma_Aluno_IdUsuario(Long idAluno);

    boolean existsByExercicio_IdExercicio(Long idExercicio);
}
