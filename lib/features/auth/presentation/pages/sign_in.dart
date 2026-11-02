import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/auth/data/provider/auth_providers.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_kit.dart';

/// Login (Figma `121:150`).
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authRepositoryProvider)
        .signIn(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          rememberMe: _rememberMe,
        );
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  // The prototype signs straight in with Google / Apple.
  void _socialSignIn() => context.go(AppRoutes.home);

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      footer: AuthFooterLink(
        prompt: 'Don’t have an account?',
        action: 'Register here',
        onTap: () => context.go(AppRoutes.signUp),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeading(
              title: 'Welcome Back',
              subtitle: 'Log in to continue your journey.',
            ),
            const SizedBox(height: 20),
            AuthTextField.email(
              label: 'Email Address',
              hint: 'Enter your email address',
              controller: _emailCtrl,
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 20),
            AuthPasswordField(
              label: 'Password',
              hint: 'Enter your password',
              controller: _passCtrl,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: AuthValidators.password,
            ),
            const SizedBox(height: 20),
            _RememberRow(
              rememberMe: _rememberMe,
              onRememberChanged: (v) => setState(() => _rememberMe = v),
              onForgotPassword: () => context.push(AppRoutes.forgotPassword),
            ),
            const SizedBox(height: 25),
            AuthPrimaryButton(label: 'Log In', onPressed: _submit),
            const SizedBox(height: 20),
            AuthSocialRow(onGoogle: _socialSignIn, onApple: _socialSignIn),
          ],
        ),
      ),
    );
  }
}

/// "Remember me" check (left) and "Forgot Password?" link (right), bottom
/// aligned like the design's row.
class _RememberRow extends StatelessWidget {
  const _RememberRow({
    required this.rememberMe,
    required this.onRememberChanged,
    required this.onForgotPassword,
  });

  final bool rememberMe;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: AuthCheck(
            value: rememberMe,
            onChanged: onRememberChanged,
            label: const Text('Remember me'),
          ),
        ),
        const SizedBox(width: 12),
        AuthTextLink('Forgot Password?', small: true, onTap: onForgotPassword),
      ],
    );
  }
}
