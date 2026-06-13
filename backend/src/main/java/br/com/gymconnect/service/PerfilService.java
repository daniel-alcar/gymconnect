package br.com.gymconnect.service;

import java.sql.Date;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import br.com.gymconnect.dto.PerfilRequestDTO;
import br.com.gymconnect.model.PerfilModel;
import br.com.gymconnect.model.Usuario;
import br.com.gymconnect.repository.PerfilRepository;

@Service
public class PerfilService {

    @Autowired
    private PerfilRepository pr;

    public PerfilModel cadastrar(PerfilRequestDTO dto, Usuario usuario) {
        PerfilModel perfil = new PerfilModel();
        perfil.setUsuario(usuario);
        perfil.setDataNascimento(Date.valueOf(dto.dataNascimento()));
        perfil.setAltura(dto.altura());
        perfil.setObjetivo(dto.objetivo());
        return pr.save(perfil);
    }
}
