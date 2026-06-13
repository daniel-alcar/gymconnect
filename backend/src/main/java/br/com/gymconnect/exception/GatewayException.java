package br.com.gymconnect.exception;

import org.springframework.http.HttpStatus;

public class GatewayException extends ApiException {

    public GatewayException(String message) {
        super(HttpStatus.BAD_GATEWAY, message);
    }

    public GatewayException(String message, Throwable cause) {
        super(HttpStatus.BAD_GATEWAY, message);
        initCause(cause);
    }
}
