import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_style.dart';
import 'package:starapp/shared/widgets/star_form_fields.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';

const _radius = BorderRadius.all(Radius.circular(12));

const _valueStyle = TextStyle(
  fontSize: 15,
  height: 22 / 15,
  letterSpacing: 0,
  color: AppColors.ink,
);

const _hintStyle = TextStyle(
  fontSize: 15,
  height: 22 / 15,
  letterSpacing: 0,
  color: AppColors.textFaint,
);

/// Uppercase label over a 52px field, with an inline [error] below it
/// (Add payout method, Tax information).
class WalletField extends StatelessWidget {
  const WalletField({
    super.key,
    required this.label,
    required this.child,
    this.error,
  });

  final String label;
  final Widget child;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        StarSectionLabel(label),
        child,
        if (error != null) WalletFieldError(error!),
      ],
    );
  }
}

class WalletFieldError extends StatelessWidget {
  const WalletFieldError(this.message, {super.key, this.textAlign});

  final String message;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: textAlign,
      style: const TextStyle(
        fontSize: 13,
        height: 18 / 13,
        letterSpacing: 0,
        color: AppColors.danger,
      ),
    );
  }
}

/// A text input styled like the design's fields.
class WalletTextInput extends StatelessWidget {
  const WalletTextInput({
    super.key,
    required this.controller,
    this.hintText,
    this.hasError = false,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onChanged,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String? hintText;
  final bool hasError;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onChanged: onChanged,
      style: _valueStyle,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: _hintStyle,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        // The outline adds its own 4px inset, so 12 lines the text up
        // with the picker fields' 16.
        contentPadding: const EdgeInsets.fromLTRB(12, 15, 12, 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: _radius,
          borderSide: BorderSide(
            color: hasError ? AppColors.danger : AppColors.borderField,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _radius,
          borderSide: BorderSide(
            color: hasError ? AppColors.danger : AppColors.brandBlue,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

/// A field that isn't typed into: a picker (Bank, Country) when [onTap] is
/// set, or a read-out (Account name). Shows [hint] while [value] is null.
class WalletFieldBox extends StatelessWidget {
  const WalletFieldBox({
    super.key,
    this.value,
    this.hint,
    this.onTap,
    this.trailing,
    this.hasError = false,
    this.semanticLabel,
  });

  final String? value;
  final String? hint;
  final VoidCallback? onTap;

  /// e.g. a small spinner while the value loads.
  final Widget? trailing;
  final bool hasError;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: _radius,
          side: BorderSide(
            color: hasError ? AppColors.danger : AppColors.borderField,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: Text(
                      value ?? hint ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: value == null ? _hintStyle : _valueStyle,
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 16px navy spinner for a field that is checking its value.
class WalletFieldSpinner extends StatelessWidget {
  const WalletFieldSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: AppColors.brandNavy,
      ),
    );
  }
}

/// 48×22 navy switch (Figma "Toggle - Switch"): outlined with a grey knob on
/// the left when off, filled navy with a white knob on the right when on.
class WalletToggle extends StatelessWidget {
  const WalletToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  static const _duration = Duration(milliseconds: 180);
  static const _offKnob = Color(0xFFC2C2C2); // surface/strong/c2c2c2

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: semanticLabel,
      enabled: onChanged != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: _duration,
          curve: Curves.easeOut,
          width: 48,
          height: 22,
          decoration: BoxDecoration(
            color: value ? AppColors.brandNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: AppColors.brandNavy,
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: _duration,
                curve: Curves.easeOut,
                left: value ? 17.5 : 2.5,
                top: 1.5,
                child: AnimatedContainer(
                  duration: _duration,
                  width: 25,
                  height: 16,
                  decoration: BoxDecoration(
                    color: value ? Colors.white : _offKnob,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single-choice row for the wallet's sheets: radio, then a bold label.
class WalletSheetOption extends StatelessWidget {
  const WalletSheetOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            spacing: 12,
            children: [
              StarRadioDot(selected: selected),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: walletLeading,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
