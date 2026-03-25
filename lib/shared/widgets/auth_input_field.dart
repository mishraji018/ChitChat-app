import 'package:flutter/material.dart';

class AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int? maxLength;
  final String? labelText;
  final bool enabled;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.prefixText,
    this.prefixStyle,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLength,
    this.labelText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      maxLength: maxLength,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
        fillColor: colorScheme.surface,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
        prefixText: prefixText,
        prefixStyle: prefixStyle ?? TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: colorScheme.primary) : null,
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: onToggleObscure,
              )
            : null,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
