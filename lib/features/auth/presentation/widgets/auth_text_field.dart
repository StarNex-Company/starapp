import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_assets.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_text.dart';

const double _fieldHeight = 45;
const double _iconSize = 22;
const double _sidePadding = 15;
const double _iconGap = 8;

/// Bordered auth input (Login / Register / Forgot Password fields).
///
/// 45 high, radius 12, fill #F7F7F8, 1px #000207 border; optional 22px
/// leading icon 15px from the left with the text starting at x+45; value and
/// placeholder 13 Light #000207; optional [trailing] widget (eye toggle, green
/// check, chevron…) 15px from the right; no floating label. If [label] is set
/// it is drawn 8px above the box (14 Regular).
///
/// States: focused → 1.5px #001F6E border; error (from [validator] inside a
/// `Form`, or [errorText]) → #B10003 border + 12px message below; disabled →
/// 40% border/text.
///
/// For pickers (date of birth, country…) use `readOnly: true` + [onTap].
///
/// ```dart
/// AuthTextField.email(
///   label: 'Email Address',
///   hint: 'Enter your email address',
///   controller: _emailCtrl,
///   validator: AuthValidators.email,
/// )
/// AuthTextField(
///   label: 'Date of Birth',
///   icon: 'assets/vectors/auth_calendar.svg',
///   hint: 'DD/MM/YYYY',
///   readOnly: true,
///   onTap: _pickDate,
///   trailing: SvgPicture.asset(AuthAssets.fieldCheck, width: 22, height: 22),
/// )
/// ```
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.icon,
    this.leading,
    this.trailing,
    this.onTrailingTap,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    this.validator,
    this.autovalidateMode,
    this.errorText,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.focusNode,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.style,
  });

  /// Full name field: person icon, words capitalisation, name autofill.
  const AuthTextField.name({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.trailing,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.autovalidateMode,
    this.errorText,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.enabled = true,
    this.autofocus = false,
  }) : icon = AuthAssets.person,
       leading = null,
       onTrailingTap = null,
       obscureText = false,
       keyboardType = TextInputType.name,
       textCapitalization = TextCapitalization.words,
       autofillHints = const [AutofillHints.name],
       inputFormatters = null,
       maxLength = null,
       onTap = null,
       readOnly = false,
       style = null;

  /// Email field: mail icon, email keyboard, email autofill.
  const AuthTextField.email({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.trailing,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.autovalidateMode,
    this.errorText,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.enabled = true,
    this.autofocus = false,
  }) : icon = AuthAssets.mail,
       leading = null,
       onTrailingTap = null,
       obscureText = false,
       keyboardType = TextInputType.emailAddress,
       textCapitalization = TextCapitalization.none,
       autofillHints = const [AutofillHints.email],
       inputFormatters = null,
       maxLength = null,
       onTap = null,
       readOnly = false,
       style = null;

  final TextEditingController? controller;
  final String? initialValue;

  /// 14 Regular label 8px above the box.
  final String? label;

  /// Placeholder (13 Light #000207, like the value).
  final String? hint;

  /// SVG asset for the 22px leading icon (see [AuthAssets]).
  final String? icon;

  /// Custom leading widget (laid out in the same 22px slot); wins over [icon].
  final Widget? leading;

  /// Trailing widget, 15px from the right edge (≈22px tall).
  final Widget? trailing;

  /// Makes the whole trailing area (45px tall, incl. its 8/15px padding)
  /// tappable — eye toggles, dropdown chevrons, clear buttons.
  final VoidCallback? onTrailingTap;

  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;

  /// Forces the error state (e.g. a server error) regardless of [validator].
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final GestureTapCallback? onTap;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;

  /// Overrides the value text style (the password field uses this for dots).
  final TextStyle? style;

  static OutlineInputBorder _border(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final Widget? leadingWidget =
        leading ??
        (icon == null
            ? null
            : SvgPicture.asset(icon!, width: _iconSize, height: _iconSize));

    // Vertical padding that centres one 13px line in the 45px box.
    final lineHeight =
        AuthTextStyles.input.fontSize! * AuthTextStyles.input.height!;
    final vPad = (_fieldHeight - lineHeight) / 2;

    // InputDecorator adds its own gaps (outline/filled: 4px inside the content
    // padding; Material 3: 4px between prefix/suffix icons and the text), so
    // subtract them to land on the design's 15px / 8px spacing.
    const inputGap = 4.0;
    final iconGap = Theme.of(context).useMaterial3 ? 4.0 : 0.0;

    final field = TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      validator: validator,
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
      readOnly: readOnly,
      enabled: enabled,
      autofocus: autofocus,
      style: style ?? AuthTextStyles.input,
      cursorColor: AppColors.brandNavy,
      cursorHeight: 16,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.lunarWhite,
        visualDensity: VisualDensity.standard,
        hintText: hint,
        hintStyle: AuthTextStyles.input,
        hintMaxLines: 1,
        errorText: errorText,
        errorStyle: AuthTextStyles.error,
        errorMaxLines: 3,
        counterText: '',
        contentPadding: EdgeInsets.fromLTRB(
          leadingWidget == null ? _sidePadding - inputGap : 0,
          vPad,
          trailing == null ? _sidePadding - inputGap : 0,
          vPad,
        ),
        prefixIcon: leadingWidget == null
            ? null
            : Padding(
                padding: EdgeInsets.only(
                  left: _sidePadding,
                  right: _iconGap - iconGap,
                ),
                child: SizedBox.square(
                  dimension: _iconSize,
                  child: leadingWidget,
                ),
              ),
        prefixIconConstraints: BoxConstraints.tightFor(
          width: _sidePadding + _iconSize + _iconGap - iconGap,
          height: _fieldHeight,
        ),
        suffixIcon: trailing == null
            ? null
            : _Trailing(
                onTap: onTrailingTap,
                leftPadding: _iconGap - iconGap,
                child: trailing!,
              ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: _fieldHeight,
          maxHeight: _fieldHeight,
        ),
        border: _border(AppColors.voidBlack, 1),
        enabledBorder: _border(AppColors.voidBlack, 1),
        focusedBorder: _border(AppColors.brandNavy, 1.5),
        errorBorder: _border(AppColors.authError, 1),
        focusedErrorBorder: _border(AppColors.authError, 1.5),
        disabledBorder: _border(AppColors.voidBlack.withValues(alpha: 0.4), 1),
      ),
    );

    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [AuthFieldLabel(label!), const SizedBox(height: 8), field],
    );
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({
    required this.onTap,
    required this.leftPadding,
    required this.child,
  });

  final VoidCallback? onTap;
  final double leftPadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padded = Padding(
      padding: EdgeInsets.only(left: leftPadding, right: _sidePadding),
      child: Center(widthFactor: 1, child: child),
    );
    if (onTap == null) return padded;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: padded,
      ),
    );
  }
}

