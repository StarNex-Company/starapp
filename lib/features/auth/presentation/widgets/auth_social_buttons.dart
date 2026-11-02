import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_assets.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_text.dart';

/// "Or continue with" divider + Google / Apple buttons (Login, Register).
///
/// Divider row, 24px gap, then two [AuthSocialButton]s 16px apart that share
/// the width (165 each at 345).
///
/// ```dart
/// AuthSocialRow(onGoogle: _google, onApple: _apple)
/// ```
class AuthSocialRow extends StatelessWidget {
  const AuthSocialRow({
    super.key,
    required this.onGoogle,
    required this.onApple,
    this.dividerLabel = 'Or continue with',
    this.showDivider = true,
  });

  final VoidCallback? onGoogle;
  final VoidCallback? onApple;
  final String dividerLabel;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDivider) ...[
          AuthOrDivider(label: dividerLabel),
          const SizedBox(height: 24),
        ],
        Row(
          children: [
            Expanded(
              child: AuthSocialButton(
                icon: AuthAssets.google,
                label: 'Google',
                onPressed: onGoogle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AuthSocialButton(
                icon: AuthAssets.apple,
                label: 'Apple',
                onPressed: onApple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Centred label between two 105px × 1px #000207 lines, 7px gaps
/// (lines shrink on narrow screens).
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key, this.label = 'Or continue with'});

  final String label;

  @override
  Widget build(BuildContext context) {
    const line = Flexible(
      child: SizedBox(
        width: 105,
        height: 1,
        child: ColoredBox(color: AppColors.voidBlack),
      ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        line,
        const SizedBox(width: 7),
        Text(label, style: AuthTextStyles.body, textAlign: TextAlign.center),
        const SizedBox(width: 7),
        line,
      ],
    );
  }
}

/// Outlined social sign-in button: 45 high, radius 13, 1.5px #000207 stroke,
/// transparent; 24px colour logo + 10px gap + 14 Regular #000207 label.
/// Fills the available width.
class AuthSocialButton extends StatefulWidget {
  const AuthSocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  /// SVG asset of the 24px logo ([AuthAssets.google] / [AuthAssets.apple]).
  final String icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  State<AuthSocialButton> createState() => _AuthSocialButtonState();
}

class _AuthSocialButtonState extends State<AuthSocialButton> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Continue with ${widget.label}',
      excludeSemantics: true,
      onTap: widget.onPressed,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => _set(true) : null,
          onTapUp: enabled ? (_) => _set(false) : null,
          onTapCancel: enabled ? () => _set(false) : null,
          onTap: widget.onPressed,
          child: Opacity(
            opacity: enabled ? 1 : 0.4,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              height: 45,
              decoration: BoxDecoration(
                color: _pressed
                    ? AppColors.voidBlack.withValues(alpha: 0.05)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.voidBlack, width: 1.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(widget.icon, width: 24, height: 24),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AuthTextStyles.social,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
