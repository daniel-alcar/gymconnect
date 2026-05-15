package br.com.gymconnect.model;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter
public class StatusExecucaoConverter implements AttributeConverter<StatusExecucao, String> {

    @Override
    public String convertToDatabaseColumn(StatusExecucao attribute) {
        if (attribute == null) {
            return null;
        }
        return attribute == StatusExecucao.FEITO ? "FEITO" : "NAO FEITO";
    }

    @Override
    public StatusExecucao convertToEntityAttribute(String dbData) {
        if (dbData == null) {
            return null;
        }
        if ("FEITO".equals(dbData)) {
            return StatusExecucao.FEITO;
        }
        if ("NAO FEITO".equals(dbData)) {
            return StatusExecucao.NAO_FEITO;
        }
        throw new IllegalArgumentException("Status de execução inválido: " + dbData);
    }
}
