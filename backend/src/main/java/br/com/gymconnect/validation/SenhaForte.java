package br.com.gymconnect.validation;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

@Documented
@Constraint(validatedBy = SenhaForteValidator.class)
@Target({ ElementType.FIELD, ElementType.PARAMETER, ElementType.RECORD_COMPONENT })
@Retention(RetentionPolicy.RUNTIME)
public @interface SenhaForte {

    String message() default "Senha deve ter no mínimo 8 caracteres, com letra e número.";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
