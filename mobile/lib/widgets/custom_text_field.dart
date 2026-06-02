import 'package:flutter/material.dart';

/// Campo de texto padronizado com label, ícone e validação.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icone;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final String? hint;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icone,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.hint,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icone != null ? Icon(icone) : null,
      ),
    );
  }
}
