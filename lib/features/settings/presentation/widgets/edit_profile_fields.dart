import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/settings/presentation/widgets/edit_profile_style.dart';

const _radius = BorderRadius.all(Radius.circular(8));

InputDecoration _decoration({required EdgeInsets padding}) {
  return InputDecoration(
    isDense: true,
    counterText: '',
    filled: true,
    fillColor: Colors.white,
    contentPadding: padding,
    enabledBorder: const OutlineInputBorder(
      borderRadius: _radius,
      borderSide: BorderSide(color: EditProfileColors.border),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: _radius,
      borderSide: BorderSide(color: EditProfileColors.brand, width: 1.5),
    ),
  );
}

/// The server's message under a rejected field.
class _FieldError extends StatelessWidget {
  const _FieldError(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        height: 1.21,
        letterSpacing: 0,
        color: AppColors.danger,
      ),
    );
  }
}

/// Labelled single-line input of the Edit Profile form. A [prefixText]
/// ("@") or [prefixIcon] (SVG) sits inside the field on the left; an
/// [errorText] shows under it.
class EditProfileTextField extends StatelessWidget {
  const EditProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.prefixText,
    this.prefixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.textInputAction = TextInputAction.next,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final String? errorText;
  final String? prefixText;
  final String? prefixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextInputAction textInputAction;

  static const _textStyle = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0,
    color: EditProfileColors.text,
  );

  @override
  Widget build(BuildContext context) {
    final start = prefixIcon != null
        ? 45.0
        : prefixText != null
        ? 37.0
        : 17.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        EditProfileLabel(label),
        DecoratedBox(
          decoration: editProfileFieldDecoration,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                maxLength: maxLength,
                maxLines: 1,
                textInputAction: textInputAction,
                style: _textStyle,
                decoration: _decoration(
                  padding: EdgeInsets.fromLTRB(start, 16, 17, 16),
                ),
              ),
              if (prefixText != null)
                Positioned(
                  left: 16,
                  child: IgnorePointer(
                    child: Text(
                      prefixText!,
                      style: _textStyle.copyWith(
                        color: EditProfileColors.muted,
                      ),
                    ),
                  ),
                ),
              if (prefixIcon != null)
                Positioned(
                  left: 16,
                  child: IgnorePointer(
                    child: SvgPicture.asset(prefixIcon!, width: 16, height: 16),
                  ),
                ),
            ],
          ),
        ),
        if (errorText != null) _FieldError(errorText!),
      ],
    );
  }
}

/// Bio input with a live `n/max` counter beside its label.
class EditProfileBioField extends StatelessWidget {
  const EditProfileBioField({
    super.key,
    required this.controller,
    this.maxLength = 160,
    this.errorText,
  });

  final TextEditingController controller;
  final int maxLength;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) => EditProfileLabel(
              'Bio',
              trailing: '${value.text.characters.length}/$maxLength',
            ),
          ),
          DecoratedBox(
            decoration: editProfileFieldDecoration,
            child: TextField(
              controller: controller,
              maxLength: maxLength,
              maxLines: null,
              // Two lines + the design's roomy bottom padding = its 81px box.
              minLines: 2,
              keyboardType: TextInputType.multiline,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                fontSize: 13,
                height: 19 / 13,
                letterSpacing: 0,
                color: EditProfileColors.text,
              ),
              decoration: _decoration(
                padding: const EdgeInsets.fromLTRB(14, 15, 14, 28),
              ),
            ),
          ),
          if (errorText != null) _FieldError(errorText!),
        ],
      ),
    );
  }
}
