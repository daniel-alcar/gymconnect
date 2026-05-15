package br.com.gymconnect.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import br.com.gymconnect.model.PerfilModel;
import br.com.gymconnect.model.ResponseModel;
import br.com.gymconnect.repository.PerfilRepository;

@Service
public class PerfilService {

    @Autowired
    private ResponseModel rm;

    @Autowired
    private PerfilRepository pr;

    public ResponseEntity<?> cadastrar(PerfilModel pp){

        if (pp.getAltura() == null || pp.getAltura() <= 0.00) {
            return new ResponseEntity<>(rm, HttpStatus.BAD_REQUEST);
        } else if(pp.getDataNascimento() == null) {
            return new ResponseEntity<>(rm, HttpStatus.BAD_REQUEST);
        } else if(pp.getObjetivo().isEmpty()){
            return new ResponseEntity<>(rm, HttpStatus.BAD_REQUEST);
        }else {
            return new ResponseEntity<>(pr.save(pp), HttpStatus.OK);
        }
    }
}
