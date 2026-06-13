package br.com.gymconnect.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import br.com.gymconnect.exception.BadRequestException;
import br.com.gymconnect.model.RegistroDiarioModel;
import br.com.gymconnect.repository.RegistroDiarioRepository;

@Service
public class RegistroService {

    @Autowired
    private RegistroDiarioRepository rdm;

    public RegistroDiarioModel cadastrar(RegistroDiarioModel registro) {
        if (registro.getExecucao() == null) {
            throw new BadRequestException("Execução obrigatória.");
        }
        return rdm.save(registro);
    }
}
