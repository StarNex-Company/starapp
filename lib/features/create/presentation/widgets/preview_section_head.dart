import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/shared/widgets/star_form_fields.dart';

/// Section label with a grey note on the right ("TRIM  0:03 – 0:47 · 44s").
class PreviewSectionHead extends StatelessWidget {
  const PreviewSectionHead({
    super.key,
    required this.label,
    required this.note,
    this.noteWeight = FontWeight.w500,
  });

  final String label;
  final String note;
  final FontWeight noteWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Expanded(child: StarSectionLabel(label)),
        Text(
          note,
          style: TextStyle(
            height: 1.2,
            letterSpacing: 0,
            fontSize: 12,
            fontWeight: noteWeight,
            color: AppColors.textSubtle,
          ),
        ),
      ],
    );
  }
}
