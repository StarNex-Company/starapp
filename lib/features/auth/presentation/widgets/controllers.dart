import 'package:flutter/material.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_text_field.dart';

// Legacy field widgets, now thin wrappers over the design-system
// [AuthTextField] / [AuthPasswordField] so older screens pick up the Figma
// styling. New code should use those widgets directly (they also take
// `label:` and `hint:`).

// ── Full Name field ────────────────────────────────────────────────────────────

class FullNameField extends StatelessWidget {
  const FullNameField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.validator,
  });

  final TextEditingController controller;
  final TextInputAction textInputAction;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return AuthTextField.name(
      controller: controller,
      hint: 'Enter your full name',
      textInputAction: textInputAction,
      validator: validator ?? AuthValidators.fullName,
    );
  }
}

// ── Email field ────────────────────────────────────────────────────────────────

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.validator,
  });

  final TextEditingController controller;
  final TextInputAction textInputAction;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return AuthTextField.email(
      controller: controller,
      hint: 'Enter your email address',
      textInputAction: textInputAction,
      validator: validator ?? AuthValidators.email,
    );
  }
}

// ── Password field ─────────────────────────────────────────────────────────────

class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
    this.validator,
  });

  final TextEditingController controller;

  /// Shown as the placeholder (there is no floating label in the design).
  final String label;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return AuthPasswordField(
      controller: controller,
      hint: label,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator ?? AuthValidators.password,
    );
  }
}
