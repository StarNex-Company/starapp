import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';

/// Uppercase grey section heading ("CAPTION", "WHAT YOU CAN DO"), with an
/// optional trailing note such as a counter or "Auto-generated".
class StarSectionLabel extends StatelessWidget {
  const StarSectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.72,
              color: AppColors.textSubtle,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              fontSize: 12,
              height: 1.2,
              letterSpacing: 0,
              color: AppColors.textFaint,
            ),
          ),
      ],
    );
  }
}

/// Labelled multi-line input with a live `n/max` counter (Caption, Tell us more).
class StarTextArea extends StatefulWidget {
  const StarTextArea({
    super.key,
    required this.label,
    required this.controller,
    required this.maxLength,
    this.hintText,
    this.minHeight = 104,
  });

  final String label;
  final TextEditingController controller;
  final int maxLength;
  final String? hintText;
  final double minHeight;

  @override
  State<StarTextArea> createState() => _StarTextAreaState();
}

class _StarTextAreaState extends State<StarTextArea> {
  static const _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        ValueListenableBuilder(
          valueListenable: widget.controller,
          builder: (context, value, _) => StarSectionLabel(
            widget.label,
            trailing: '${value.text.characters.length}/${widget.maxLength}',
          ),
        ),
        TextField(
          controller: widget.controller,
          maxLength: widget.maxLength,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textAlignVertical: TextAlignVertical.top,
          style: const TextStyle(
            fontSize: 15,
            height: 22 / 15,
            letterSpacing: 0,
            color: AppColors.ink,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              fontSize: 15,
              height: 22 / 15,
              letterSpacing: 0,
              color: AppColors.textFaint,
            ),
            counterText: '',
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            constraints: BoxConstraints(minHeight: widget.minHeight),
            contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            enabledBorder: const OutlineInputBorder(
              borderRadius: _radius,
              borderSide: BorderSide(color: AppColors.borderField),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: _radius,
              borderSide: BorderSide(color: AppColors.brandBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
