package br.com.gymconnect.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import br.com.gymconnect.model.CronogramaExecucao;

@Repository
public interface CronogramaExecucaoRepository extends JpaRepository<CronogramaExecucao, Long> {

    List<CronogramaExecucao> findByCronograma_IdCronograma(Long idCronograma);
}
