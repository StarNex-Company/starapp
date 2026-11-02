import 'package:flutter/material.dart';
import 'package:starapp/features/verification/data/models/verification.dart';
import 'package:starapp/shared/widgets/star_tabs.dart';

/// Single-choice document-type chips ("Passport", "National ID", …) that
/// wrap onto a second line.
class VerificationIdChips extends StatelessWidget {
  const VerificationIdChips({
    super.key,
    required this.types,
    required this.selectedId,
    required this.onSelected,
  });

  final List<VerificationIdType> types;
  final String selectedId;
  final ValueChanged<VerificationIdType> onSelected;

  @override
  Widget build(BuildContext context) {
    return StarChoiceChips<VerificationIdType>(
      chips: [
        for (final type in types) StarChip(value: type, label: type.label),
      ],
      selected: types.where((t) => t.id == selectedId).firstOrNull,
      onSelected: onSelected,
      wrap: true,
    );
  }
}
