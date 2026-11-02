import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/auth/data/provider/auth_providers.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_kit.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Register, step 1 of 4 (Figma `216:315` unchecked, `232:767` checked,
/// `232:851` Continue tapped without accepting the terms).
///
/// Continue records the name and email in `registrationProvider`, asks the
/// auth repository to send the verification code and pushes the OTP step.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _agreed = false;
  bool _termsWarning = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!_agreed) {
      setState(() => _termsWarning = true);
      return;
    }
    if (!valid) return;
    final fullName = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    ref
        .read(registrationProvider.notifier)
        .setAccount(fullName: fullName, email: email);
    await ref
        .read(authRepositoryProvider)
        .signUp(fullName: fullName, email: email);
    if (!mounted) return;
    context.push(AppRoutes.otp);
  }

  // The prototype skips straight to Interests after Google / Apple.
  void _socialSignUp() => context.push(AppRoutes.registerInterests);

  void _comingSoon() => showStarToast(context, 'Coming soon');

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      step: 1,
      footer: AuthFooterLink(
        prompt: 'Already have an account?',
        action: 'Login here',
        onTap: () => context.go(AppRoutes.signIn),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeading(
              title: 'Create Your Account',
              subtitle: 'Join creators sharing their talent and creativity.',
            ),
            const SizedBox(height: 20),
            AuthTextField.name(
              label: 'Full Name',
              hint: 'Enter your full name',
              controller: _nameCtrl,
              validator: AuthValidators.fullName,
            ),
            const SizedBox(height: 20),
            AuthTextField.email(
              label: 'Email Address',
              hint: 'Enter your email address',
              controller: _emailCtrl,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: AuthCheck(
                value: _agreed,
                warning: _termsWarning,
                onChanged: (v) => setState(() {
                  _agreed = v;
                  _termsWarning = false;
                }),
                label: _TermsLabel(
                  onTerms: _comingSoon,
                  onPrivacy: _comingSoon,
                ),
              ),
            ),
            const SizedBox(height: 25),
            AuthPrimaryButton(label: 'Continue with Email', onPressed: _submit),
            const SizedBox(height: 20),
            AuthSocialRow(onGoogle: _socialSignUp, onApple: _socialSignUp),
          ],
        ),
      ),
    );
  }
}

/// "By continuing, you agree to our Terms & Privacy Policy" — 12 Regular
/// #000207 (from [AuthCheck]) with 12 Medium #001F6E tappable links.
class _TermsLabel extends StatefulWidget {
  const _TermsLabel({required this.onTerms, required this.onPrivacy});

  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  State<_TermsLabel> createState() => _TermsLabelState();
}

class _TermsLabelState extends State<_TermsLabel> {
  late final _terms = TapGestureRecognizer()..onTap = () => widget.onTerms();
  late final _privacy = TapGestureRecognizer()
    ..onTap = () => widget.onPrivacy();

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms',
            style: AuthTextStyles.smallLink,
            recognizer: _terms,
          ),
          const TextSpan(text: ' & '),
          TextSpan(
            text: 'Privacy Policy',
            style: AuthTextStyles.smallLink,
            recognizer: _privacy,
          ),
        ],
      ),
    );
  }
}
