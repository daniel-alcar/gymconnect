package br.com.gymconnect.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

public class SenhaForteValidator implements ConstraintValidator<SenhaForte, String> {

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (value == null) {
            return false;
        }
        if (value.length() < 8) {
            return false;
        }
        boolean temLetra = value.chars().anyMatch(Character::isLetter);
        boolean temNumero = value.chars().anyMatch(Character::isDigit);
        return temLetra && temNumero;
    }
}
