import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/auth/data/provider/auth_providers.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_kit.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_success_dialog.dart';

/// Create New Password (Figma "New Password" `589:1772`), the last step of
/// the password reset. "Update Password" shows the "Password Updated" success
/// card, whose button goes to Login. The password is saved through the auth
/// repository.
class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool get _hasLength => _passCtrl.text.length >= 8;
  bool get _hasLetterNum =>
      RegExp(r'[a-zA-Z]').hasMatch(_passCtrl.text) &&
      RegExp(r'[0-9]').hasMatch(_passCtrl.text);
  bool get _matches =>
      _confirmCtrl.text.isNotEmpty && _passCtrl.text == _confirmCtrl.text;

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(_refresh);
    _confirmCtrl.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validatePassword(String? v) {
    final base = AuthValidators.password(v);
    if (base != null) return base;
    if (!_hasLetterNum) return 'Use both letters and numbers';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Confirm your password';
    if (v != _passCtrl.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    await ref.read(authRepositoryProvider).resetPassword(_passCtrl.text);
    if (!mounted) return;
    await showAuthSuccessDialog(
      context,
      title: 'Password Updated',
      message:
          'Your password has been successfully changed. '
          'You can now log in with your new password.',
      actionLabel: 'Continue to Login',
      onAction: () => context.go(AppRoutes.signIn),
    );
  }

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
              title: 'Create New Password',
              subtitle: 'Choose a strong password to keep your account secure.',
            ),
            const SizedBox(height: 20),
            AuthPasswordField(
              label: 'New Password',
              hint: 'Enter your new password',
              controller: _passCtrl,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: _validatePassword,
            ),
            const SizedBox(height: 20),
            AuthPasswordField(
              label: 'Confirm Password',
              hint: 'Re-enter your new password',
              controller: _confirmCtrl,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => _submit(),
              validator: _validateConfirm,
            ),
            const SizedBox(height: 11),
            // Requirement hints: wrap onto a second line when they don't fit.
            Wrap(
              spacing: 17,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Hint(label: 'At least 8 characters', met: _hasLength),
                _Hint(
                  label: 'Contains letters and numbers',
                  met: _hasLetterNum,
                ),
                _Hint(label: 'Same Password', met: _matches),
              ],
            ),
            const SizedBox(height: 25),
            AuthPrimaryButton(label: 'Update Password', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}

/// Unmet hint text (text/secondary #7C7D80).
const _hintUnmet = Color(0xFF7C7D80);

/// One requirement: 14px check + 8 Regular label. Met → green check,
/// #000207 text; unmet → pale check, #7C7D80 text, 65% opacity.
class _Hint extends StatelessWidget {
  const _Hint({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: ${met ? 'met' : 'not met'}',
      excludeSemantics: true,
      child: Opacity(
        opacity: met ? 1 : 0.65,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              met
                  ? 'assets/vectors/auth_hint_check.svg'
                  : 'assets/vectors/auth_hint_check_off.svg',
              width: 14,
              height: 14,
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 8,
                fontWeight: FontWeight.w400,
                height: 1.21,
                letterSpacing: 0,
                color: met ? AppColors.voidBlack : _hintUnmet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
