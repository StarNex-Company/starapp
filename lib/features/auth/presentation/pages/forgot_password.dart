import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/auth/data/provider/auth_providers.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_kit.dart';

/// Forgot Password (Figma `589:1341`). "Send Code" asks the auth repository
/// for a reset code and pushes the OTP step in reset mode.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authRepositoryProvider)
        .requestPasswordReset(_emailCtrl.text.trim());
    if (!mounted) return;
    context.push('${AppRoutes.otp}?mode=reset');
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      footer: AuthFooterLink(
        prompt: 'Remember your password?',
        action: 'Login here',
        onTap: () => context.go(AppRoutes.signIn),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeading(
              title: 'Forgot Your Password?',
              subtitle:
                  "Enter the email address associated with your account and we'll send you a verification code.",
            ),
            const SizedBox(height: 30),
            AuthTextField.email(
              label: 'Email Address',
              hint: 'Enter your email address',
              controller: _emailCtrl,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 25),
            AuthPrimaryButton(label: 'Send Code', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
