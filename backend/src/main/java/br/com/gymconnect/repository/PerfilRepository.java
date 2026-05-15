package br.com.gymconnect.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import br.com.gymconnect.model.PerfilModel;
import java.util.List;
import java.util.Optional;

@Repository
public interface PerfilRepository extends JpaRepository<PerfilModel, Long>{
    
    List<PerfilModel> findByIdPerfil(Long idPerfil);
    boolean existsByUsuario_IdUsuario(Long idUsuario);
    Optional<PerfilModel> findByUsuario_IdUsuario(Long idUsuario);
     
}
