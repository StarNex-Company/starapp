import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/auth/data/provider/auth_providers.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_kit.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Which flow the [OtpScreen] verifies.
enum OtpMode {
  /// Registration, step 2 of 4 (Figma "OTP" `232:666`): continues to the
  /// password step.
  register,

  /// Password reset (Figma "Verify Email" `589:1422`), reached from Forgot
  /// Password with `/otp?mode=reset`: continues to New Password.
  reset;

  /// Maps the route's `mode` query parameter: `reset` → [reset], anything
  /// else (or none) → [register].
  static OtpMode fromQuery(String? value) =>
      value == 'reset' ? OtpMode.reset : OtpMode.register;
}

/// Email verification code entry, in registration or password-reset [mode].
///
/// Six 45×45 code boxes, "Change Email" (back to the previous screen) and a
/// 59s "Resend Code" countdown. The button enables once all six digits are
/// in. Typing advances to the next box, backspace in an empty box goes back
/// (soft keyboards too), and pasting / autofilling a code fills every box.
/// The code is checked, and new codes are sent, through the auth repository.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, this.mode = OtpMode.register});

  final OtpMode mode;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _length = 6;
  static const _resendSeconds = 59;

  /// Zero-width placeholder kept in front of every box's digit, so backspace
  /// in an empty box still edits the text (soft keyboards send no key event
  /// for it) and can move focus back.
  static const _zwsp = '​';

  static final _nonDigit = RegExp(r'[^0-9]');

  late final List<TextEditingController> _controllers = List.generate(
    _length,
    (_) => TextEditingController(text: _zwsp),
  );

  /// Each box's text as of its last change (onChanged only gives the new one).
  late final List<String> _lastText = List.filled(_length, _zwsp);

  late final List<FocusNode> _focusNodes = List.generate(
    _length,
    (i) => FocusNode(debugLabel: 'otp-$i')..addListener(() => _onFocus(i)),
  );

  int _seconds = _resendSeconds;
  Timer? _timer;

  bool get _isReset => widget.mode == OtpMode.reset;

  String _digitAt(int i) => _controllers[i].text.replaceAll(_nonDigit, '');

  String get _code => List.generate(_length, _digitAt).join();

  bool get _isComplete => _code.length == _length;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ── Resend countdown ───────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _seconds = _resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _seconds--);
      if (_seconds <= 0) t.cancel();
    });
  }

  Future<void> _resend() async {
    if (_seconds > 0) return;
    setState(_startTimer);
    await ref.read(authRepositoryProvider).resendCode();
    if (!mounted) return;
    showStarToast(context, 'New code sent to your email');
  }

  // ── Code boxes ─────────────────────────────────────────────────────────

  void _onFocus(int i) {
    // Keep the caret after the placeholder so backspace always deletes it.
    if (_focusNodes[i].hasFocus) _setDigit(i, _digitAt(i));
    if (mounted) setState(() {}); // focused-box fill
  }

  void _setDigit(int i, String digit) {
    final text = '$_zwsp$digit';
    _lastText[i] = text;
    _controllers[i].value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _focus(int i) => _focusNodes[i].requestFocus();

  void _onChanged(int i, String value) {
    final before = _lastText[i];
    final inserted = _insertedText(before, value).replaceAll(_nonDigit, '');

    if (inserted.isEmpty) {
      // A deletion. Removing the placeholder of an already empty box is a
      // backspace there: step back and clear the previous digit.
      final wasEmpty = before.replaceAll(_nonDigit, '').isEmpty;
      _setDigit(i, '');
      if (wasEmpty && !value.contains(_zwsp) && i > 0) {
        _setDigit(i - 1, '');
        _focus(i - 1);
      }
    } else if (inserted.length == 1) {
      _setDigit(i, inserted);
      _advanceFrom(i);
    } else {
      _paste(i, inserted);
    }
    setState(() {});
  }

  /// The text that replaced the changed range of [before] in [after].
  static String _insertedText(String before, String after) {
    var p = 0;
    while (p < before.length && p < after.length && before[p] == after[p]) {
      p++;
    }
    var s = 0;
    while (s < before.length - p &&
        s < after.length - p &&
        before[before.length - 1 - s] == after[after.length - 1 - s]) {
      s++;
    }
    return after.substring(p, after.length - s);
  }

  /// A full code fills every box; a shorter one fills from box [i] onward.
  void _paste(int i, String digits) {
    final start = digits.length >= _length ? 0 : i;
    final count = (_length - start).clamp(0, digits.length);
    for (var k = 0; k < count; k++) {
      _setDigit(start + k, digits[k]);
    }
    _advanceFrom(start + count - 1);
  }

  void _advanceFrom(int i) {
    if (_isComplete) {
      FocusManager.instance.primaryFocus?.unfocus();
    } else if (i < _length - 1) {
      _focus(i + 1);
    }
  }

  // ── Actions ────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_isComplete) return;
    await ref.read(authRepositoryProvider).verifyOtp(_code);
    if (!mounted) return;
    context.push(_isReset ? AppRoutes.newPassword : AppRoutes.registerPassword);
  }

  void _changeEmail() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(_isReset ? AppRoutes.forgotPassword : AppRoutes.signUp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      step: _isReset ? null : 2,
      footer: AuthFooterLink(
        prompt: _isReset
            ? 'Remember your password?'
            : 'Already have an account?',
        action: 'Login here',
        onTap: () => context.go(AppRoutes.signIn),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeading(
            title: _isReset ? 'Verify Your Account' : 'Verify Your Email',
            subtitle: 'Enter the verification code sent to your email address.',
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 45px boxes, 15px apart on the 345 design width; they
                // shrink (keeping ≥8px gaps) on narrower screens.
                final size = ((constraints.maxWidth - 5 * 8) / _length).clamp(
                  0.0,
                  45.0,
                );
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    _length,
                    (i) => _OtpBox(
                      size: size,
                      index: i,
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      autofocus: i == 0,
                      onChanged: (v) => _onChanged(i, v),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 12,
            // Both links shrink rather than overflow at large text sizes.
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AuthTextLink(
                    'Change Email',
                    style: AuthTextStyles.smallLink.copyWith(
                      color: AppColors.voidBlack,
                    ),
                    onTap: _changeEmail,
                  ),
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: AuthTextLink(
                    _seconds > 0 ? 'Resend Code (${_seconds}s)' : 'Resend Code',
                    small: true,
                    onTap: _seconds > 0 ? null : _resend,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          AuthPrimaryButton(
            label: _isReset ? 'Verify' : 'Continue',
            size: AuthButtonSize.compact,
            onPressed: _isComplete ? _submit : null,
          ),
        ],
      ),
    );
  }
}

/// Focused box fill (backgrounds/secondary-elevated #F2F2F7).
const _boxFocusedFill = Color(0xFFF2F2F7);

/// One code digit: 45×45, radius 12, 1px #000207 border, #F7F7F8 fill
/// (#F2F2F7 while focused).
class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.size,
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.autofocus = false,
  });

  final double size;
  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  static const _digitStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.21,
    letterSpacing: 0,
    color: AppColors.voidBlack,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: focusNode.requestFocus,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: focusNode.hasFocus ? _boxFocusedFill : AppColors.lunarWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.voidBlack),
        ),
        child: Semantics(
          label: 'Digit ${index + 1} of 6',
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            onChanged: onChanged,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            autofillHints: index == 0
                ? const [AutofillHints.oneTimeCode]
                : null,
            // Caret after the placeholder (see _zwsp) after a tap too.
            onTap: () => controller.selection = TextSelection.collapsed(
              offset: controller.text.length,
            ),
            cursorColor: AppColors.brandNavy,
            cursorHeight: 20,
            style: _digitStyle,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9​]')),
            ],
            decoration: const InputDecoration.collapsed(hintText: null),
          ),
        ),
      ),
    );
  }
}
