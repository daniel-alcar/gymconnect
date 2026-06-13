package br.com.gymconnect.model;

import lombok.Getter;
import lombok.Setter;

/**
 * @deprecated Use {@link br.com.gymconnect.dto.ApiMessageResponse} (record imutável).
 */
@Deprecated
@Getter
@Setter
public class ResponseModel {

    private String mensagem;
}