/// Password variant of [AuthTextField]: lock icon + eye toggle.
///
/// Obscured text shows as grey dots (the design's 5px #000 @ 42% dots) with
/// the `mdi:hide-outline` icon; tapping it reveals the text and shows
/// `mdi:eye-outline`.
///
/// ```dart
/// AuthPasswordField(
///   label: 'Password',
///   hint: 'Enter your password',
///   controller: _passCtrl,
///   textInputAction: TextInputAction.done,
///   onFieldSubmitted: (_) => _submit(),
///   validator: AuthValidators.password,
/// )
/// ```
class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.icon = AuthAssets.lock,
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.autovalidateMode,
    this.errorText,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.enabled = true,
    this.autofocus = false,
    this.autofillHints = const [AutofillHints.password],
    this.initiallyObscured = true,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;

  /// Leading icon asset; defaults to the lock (`mdi:password`).
  final String? icon;
  final TextInputAction textInputAction;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final bool autofocus;

  /// Use `[AutofillHints.newPassword]` on create/reset screens.
  final Iterable<String>? autofillHints;
  final bool initiallyObscured;

  /// Style of the obscuring dots (5px, #000 @ 42%, ~12.9px apart).
  /// Inter's bullet is ~0.28em wide, so the dots use an 18px font squeezed to
  /// the 13px line height (keeps the 45px box and caret unchanged).
  static const obscuredStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 13 * 1.21 / 18,
    letterSpacing: 2.7,
    color: Color(0x6B000000),
  );

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  late bool _obscured = widget.initiallyObscured;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      icon: widget.icon,
      obscureText: _obscured,
      style: _obscured ? AuthPasswordField.obscuredStyle : null,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      errorText: widget.errorText,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      onTrailingTap: () => setState(() => _obscured = !_obscured),
      trailing: Semantics(
        button: true,
        label: _obscured ? 'Show password' : 'Hide password',
        child: SvgPicture.asset(
          _obscured ? AuthAssets.eyeOff : AuthAssets.eye,
          width: _iconSize,
          height: _iconSize,
        ),
      ),
    );
  }
}

/// Default validators for the auth fields (English copy, like the screens).
abstract final class AuthValidators {
  static String? fullName(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Enter your full name' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your email';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Enter a password';
    if (v.length < 8) return 'Minimum 8 characters';
    return null;
  }

  /// `validator: AuthValidators.required('Pick your date of birth')`
  static FormFieldValidator<String> required(String message) =>
      (v) => (v == null || v.trim().isEmpty) ? message : null;
}
