import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';

/// Inter "normal" line height (ascender + descender ≈ 1.21 em).
const double _normal = 1.21;

/// Text styles for the auth screens (Figma STAR-APP). Every style sets
/// `height` and `letterSpacing: 0` so Material 3 defaults don't leak in.
abstract final class AuthTextStyles {
  /// Screen title: 23 SemiBold #000207.
  static const title = TextStyle(
    fontFamily: 'Inter',
    fontSize: 23,
    fontWeight: FontWeight.w600,
    height: _normal,
    letterSpacing: 0,
    color: AppColors.voidBlack,
  );

  /// Screen subtitle: 13 Regular, line height 18, #59606D.
  static const subtitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    letterSpacing: 0,
    color: AppColors.authTextSecondary,
  );

  /// Label above a field: 14 Regular #000207.
  static const label = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: _normal,
    letterSpacing: 0,
    color: AppColors.voidBlack,
  );

  /// Field value and placeholder: 13 Light #000207. Inter Light isn't bundled,
  /// so this renders with the nearest bundled weight (Regular).
  static const input = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w300,
    height: _normal,
    letterSpacing: 0,
    color: AppColors.voidBlack,
  );

  /// Body copy (divider label, footer prompt): 14 Regular #000207.
  static const body = label;

  /// Inline brand link (footer action): 14 Medium #001F6E.
  static const link = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: _normal,
    letterSpacing: 0,
    color: AppColors.brandNavy,
  );

  /// Small copy (checkbox labels): 12 Regular #000207.
  static const small = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: _normal,
    letterSpacing: 0,
    color: AppColors.voidBlack,
  );

  /// Small brand link ("Forgot Password?", "Terms"): 12 Medium #001F6E.
  static const smallLink = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: _normal,
    letterSpacing: 0,
    color: AppColors.brandNavy,
  );

  /// Button label: 16 Regular (colour set by the button).
  static const button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: _normal,
    letterSpacing: 0,
  );

  /// Social button label: 14 Regular #000207.
  static const social = label;

  /// Language chip label: 14 Regular #011C64.
  static const chip = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: _normal,
    letterSpacing: 0,
    color: AppColors.authChipText,
  );

  /// Field error message: 12 Regular #B10003.
  static const error = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0,
    color: AppColors.authError,
  );

  /// Welcome title: 30 SemiBold #001F6E.
  static const welcomeTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 30,
    fontWeight: FontWeight.w600,
    height: _normal,
    letterSpacing: 0,
    color: AppColors.brandNavy,
  );

  /// Welcome subtitle: 16 Regular #001F6E.
  static const welcomeSubtitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: _normal,
    letterSpacing: 0,
    color: AppColors.brandNavy,
  );
}

/// Title + optional subtitle block that opens every auth form (3px apart).
///
/// ```dart
/// const AuthHeading(
///   title: 'Welcome Back',
///   subtitle: 'Log in to continue your journey.',
/// )
/// ```
class AuthHeading extends StatelessWidget {
  const AuthHeading({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AuthTextStyles.title),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(subtitle!, style: AuthTextStyles.subtitle),
        ],
      ],
    );
  }
}

/// 14 Regular label shown 8px above a field. [AuthTextField] renders this
/// itself when given `label:`; use it directly for custom inputs.
class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: AuthTextStyles.label);
}

/// A tappable brand-coloured text link (no underline).
///
/// ```dart
/// AuthTextLink('Forgot Password?', small: true, onTap: () => context.push(AppRoutes.forgotPassword))
/// ```
class AuthTextLink extends StatelessWidget {
  const AuthTextLink(
    this.text, {
    super.key,
    required this.onTap,
    this.small = false,
    this.style,
  });

  final String text;
  final VoidCallback? onTap;

  /// 12 Medium instead of 14 Medium.
  final bool small;

  /// Overrides the default link style.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      link: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Text(
          text,
          style:
              style ?? (small ? AuthTextStyles.smallLink : AuthTextStyles.link),
        ),
      ),
    );
  }
}

/// Footer line: `prompt` then `action` — 14 Regular #000207 + 14 Medium #001F6E,
/// 3px apart, centred. Pass it to `AuthScaffold(footer: ...)`.
///
/// ```dart
/// AuthFooterLink(
///   prompt: 'Remember your password?',
///   action: 'Login here',
///   onTap: () => context.go(AppRoutes.signIn),
/// )
/// ```
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 3,
      children: [
        Text(prompt, style: AuthTextStyles.body),
        AuthTextLink(action, onTap: onTap),
      ],
    );
  }
}
