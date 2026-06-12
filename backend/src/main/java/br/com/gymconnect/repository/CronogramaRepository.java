package br.com.gymconnect.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import br.com.gymconnect.model.Cronograma;

@Repository
public interface CronogramaRepository extends JpaRepository<Cronograma, Long>{
    
    List<Cronograma> findByAlunoIdUsuario(Long idUsuario);

    boolean existsByAlunoIdUsuario(Long idUsuario);
}
