package br.com.gymconnect.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import br.com.gymconnect.model.RegistroDiarioModel;
import java.util.List;

@Repository
public interface RegistroDiarioRepository extends JpaRepository<RegistroDiarioModel, Long> {

    List<RegistroDiarioModel> findByIdRegistro(Long idRegistro);
}
