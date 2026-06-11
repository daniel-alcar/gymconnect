package br.com.gymconnect.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import br.com.gymconnect.model.RegistroDiarioModel;
import br.com.gymconnect.model.ResponseModel;
import br.com.gymconnect.repository.RegistroDiarioRepository;

@Service
public class RegistroService {
    
    @Autowired
    private RegistroDiarioRepository rdm;

    public ResponseEntity<?> cadastrar(RegistroDiarioModel rd){
        if (rd.getExecucao() == null) {
            ResponseModel rm = new ResponseModel();
            rm.setMensagem("Execução obrigatória.");
            return new ResponseEntity<>(rm, HttpStatus.BAD_REQUEST);
        }
        return new ResponseEntity<>(rdm.save(rd), HttpStatus.OK);
    }
}
